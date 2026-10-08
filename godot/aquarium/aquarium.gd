extends Node3D
class_name Aquarium
## L'aquarium : une boite centree sur l'origine, aux parois invisibles.
## On n'en dessine que les 12 aretes, pour que la boite se lise a l'ecran.

# Les deux cotes de la boite sur un axe : le cote negatif et le cote positif.
const COTES: Array[float] = [-1.0, 1.0]

## Longueur (x), hauteur (y) et profondeur (z) de l'aquarium, en unites Godot.
## Seul endroit ou les dimensions sont ecrites : tout le reste les lit ici.
@export var dimensions: Vector3 = Vector3(40.0, 20.0, 20.0)

@onready var _aretes: MeshInstance3D = $Aretes
@onready var _camera: CameraAquarium = $Camera
@onready var _sol: Sol = $Sol
@onready var _thon: Thon = $Thon


func _ready() -> void:
	_tracer_aretes()
	# Le sol reçoit les dimensions au lieu de les réécrire : elles restent définies ici.
	_sol.construire(dimensions)
	# La caméra aussi, avec la hauteur des plus hautes dunes : elle doit rester au-dessus.
	_camera.installer(dimensions, -dimensions.y / 2.0 + _sol.hauteur_dunes)
	# Le thon reçoit les parois et le sol qu'il doit éviter.
	_thon.installer(dimensions, _sol)


# Trace les 12 aretes de la boite : 4 aretes paralleles a chacun des 3 axes.
func _tracer_aretes() -> void:
	var demi: Vector3 = dimensions / 2.0
	var maillage: ImmediateMesh = ImmediateMesh.new()
	# PRIMITIVE_LINES : chaque paire de sommets forme un segment.
	maillage.surface_begin(Mesh.PRIMITIVE_LINES)
	for a: float in COTES:
		for b: float in COTES:
			# Arete parallele a l'axe x
			maillage.surface_add_vertex(Vector3(-demi.x, a * demi.y, b * demi.z))
			maillage.surface_add_vertex(Vector3(demi.x, a * demi.y, b * demi.z))
			# Arete parallele a l'axe y
			maillage.surface_add_vertex(Vector3(a * demi.x, -demi.y, b * demi.z))
			maillage.surface_add_vertex(Vector3(a * demi.x, demi.y, b * demi.z))
			# Arete parallele a l'axe z
			maillage.surface_add_vertex(Vector3(a * demi.x, b * demi.y, -demi.z))
			maillage.surface_add_vertex(Vector3(a * demi.x, b * demi.y, demi.z))
	maillage.surface_end()
	_aretes.mesh = maillage
