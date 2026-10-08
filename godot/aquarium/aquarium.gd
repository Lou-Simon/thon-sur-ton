extends Node3D
class_name Aquarium
## L'aquarium : une boîte centrée sur l'origine, aux parois invisibles, dans un océan ouvert.
## Les parois sont des limites que les thons évitent ; on ne les dessine pas.

## Longueur (x), hauteur (y) et profondeur (z) de l'aquarium, en unites Godot.
## Seul endroit ou les dimensions sont ecrites : tout le reste les lit ici.
@export var dimensions: Vector3 = Vector3(40.0, 20.0, 20.0)

@onready var _camera: CameraAquarium = $Camera
@onready var _sol: Sol = $Sol
@onready var _rayons: Rayons = $Rayons
@onready var _decor: Decor = $Decor
@onready var _thon: Thon = $Thon
@onready var _ambiance: Ambiance = $Ambiance
@onready var _interface: Interface = $Interface


func _ready() -> void:
	# Le sol reçoit les dimensions au lieu de les réécrire : elles restent définies ici.
	_sol.construire(dimensions)
	_rayons.construire(dimensions)
	_decor.construire(dimensions, _sol)
	# La caméra aussi, avec la hauteur des plus hautes dunes : elle doit rester au-dessus.
	_camera.installer(dimensions, -dimensions.y / 2.0 + _sol.hauteur_dunes)
	# Le thon reçoit les parois, le sol et les obstacles du décor qu'il doit éviter.
	_thon.installer(dimensions, _sol, _decor.obstacles())


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
