extends Node3D
class_name Plongee
## La scène principale : l'accueil posé au-dessus de la mer, l'aquarium en dessous,
## et la plongée qui fait passer une caméra de l'un à l'autre.
##
## Le chemin de la caméra passe par quatre points : la vue de l'accueil, au ras de l'eau,
## juste sous la surface, puis la vue de départ de l'aquarium. Entre deux points, la caméra
## glisse en ligne droite et tourne en douceur. Quand elle traverse la surface, on change
## de côté : l'ambiance, la lumière et ce qui est affiché basculent.
## La remontée (`Échap`) fait le même chemin à l'envers. Un clic ou `Entrée` passe l'une ou l'autre.

enum Etat { ACCUEIL, PLONGEE, AQUARIUM, REMONTEE }

## Durée de la plongée et de la remontée, en secondes.
@export var duree_plongee: float = 9.0
@export var duree_remontee: float = 5.0

# Les deux points autour de la surface, par rapport au point où la caméra la traverse :
# décalage de position et angle sous l'horizontale, en degrés.
const RAS_EAU: Vector3 = Vector3(0.0, 1.5, 4.0)
const ANGLE_RAS_EAU: float = 35.0
const SOUS_SURFACE: Vector3 = Vector3(0.0, -3.0, -4.0)
const ANGLE_SOUS_SURFACE: float = 25.0
# Où la caméra traverse la surface, entre la vue de l'accueil (0) et celle de l'aquarium (1).
const PART_TRAVERSEE: float = 0.4
# Moment où la caméra atteint chaque point, en part de la durée : la descente sous l'eau,
# la plus longue, prend plus de la moitié du temps.
const ETAPES_PLONGEE: Array[float] = [0.0, 0.3, 0.45, 1.0]
# Bulles qui partent devant la caméra quand elle traverse la surface : nombre, rayon,
# durée de vie, vitesse de montée (au moins, au plus), demi-taille de la boîte où elles naissent.
const NB_BULLES: int = 40
const RAYON_BULLE: float = 0.05
const DUREE_BULLES: float = 1.5
const VITESSE_BULLES: Vector2 = Vector2(1.0, 3.0)
const BOITE_BULLES: Vector3 = Vector3(1.5, 1.0, 0.5)
const COULEUR_BULLES: Color = Color(0.85, 0.95, 1.0, 0.7)
# Distance devant la caméra où naissent les bulles.
const AVANCE_BULLES: float = 2.0

var _etat: Etat = Etat.ACCUEIL
var _chemin: Array[Transform3D] = []
var _etapes: Array[float] = []
# Où en est la caméra sur son chemin, de 0 (premier point) à 1 (dernier point).
var _avancement: float = 0.0
var _trajet: Tween
var _dessous: bool = false
var _ambiance_haut: Environment
var _ambiance_bas: Environment

@onready var _accueil: Accueil = $Accueil
@onready var _aquarium: Aquarium = $Aquarium
@onready var _camera: Camera3D = $Camera
@onready var _bulles: GPUParticles3D = _creer_bulles()


func _ready() -> void:
	# Chaque caméra porte l'ambiance de son côté de la surface.
	_ambiance_haut = _accueil.ceder_environnement()
	_ambiance_bas = _aquarium.ceder_environnement()
	_accueil.camera().environment = _ambiance_haut
	_aquarium.camera().environment = _ambiance_bas
	_aquarium.activer(false)
	_changer_de_cote(false)
	_accueil.camera().make_current()
	_accueil.plonger_demande.connect(_plonger)


func _process(_delta: float) -> void:
	if _etat != Etat.PLONGEE and _etat != Etat.REMONTEE:
		return
	_camera.global_transform = _sur_le_chemin(_avancement)
	var dessous: bool = _camera.global_position.y < _accueil.global_position.y
	if dessous != _dessous:
		_changer_de_cote(dessous)
		_bulles.restart()


func _unhandled_input(evenement: InputEvent) -> void:
	if _etat == Etat.AQUARIUM and evenement.is_action_pressed("retour_accueil"):
		_remonter()
	elif _etat == Etat.PLONGEE or _etat == Etat.REMONTEE:
		var clic: bool = evenement is InputEventMouseButton and evenement.is_pressed()
		if clic or evenement.is_action_pressed("ui_accept"):
			# On avance le trajet bien au-delà de sa durée : il se termine aussitôt.
			_trajet.custom_step(60.0)
			get_viewport().set_input_as_handled()


func _plonger() -> void:
	# Un second clic sur « Plonger » pendant le fondu ne relance pas la plongée.
	if _etat != Etat.ACCUEIL:
		return
	_etat = Etat.PLONGEE
	_accueil.afficher_interface(false)
	_aquarium.camera().placer_au_depart()
	var depart: Transform3D = _accueil.camera().global_transform
	var arrivee: Transform3D = _aquarium.camera().global_transform
	_chemin = [depart, _point_ras_eau(depart, arrivee), _point_sous_surface(depart, arrivee), arrivee]
	_etapes = ETAPES_PLONGEE
	_partir(duree_plongee, _arriver)


