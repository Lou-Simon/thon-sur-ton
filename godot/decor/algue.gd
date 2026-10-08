extends Node3D
class_name Algue
## Une algue haute : quelques lanières qui montent du sable et ondulent.
## Chaque lanière est une chaîne de segments : chaque segment est l'enfant du précédent
## et tourne un peu, en retard sur lui. Les rotations s'additionnent le long de la chaîne,
## et le retard fait courir une vague du pied vers le sommet.

## Hauteur de l'algue, en unités Godot.
@export var hauteur: float = 10.0
## Nombre de lanières, réparties autour du pied.
@export var nb_lanieres: int = 4
## Nombre de segments par lanière : plus il y en a, plus la vague est souple.
@export var nb_segments: int = 8
## Largeur d'une lanière au pied ; elle s'affine jusqu'au sommet.
@export var largeur: float = 0.8
## Couleur de l'algue.
@export var couleur: Color = Color(0.15, 0.55, 0.3)
## Angle le plus grand de chaque segment, en degrés.
@export var amplitude: float = 3.0
## Ondulations par seconde.
@export var frequence: float = 0.3
## Décalage dans l'ondulation, en radians : deux algues voisines ne bougent pas ensemble.
@export var phase: float = 0.0

# Retard d'un segment sur le précédent dans la vague, en radians.
const RETARD: float = 0.5
# Largeur au sommet, en part de la largeur au pied.
const FINESSE_SOMMET: float = 0.3

# Tous les segments, rangés lanière par lanière, et leur rang dans leur lanière.
var _segments: Array[Node3D] = []
var _rangs: Array[int] = []
var _temps: float = 0.0


func _ready() -> void:
	var matiere: StandardMaterial3D = StandardMaterial3D.new()
	matiere.albedo_color = couleur
	matiere.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	matiere.specular_mode = BaseMaterial3D.SPECULAR_TOON
	# Une lanière est plate : on la voit des deux côtés.
	matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
	var longueur: float = hauteur / nb_segments
	for l: int in nb_lanieres:
		var parent: Node3D = Node3D.new()
		parent.rotation.y = TAU * l / nb_lanieres
		add_child(parent)
		for i: int in nb_segments:
			var segment: Node3D = Node3D.new()
			# Le premier segment part du pied, les suivants du haut du précédent.
			segment.position.y = 0.0 if i == 0 else longueur
			var morceau: MeshInstance3D = MeshInstance3D.new()
			morceau.mesh = _morceau(_largeur(i), _largeur(i + 1), longueur)
			morceau.material_override = matiere
			segment.add_child(morceau)
			parent.add_child(segment)
			_segments.append(segment)
			_rangs.append(i)
			parent = segment


func _process(delta: float) -> void:
	_temps += delta
	var angle_max: float = deg_to_rad(amplitude)
	for k: int in _segments.size():
		_segments[k].rotation.x = angle_max * sin(_temps * TAU * frequence + phase - _rangs[k] * RETARD)


# Largeur de la lanière à la base du segment i : elle diminue en ligne droite jusqu'au sommet.
func _largeur(i: int) -> float:
	return largeur * lerpf(1.0, FINESSE_SOMMET, float(i) / nb_segments)


# Un morceau de lanière : un trapèze plat, de la largeur du bas à celle du haut.
func _morceau(largeur_bas: float, largeur_haut: float, longueur: float) -> ArrayMesh:
	var a: Vector3 = Vector3(-largeur_bas / 2.0, 0.0, 0.0)
	var b: Vector3 = Vector3(largeur_bas / 2.0, 0.0, 0.0)
	var c: Vector3 = Vector3(largeur_haut / 2.0, longueur, 0.0)
	var d: Vector3 = Vector3(-largeur_haut / 2.0, longueur, 0.0)
	var outil: SurfaceTool = SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	for sommet: Vector3 in [a, d, c, a, c, b]:
		outil.add_vertex(sommet)
	outil.generate_normals()
	return outil.commit()
