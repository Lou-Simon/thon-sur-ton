extends Node3D
class_name Thon
## Un thon qui nage : il avance à une vitesse bornée, tourné dans le sens de sa nage,
## change doucement de direction grâce à l'errance, évite les parois et le sol,
## et contourne les plantes et les coraux.
##
## Errance de Reynolds : une cible glisse au hasard sur une sphère placée devant le thon,
## et le thon est attiré vers elle. Comme la cible bouge peu d'une image à l'autre,
## la direction change en douceur au lieu de trembler.

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

# Vitesse actuelle : sa direction est le sens de nage, sa longueur la vitesse.
var _vitesse: Vector3
# Cible d'errance, repérée par rapport au centre de la sphère.
var _cible_errance: Vector3
# Demi-dimensions de l'aquarium, son sol et les obstacles du décor, reçus de l'aquarium.
var _demi: Vector3
var _sol: Sol
var _obstacles: Array[Obstacle] = []


func _ready() -> void:
	# Le thon part dans la longueur de l'aquarium, pour rester visible le plus longtemps.
	_vitesse = Vector3.RIGHT * vitesse_min
	_cible_errance = Vector3.RIGHT * rayon_errance


# `_physics_process` tourne à pas fixe : le hasard de l'errance ne dépend pas des images par seconde.
func _physics_process(delta: float) -> void:
	var force: Vector3 = _errance(delta) * poids_errance + _evitement() * poids_evitement \
			+ _contournement() * poids_obstacles
	_vitesse = _borner(_vitesse + force * delta)
	position += _vitesse * delta
	# Le modèle regarde vers -Z : on l'oriente vers le point où il va.
	look_at(global_position + _vitesse)


# C'est l'aquarium qui appelle cette fonction : lui seul connaît ses dimensions, son sol et son décor.
func installer(dimensions: Vector3, sol: Sol, obstacles: Array[Obstacle]) -> void:
	_demi = dimensions / 2.0
	_sol = sol
	_obstacles = obstacles


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


# Rampe linéaire : 0 à la portée ou plus loin, 1 contre la paroi, plus de 1 si le thon l'a dépassée.
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
