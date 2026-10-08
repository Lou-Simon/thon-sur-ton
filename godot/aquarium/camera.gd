extends Camera3D
class_name CameraAquarium
## La caméra de l'aquarium : elle tourne autour d'un point, le pivot, et le regarde toujours.
## La souris change les deux angles et la distance, le clavier déplace le pivot.
## En zoomant près du pivot puis en le déplaçant, on se promène dans l'aquarium.
##
## Chaque réglage existe en deux exemplaires : la valeur voulue, que les commandes
## modifient d'un coup, et la valeur affichée, qui la rejoint en douceur.

## Angle dont la caméra tourne quand la souris glisse d'un pixel, en degrés.
@export var sensibilite_souris: float = 0.3
## Tangage le plus fort, vers le haut comme vers le bas, en degrés.
## Doit rester sous 90 : à la verticale exacte, la caméra ne sait plus où est le haut.
@export var tangage_max: float = 85.0
## Part de la distance gagnée ou perdue à chaque cran de molette (0.1 = 10 %).
@export var pas_zoom: float = 0.1
## Distance la plus courte entre la caméra et le pivot, en unités Godot.
@export var distance_min: float = 2.0
## Distance la plus longue, en nombre de fois la distance de départ.
@export var facteur_distance_max: float = 1.5
## Vitesse du pivot quand on le déplace au clavier, en unités Godot par seconde.
@export var vitesse_pivot: float = 10.0
## Hauteur gardée entre la caméra (ou le pivot) et le haut des dunes, en unités Godot.
@export var marge_sol: float = 0.5
## Rapidité avec laquelle la vue rejoint la position voulue : plus c'est grand, plus c'est vif.
@export var douceur: float = 10.0

# Limites reçues de l'aquarium, ou calculées à partir de ses dimensions.
var _pivot_min: Vector3
var _pivot_max: Vector3
var _hauteur_min: float
var _distance_depart: float
var _distance_max: float

# Valeurs voulues : là où les commandes demandent d'aller.
var _pivot_voulu: Vector3
var _lacet_voulu: float
var _tangage_voulu: float
var _distance_voulue: float

# Valeurs affichées : là où la caméra en est. Angles en radians.
var _pivot: Vector3
var _lacet: float
var _tangage: float
var _distance: float


func _process(delta: float) -> void:
	_deplacer_pivot(delta)
	_adoucir(delta)
	_placer()


# `_unhandled_input` ne reçoit que ce que l'interface n'a pas utilisé :
# un clic sur un futur bouton ne fera pas tourner la caméra.
func _unhandled_input(evenement: InputEvent) -> void:
	if evenement is InputEventMouseMotion and Input.is_action_pressed("camera_tourner"):
		_tourner((evenement as InputEventMouseMotion).relative)
	elif evenement.is_action_pressed("camera_zoom_avant"):
		_zoomer(1.0 - pas_zoom)
	elif evenement.is_action_pressed("camera_zoom_arriere"):
		_zoomer(1.0 + pas_zoom)
	elif evenement.is_action_pressed("camera_recentrer"):
		_recentrer()


# Prépare la caméra pour une boîte de la taille donnée, dont le sable monte jusqu'à `hauteur_sol`.
# C'est l'aquarium qui appelle cette fonction : lui seul connaît les dimensions.
func installer(dimensions: Vector3, hauteur_sol: float) -> void:
	var demi: Vector3 = dimensions / 2.0
	_hauteur_min = hauteur_sol + marge_sol
	# Le pivot reste dans la boîte, au-dessus du sable.
	_pivot_min = Vector3(-demi.x, _hauteur_min, -demi.z)
	_pivot_max = demi
	# Distance de départ : juste assez pour voir toute la boîte.
	# Rayon de la sphère qui contient la boîte : la moitié de sa diagonale.
	var rayon: float = dimensions.length() / 2.0
	# La sphère tient dans le champ de vision quand sin(angle / 2) = rayon / distance.
	_distance_depart = rayon / sin(deg_to_rad(fov / 2.0))
	_distance_max = _distance_depart * facteur_distance_max
	_recentrer()
	# Au lancement, la caméra est tout de suite à la vue de départ, sans glisser jusqu'à elle.
	_distance = _distance_voulue
	_placer()


