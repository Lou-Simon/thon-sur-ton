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
@onready var _thon: Thon = $Thon


func _ready() -> void:
	# Le sol reçoit les dimensions au lieu de les réécrire : elles restent définies ici.
	_sol.construire(dimensions)
	_rayons.construire(dimensions)
	# La caméra aussi, avec la hauteur des plus hautes dunes : elle doit rester au-dessus.
	_camera.installer(dimensions, -dimensions.y / 2.0 + _sol.hauteur_dunes)
	# Le thon reçoit les parois et le sol qu'il doit éviter.
	_thon.installer(dimensions, _sol)