func _arriver() -> void:
	_etat = Etat.AQUARIUM
	_aquarium.camera().make_current()
	_aquarium.activer(true)


func _remonter() -> void:
	_etat = Etat.REMONTEE
	_aquarium.activer(false)
	var depart: Transform3D = _aquarium.camera().global_transform
	var arrivee: Transform3D = _accueil.camera().global_transform
	# Le même chemin qu'à l'aller, parcouru à l'envers : les points sont calculés
	# à partir de l'accueil (arrivee) et de l'aquarium (depart), dans l'ordre inverse.
	_chemin = [depart, _point_sous_surface(arrivee, depart), _point_ras_eau(arrivee, depart), arrivee]
	_etapes = []
	for i: int in range(ETAPES_PLONGEE.size() - 1, -1, -1):
		_etapes.append(1.0 - ETAPES_PLONGEE[i])
	_partir(duree_remontee, _revenir)


func _revenir() -> void:
	_etat = Etat.ACCUEIL
	_accueil.camera().make_current()
	_accueil.afficher_interface(true)


# Lance la caméra de plongée sur `_chemin`, en accélérant au début et en freinant à la fin.
func _partir(duree: float, a_la_fin: Callable) -> void:
	_avancement = 0.0
	_camera.global_transform = _chemin[0]
	_camera.make_current()
	_trajet = create_tween()
	_trajet.tween_property(self, "_avancement", 1.0, duree).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_trajet.tween_callback(a_la_fin)


# La position et l'orientation de la caméra quand elle a fait la part `avancement` du chemin :
# on cherche entre quels points elle se trouve, puis on mélange ces deux points.
func _sur_le_chemin(avancement: float) -> Transform3D:
	for i: int in _chemin.size() - 1:
		if avancement <= _etapes[i + 1]:
			var part: float = (avancement - _etapes[i]) / (_etapes[i + 1] - _etapes[i])
			return _chemin[i].interpolate_with(_chemin[i + 1], part)
	return _chemin.back()


# Le point de la surface où la caméra la traverse, entre l'accueil et l'aquarium.
func _traversee(accueil: Transform3D, aquarium: Transform3D) -> Vector3:
	var point: Vector3 = accueil.origin.lerp(aquarium.origin, PART_TRAVERSEE)
	point.y = _accueil.global_position.y
	return point


func _point_ras_eau(accueil: Transform3D, aquarium: Transform3D) -> Transform3D:
	return _point(_traversee(accueil, aquarium) + RAS_EAU, ANGLE_RAS_EAU)


func _point_sous_surface(accueil: Transform3D, aquarium: Transform3D) -> Transform3D:
	return _point(_traversee(accueil, aquarium) + SOUS_SURFACE, ANGLE_SOUS_SURFACE)


# Une caméra placée en `lieu`, tournée vers l'avant (-z) et penchée de `angle` degrés vers le bas.
func _point(lieu: Vector3, angle: float) -> Transform3D:
	return Transform3D(Basis(Vector3.RIGHT, -deg_to_rad(angle)), lieu)


# Change de côté de la surface : on n'affiche que le monde où se trouve la caméra,
# avec sa lumière (les lumières sont dans chaque monde), et la caméra prend son ambiance.
func _changer_de_cote(dessous: bool) -> void:
	_dessous = dessous
	_accueil.visible = not dessous
	_aquarium.visible = dessous
	_camera.environment = _ambiance_bas if dessous else _ambiance_haut


# Une gerbe de bulles attachée à la caméra : elles naissent juste devant elle et montent.
func _creer_bulles() -> GPUParticles3D:
	var processus: ParticleProcessMaterial = ParticleProcessMaterial.new()
	processus.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	processus.emission_box_extents = BOITE_BULLES
	processus.direction = Vector3.UP
	processus.initial_velocity_min = VITESSE_BULLES.x
	processus.initial_velocity_max = VITESSE_BULLES.y
	processus.gravity = Vector3.ZERO
	var bulle: SphereMesh = SphereMesh.new()
	bulle.radius = RAYON_BULLE
	bulle.height = 2.0 * RAYON_BULLE
	var matiere: StandardMaterial3D = StandardMaterial3D.new()
	matiere.albedo_color = COULEUR_BULLES
	matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bulle.material = matiere
	var bulles: GPUParticles3D = GPUParticles3D.new()
	bulles.amount = NB_BULLES
	bulles.lifetime = DUREE_BULLES
	bulles.one_shot = true
	bulles.emitting = false
	# Presque toutes les bulles partent ensemble, en gerbe.
	bulles.explosiveness = 0.8
	bulles.local_coords = false
	bulles.process_material = processus
	bulles.draw_pass_1 = bulle
	# Juste devant la caméra, pour qu'elle passe à travers.
	bulles.position = Vector3.FORWARD * AVANCE_BULLES
	_camera.add_child(bulles)
	return bulles
