extends Node3D
class_name Thon
## Un thon du banc : il avance à une vitesse bornée, tourné dans le sens de sa nage,
## change doucement de direction grâce à l'errance, évite les parois et le sol,
## contourne les plantes et les coraux, et forme un banc avec ses voisins.
##
## Il ne connaît que ses voisins : les thons dans son rayon de vision, sauf ceux
## dans l'angle mort derrière lui. Il ne regarde jamais le banc entier.
##
## Trois forces viennent de ses voisins : la séparation l'écarte de ceux qui sont trop proches,
## l'alignement le fait nager dans la même direction qu'eux, la cohésion le rapproche de leur centre.
## Sans voisin, l'alignement et la cohésion valent zéro : il lui reste l'errance, l'évitement et le contournement.
##
## Errance de Reynolds : une cible glisse au hasard sur une sphère placée devant le thon,
## et le thon est attiré vers elle. Comme la cible bouge peu d'une image à l'autre,
## la direction change en douceur au lieu de trembler.
##
## Le thon ne bouge pas tout seul : à chaque pas, l'aquarium appelle `decider` sur tous
## les thons, puis `avancer` sur tous, pour qu'ils bougent en même temps (voir aquarium.gd).
## `decider` range la nouvelle vitesse à part, et `avancer` l'applique.

## Vitesse la plus faible du thon, en unités Godot par seconde.
@export var vitesse_min: float = 2.0
## Vitesse la plus forte du thon, en unités Godot par seconde.
@export var vitesse_max: float = 5.0
## Distance entre le thon et le centre de la sphère d'errance, en unités Godot.
@export var distance_errance: float = 2.0
## Rayon de la sphère d'errance : plus il est grand, plus le thon peut tourner fort.
@export var rayon_errance: float = 2.0
## Déplacement de la cible sur la sphère, par seconde : plus il est grand, plus le thon change souvent d'avis.
@export var hasard_errance: float = 3.0
## Poids de l'errance dans la somme des forces.
@export var poids_errance: float = 1.0
## Distance à partir de laquelle une paroi ou le sol repousse le thon, en unités Godot.
@export var portee_evitement: float = 4.0
## Poids de l'évitement dans la somme des forces.
@export var poids_evitement: float = 30.0
## Distance à partir de laquelle une plante ou un corail repousse le thon, en unités Godot.
@export var portee_obstacles: float = 4.0
## Poids du contournement des plantes et des coraux dans la somme des forces.
@export var poids_obstacles: float = 30.0
## Distance jusqu'où le thon voit ses voisins, en unités Godot.
@export var rayon_vision: float = 6.0
## Ouverture de l'angle mort derrière le thon, en degrés : la moitié de chaque côté de l'axe arrière.
@export var angle_mort: float = 90.0
## Distance en dessous de laquelle un voisin est trop proche et repousse le thon, en unités Godot.
@export var distance_separation: float = 3.0
## Poids de la séparation dans la somme des forces.
@export var poids_separation: float = 30.0
## Poids de l'alignement dans la somme des forces.
@export var poids_alignement: float = 6.0
## Poids de la cohésion dans la somme des forces.
@export var poids_cohesion: float = 1.0

# Vitesse actuelle : sa direction est le sens de nage, sa longueur la vitesse.
var _vitesse: Vector3
# Vitesse calculée par `decider`, appliquée par `avancer`. Elle est rangée à part parce que
# l'alignement lit `_vitesse` chez les voisins : tant que tous n'ont pas décidé, `_vitesse` ne
# doit pas changer, sinon un thon lirait la vitesse d'un voisin qui a déjà décidé.
var _vitesse_suivante: Vector3
# Cible d'errance, repérée par rapport au centre de la sphère.
var _cible_errance: Vector3
# Demi-dimensions de l'aquarium, son sol et les obstacles du décor, reçus de l'aquarium.
var _demi: Vector3
var _sol: Sol
var _obstacles: Array[Obstacle] = []
# Tous les thons de l'aquarium : le thon n'y cherche que ses voisins (voir `_voisins`).
var _banc: Array[Thon] = []


func _ready() -> void:
	# Chaque thon part dans une direction au hasard, à la vitesse la plus faible.
	var direction: Vector3 = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	_vitesse = direction * vitesse_min
	_vitesse_suivante = _vitesse
	_cible_errance = direction * rayon_errance


# C'est l'aquarium qui appelle cette fonction : lui seul connaît ses dimensions, son sol,
# son décor et la liste de ses thons (la même liste pour tous).
func installer(dimensions: Vector3, sol: Sol, obstacles: Array[Obstacle], banc: Array[Thon]) -> void:
	_demi = dimensions / 2.0
	_sol = sol
	_obstacles = obstacles
	_banc = banc