# Retour à la vue de départ : pivot au centre de la boîte, caméra de face, toute la boîte visible.
func _recentrer() -> void:
	# Après plusieurs tours, le lacet vaut plus d'un tour complet. On le ramène entre
	# -PI et PI (même angle, même image), sinon le retour déroulerait tous les tours.
	_lacet = wrapf(_lacet, -PI, PI)
	_pivot_voulu = Vector3.ZERO
	_lacet_voulu = 0.0
	_tangage_voulu = 0.0
	_distance_voulue = _distance_depart


# Tourne autour du pivot, d'après le glissement de la souris en pixels.
func _tourner(glissement: Vector2) -> void:
	var angle: Vector2 = glissement * deg_to_rad(sensibilite_souris)
	# Souris vers la droite : la caméra part à gauche, la scène suit donc la souris.
	_lacet_voulu -= angle.x
	# Souris vers le bas : la caméra monte et regarde l'aquarium de plus haut.
	var limite: float = deg_to_rad(tangage_max)
	_tangage_voulu = clampf(_tangage_voulu + angle.y, -limite, limite)


# Multiplie la distance au pivot : le zoom reste régulier de près comme de loin.
func _zoomer(facteur: float) -> void:
	_distance_voulue = clampf(_distance_voulue * facteur, distance_min, _distance_max)


# Déplace le pivot au clavier, par rapport à la direction dans laquelle on regarde.
func _deplacer_pivot(delta: float) -> void:
	# x : gauche (-1) ou droite (+1). y : avancer (-1) ou reculer (+1).
	var plan: Vector2 = Input.get_vector(
			"camera_gauche", "camera_droite", "camera_avancer", "camera_reculer")
	var vertical: float = Input.get_axis("camera_descendre", "camera_monter")
	# Reculer, c'est aller vers +z quand le lacet est nul. On tourne ce déplacement
	# du même lacet que la caméra, autour de la verticale : monter reste donc vertical.
	var deplacement: Vector3 = Vector3(plan.x, vertical, plan.y).rotated(Vector3.UP, _lacet)
	_pivot_voulu += deplacement * vitesse_pivot * delta
	_pivot_voulu = _pivot_voulu.clamp(_pivot_min, _pivot_max)


# Rapproche les valeurs affichées des valeurs voulues.
func _adoucir(delta: float) -> void:
	# Part du chemin parcourue pendant cette image. Avec l'exponentielle, deux images
	# courtes font exactement le même chemin qu'une image longue : le mouvement ne
	# dépend pas du nombre d'images par seconde.
	var part: float = 1.0 - exp(-douceur * delta)
	_pivot = _pivot.lerp(_pivot_voulu, part)
	_lacet = lerpf(_lacet, _lacet_voulu, part)
	_tangage = lerpf(_tangage, _tangage_voulu, part)
	_distance = lerpf(_distance, _distance_voulue, part)


# Calcule la position de la caméra à partir du pivot, des deux angles et de la distance.
func _placer() -> void:
	# Direction du pivot vers la caméra, de longueur 1.
	# Le tangage est l'angle au-dessus de l'horizontale : sin(tangage) donne la hauteur,
	# cos(tangage) ce qui reste à l'horizontale. Le lacet répartit ce reste entre x et z.
	# Angles nuls : direction (0, 0, 1), la caméra est en +z, face à l'aquarium.
	var direction: Vector3 = Vector3(
			cos(_tangage) * sin(_lacet),
			sin(_tangage),
			cos(_tangage) * cos(_lacet))
	var cible: Vector3 = _pivot + direction * _distance
	# La caméra ne passe jamais sous le sable : si elle descendait trop, on la remonte.
	cible.y = maxf(cible.y, _hauteur_min)
	# L'aquarium est centré sur l'origine : ses coordonnées sont celles du monde.
	look_at_from_position(cible, _pivot)
