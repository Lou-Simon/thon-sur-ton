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
@onready var _camera: Camera3D = $Camera
@onready var _sol: Sol = $Sol


func _ready() -> void:
	_tracer_aretes()
	# Le sol reçoit les dimensions au lieu de les réécrire : elles restent définies ici.
	_sol.construire(dimensions)
	_placer_camera()


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


# Recule la camera, face a l'aquarium, juste assez pour voir toute la boite.
func _placer_camera() -> void:
	# Rayon de la sphere qui contient la boite : la moitie de sa diagonale.
	var rayon: float = dimensions.length() / 2.0
	# La sphere tient dans le champ de vision quand sin(angle / 2) = rayon / distance.
	var demi_angle: float = deg_to_rad(_camera.fov / 2.0)
	var distance: float = rayon / sin(demi_angle)
	# Une camera regarde vers -z : on la recule donc vers +z (Vector3.BACK).
	_camera.position = Vector3.BACK * distance