## Calcule la somme des forces et la vitesse suivante à partir des positions et des vitesses
## actuelles, sans bouger et sans changer `_vitesse`, que les voisins lisent pendant ce pas.
## À appeler à pas fixe (`_physics_process` de l'aquarium) : le hasard de l'errance ne dépend
## alors pas des images par seconde.
func decider(delta: float) -> void:
	# Les voisins sont cherchés une seule fois par pas, puis donnés aux trois forces du banc.
	var voisins: Array[Thon] = _voisins()
	var force: Vector3 = _errance(delta) * poids_errance + _evitement() * poids_evitement \
			+ _contournement() * poids_obstacles + _separation(voisins) * poids_separation \
			+ _alignement(voisins) * poids_alignement + _cohesion(voisins) * poids_cohesion
	_vitesse_suivante = _borner(_vitesse + force * delta)


## Applique la vitesse calculée par `decider`, déplace le thon et le tourne dans le sens de sa nage.
func avancer(delta: float) -> void:
	_vitesse = _vitesse_suivante
	position += _vitesse * delta
	# Le modèle regarde vers -Z : on l'oriente vers le point où il va.
	look_at(global_position + _vitesse)


# Les thons que celui-ci voit : à moins du rayon de vision, et hors de l'angle mort.
# L'angle mort est un cône autour de l'axe arrière, l'opposé de la vitesse.
func _voisins() -> Array[Thon]:
	var vus: Array[Thon] = []
	var arriere: Vector3 = -_vitesse
	for autre: Thon in _banc:
		# Un thon ne se voit pas lui-même.
		if autre == self:
			continue
		var ecart: Vector3 = autre.position - position
		var dans_angle_mort: bool = arriere.angle_to(ecart) < deg_to_rad(angle_mort / 2.0)
		if ecart.length() < rayon_vision and not dans_angle_mort:
			vus.append(autre)
	return vus


# Force de séparation : chaque voisin vu et trop proche pousse le thon à l'opposé de lui,
# avec la même rampe linéaire que les parois.
func _separation(voisins: Array[Thon]) -> Vector3:
	var force: Vector3 = Vector3.ZERO
	for voisin: Thon in voisins:
		var ecart: Vector3 = position - voisin.position
		force += ecart.normalized() * _poussee(ecart.length(), distance_separation)
	return force


# Force d'alignement : l'écart entre la vitesse moyenne des voisins vus et la vitesse du thon.
# Elle le fait tourner et accélérer ou ralentir pour nager comme eux.
func _alignement(voisins: Array[Thon]) -> Vector3:
	# Sans voisin, pas de moyenne : la force est nulle (et on ne divise pas par zéro).
	if voisins.is_empty():
		return Vector3.ZERO
	var somme: Vector3 = Vector3.ZERO
	for voisin: Thon in voisins:
		somme += voisin._vitesse
	return somme / voisins.size() - _vitesse


# Force de cohésion : du thon vers le centre de ses voisins vus, la moyenne de leurs positions.
func _cohesion(voisins: Array[Thon]) -> Vector3:
	# Sans voisin, pas de centre : la force est nulle (et on ne divise pas par zéro).
	if voisins.is_empty():
		return Vector3.ZERO
	var somme: Vector3 = Vector3.ZERO
	for voisin: Thon in voisins:
		somme += voisin.position
	return somme / voisins.size() - position


# Force d'évitement : chaque paroi proche pousse le thon vers l'intérieur, le sol le pousse vers le haut.
# Sur chaque axe, la paroi du côté négatif pousse vers +, celle du côté positif vers -.
# `position` est dans le repère de l'aquarium, centré sur son milieu.
func _evitement() -> Vector3:
	var sable: float = _sol.hauteur_sable(position.x, position.z)
	return Vector3(
		_poussee(position.x + _demi.x, portee_evitement) - _poussee(_demi.x - position.x, portee_evitement),
		_poussee(position.y - sable, portee_evitement) - _poussee(_demi.y - position.y, portee_evitement),
		_poussee(position.z + _demi.z, portee_evitement) - _poussee(_demi.z - position.z, portee_evitement))


# Force de contournement : chaque plante ou corail proche pousse le thon loin de son axe,
# avec la même rampe linéaire que les parois.
func _contournement() -> Vector3:
	var force: Vector3 = Vector3.ZERO
	for obstacle: Obstacle in _obstacles:
		var ecart: Vector3 = obstacle.ecart(position)
		force += ecart.normalized() * _poussee(ecart.length() - obstacle.rayon, portee_obstacles)
	return force


# Rampe linéaire : 0 à la portée ou plus loin, 1 au contact, plus de 1 si le thon a dépassé une paroi.
func _poussee(distance: float, portee: float) -> float:
	return maxf(0.0, 1.0 - distance / portee)


# Force d'errance : du thon vers la cible, qui glisse au hasard sur la sphère placée devant lui.
func _errance(delta: float) -> Vector3:
	var hasard: Vector3 = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	# On pousse la cible un peu au hasard, puis on la ramène sur la sphère.
	_cible_errance = (_cible_errance + hasard * hasard_errance * delta).normalized() * rayon_errance
	var centre: Vector3 = _vitesse.normalized() * distance_errance
	return centre + _cible_errance


# Ramène la longueur de la vitesse entre vitesse_min et vitesse_max, sans changer sa direction.
func _borner(vitesse: Vector3) -> Vector3:
	return vitesse.normalized() * clampf(vitesse.length(), vitesse_min, vitesse_max)
