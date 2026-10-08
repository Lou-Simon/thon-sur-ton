extends Node3D
class_name Aquarium
## L'aquarium : une boîte centrée sur l'origine, aux parois invisibles, dans un océan ouvert.
## Les parois sont des limites que les thons évitent ; on ne les dessine pas.

# La scène d'un thon : l'aquarium en crée `nombre_thons` copies.
const SCENE_THON: PackedScene = preload("res://thon/thon.tscn")

## Longueur (x), hauteur (y) et profondeur (z) de l'aquarium, en unites Godot.
## Seul endroit ou les dimensions sont ecrites : tout le reste les lit ici.
@export var dimensions: Vector3 = Vector3(40.0, 20.0, 20.0)
## Nombre de thons crees au lancement.
## Seul endroit ou ce nombre est ecrit : le curseur de la v2.3.0 le reglera ici.
@export var nombre_thons: int = 15

# Tous les thons de l'aquarium. Chaque thon reçoit cette même liste, pas une copie.
var _banc: Array[Thon] = []

@onready var _camera: CameraAquarium = $Camera
@onready var _sol: Sol = $Sol
@onready var _rayons: Rayons = $Rayons
@onready var _decor: Decor = $Decor
@onready var _ambiance: Ambiance = $Ambiance
@onready var _interface: Interface = $Interface


func _ready() -> void:
	# Le sol reçoit les dimensions au lieu de les réécrire : elles restent définies ici.
	_sol.construire(dimensions)
	_rayons.construire(dimensions)
	_decor.construire(dimensions, _sol)
	# La caméra aussi, avec la hauteur des plus hautes dunes : elle doit rester au-dessus.
	_camera.installer(dimensions, -dimensions.y / 2.0 + _sol.hauteur_dunes)
	_creer_banc()


# Mise à jour en deux temps : une première boucle où tous les thons décident, puis une seconde
# où tous avancent.
# Pourquoi : chaque thon décide à partir des positions et des vitesses du même instant. Avec une seule boucle,
# le deuxième thon verrait le premier déjà déplacé, et le résultat dépendrait de l'ordre de la liste.
func _physics_process(delta: float) -> void:
	for thon: Thon in _banc:
		thon.decider(delta)
	for thon: Thon in _banc:
		thon.avancer(delta)


## La caméra de l'aquarium : la plongée la rejoint, puis lui laisse la main.
func camera() -> CameraAquarium:
	return _camera


## Rend l'ambiance sous-marine et la retire du monde : quand l'aquarium et l'accueil sont
## réunis, chaque caméra porte l'ambiance de son côté de la surface.
func ceder_environnement() -> Environment:
	var milieu: Environment = _ambiance.environment
	_ambiance.environment = null
	return milieu


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
		add_child(thon)
		thon.position = _position_au_hasard(thon.portee_evitement)
		# Le thon reçoit les parois, le sol, les obstacles du décor et la liste de tous les thons.
		thon.installer(dimensions, _sol, _decor.obstacles(), _banc)
		_banc.append(thon)


# Un point au hasard dans l'aquarium, à plus de `marge` des parois et du sable.
# La marge est la portée d'évitement du thon : au départ, aucune paroi ne le repousse.
# Le décor n'est pas pris en compte : un thon peut naître dans une plante, et le contournement l'en fait sortir.
func _position_au_hasard(marge: float) -> Vector3:
	var demi: Vector3 = dimensions / 2.0
	var x: float = randf_range(-demi.x + marge, demi.x - marge)
	var z: float = randf_range(-demi.z + marge, demi.z - marge)
	# Le bas part du sable à cet endroit, pas du fond de la boîte : les dunes montent plus haut.
	var y: float = randf_range(_sol.hauteur_sable(x, z) + marge, demi.y - marge)
	return Vector3(x, y, z)
