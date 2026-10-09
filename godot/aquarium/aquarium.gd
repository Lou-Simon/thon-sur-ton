extends Node3D
class_name Aquarium
## L'aquarium : une boîte centrée sur l'origine, aux parois invisibles, dans un océan ouvert.
## Les parois sont des limites que les thons évitent ; on ne les dessine pas.

# La scène d'un thon : l'aquarium en crée `nombre_thons` copies.
const SCENE_THON: PackedScene = preload("res://thon/thon.tscn")
const SCENE_REQUIN: PackedScene = preload("res://obstacles/requin.tscn")

## Longueur (x), hauteur (y) et profondeur (z) de l'aquarium, en unites Godot.
## Seul endroit ou les dimensions sont ecrites : tout le reste les lit ici.
@export var dimensions: Vector3 = Vector3(40.0, 20.0, 20.0)
## Nombre de thons crees au lancement.
## Seul endroit ou ce nombre est ecrit : le curseur le regle ici, et il compte au prochain `relancer`.
@export var nombre_thons: int = 30

# Tous les thons de l'aquarium. Chaque thon reçoit cette même liste, pas une copie.
var _banc: Array[Thon] = []
# Tout ce que les thons contournent : les plantes et coraux du décor, puis le rocher.
var _obstacles: Array[Obstacle] = []
# Réglages changés par les curseurs : nom d'une variable `@export` du thon, et sa valeur.
# Gardés ici pour que les thons créés par `relancer` les reçoivent aussi.
var _reglages: Dictionary[StringName, float] = {}
# Le requin : ni dans `_banc` ni dans `_obstacles`, les thons ne le voient donc pas encore.
var _requin: Requin

@onready var _camera: CameraAquarium = $Camera
@onready var _sol: Sol = $Sol
@onready var _rayons: Rayons = $Rayons
@onready var _decor: Decor = $Decor
@onready var _rocher: Rocher = $Rocher
@onready var _ambiance: Ambiance = $Ambiance
@onready var _interface: Interface = $Interface


func _ready() -> void:
	# Le sol reçoit les dimensions au lieu de les réécrire : elles restent définies ici.
	_sol.construire(dimensions)
	_rayons.construire(dimensions)
	_decor.construire(dimensions, _sol)
	_rocher.construire(_sol)
	_obstacles = _decor.obstacles().duplicate()
	_obstacles.append(_rocher.obstacle())
	# La caméra aussi, avec la hauteur des plus hautes dunes : elle doit rester au-dessus.
	_camera.installer(dimensions, -dimensions.y / 2.0 + _sol.hauteur_dunes)
	_creer_banc()
	_creer_requin()
	_interface.installer(self)


# Mise à jour en deux temps : une première boucle où tous les thons décident, puis une seconde
# où tous avancent.
# Pourquoi : chaque thon décide à partir des positions et des vitesses du même instant. Avec une seule boucle,
# le deuxième thon verrait le premier déjà déplacé, et le résultat dépendrait de l'ordre de la liste.
func _physics_process(delta: float) -> void:
	for thon: Thon in _banc:
		thon.decider(delta)
	_requin.decider(delta)
	for thon: Thon in _banc:
		thon.avancer(delta)
	_requin.avancer(delta)


## La caméra de l'aquarium : la plongée la rejoint, puis lui laisse la main.
func camera() -> CameraAquarium:
	return _camera


## Rend l'ambiance sous-marine et la retire du monde : quand l'aquarium et l'accueil sont
## réunis, chaque caméra porte l'ambiance de son côté de la surface.
func ceder_environnement() -> Environment:
	var milieu: Environment = _ambiance.environment
	_ambiance.environment = null
	return milieu


## Donne la même valeur à un réglage de tous les thons. `reglage` est le nom d'une variable
## `@export` du thon (`poids_separation`, `vitesse_max`…) : les thons la lisent à chaque pas,
## le changement se voit donc tout de suite.
func regler(reglage: StringName, valeur: float) -> void:
	_reglages[reglage] = valeur
	for thon: Thon in _banc:
		thon.set(reglage, valeur)


## Valeur actuelle d'un réglage des thons (tous ont la même).
func reglage(nom: StringName) -> float:
	return _banc[0].get(nom)


## Retire tous les thons et en crée `nombre_thons` nouveaux, à des positions au hasard,
## avec les réglages en cours.
func relancer() -> void:
	for thon: Thon in _banc:
		thon.queue_free()
	# On vide la liste sans la remplacer : c'est la même que celle que les thons reçoivent.
	_banc.clear()
	_creer_banc()


## Donne ou retire la main à l'utilisateur : la caméra répond aux commandes et
## le panneau de réglage s'affiche, ou rien ne bouge et le panneau est caché.
func activer(oui: bool) -> void:
	var mode: ProcessMode = Node.PROCESS_MODE_INHERIT if oui else Node.PROCESS_MODE_DISABLED
	_camera.process_mode = mode
	_interface.process_mode = mode
	_interface.visible = oui


# Crée les thons, enfants directs de l'aquarium : leur `position` est alors dans son repère,
# celui où les thons comparent leurs positions entre eux et avec les parois.
func _creer_banc() -> void:
	for n: int in nombre_thons:
		var thon: Thon = SCENE_THON.instantiate() as Thon
		# Les réglages passent avant `add_child` : le `_ready` du thon lit déjà sa vitesse minimale.
		for nom: StringName in _reglages:
			thon.set(nom, _reglages[nom])
		add_child(thon)
		thon.position = _position_au_hasard(thon.portee_evitement)
		# Le thon reçoit les parois, le sol, les obstacles et la liste de tous les thons.
		thon.installer(dimensions, _sol, _obstacles, _banc)
		_banc.append(thon)


# Crée le requin, enfant direct de l'aquarium comme les thons. Il n'est créé qu'une fois :
# `relancer` ne remplace que les thons.
func _creer_requin() -> void:
	_requin = SCENE_REQUIN.instantiate() as Requin
	add_child(_requin)
	_requin.position = _position_au_hasard(_requin.portee_evitement)
	# Il reçoit les parois, le sol et les obstacles, mais une liste de thons vide : il n'a pas de banc.
	var aucun_thon: Array[Thon] = []
	_requin.installer(dimensions, _sol, _obstacles, aucun_thon)


# Un point au hasard dans l'aquarium, à plus de `marge` des parois, du sable et des obstacles.
# La marge est la portée d'évitement du poisson placé : au départ, rien ne le repousse.
func _position_au_hasard(marge: float) -> Vector3:
	var demi: Vector3 = dimensions / 2.0
	while true:
		var x: float = randf_range(-demi.x + marge, demi.x - marge)
		var z: float = randf_range(-demi.z + marge, demi.z - marge)
		# Le bas part du sable à cet endroit, pas du fond de la boîte : les dunes montent plus haut.
		var y: float = randf_range(_sol.hauteur_sable(x, z) + marge, demi.y - marge)
		var point: Vector3 = Vector3(x, y, z)
		if not _obstacles.any(func(o: Obstacle) -> bool: return o.ecart(point).length() < o.rayon + marge):
			return point
	return Vector3.ZERO
