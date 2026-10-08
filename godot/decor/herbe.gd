extends MeshInstance3D
class_name Herbe
## Une touffe d'herbe basse : quelques brins en triangle, penchés au hasard autour du pied.
## Trop basse pour gêner les thons, elle n'est que du décor.

## Nombre de brins.
@export var nb_brins: int = 8
## Hauteur des brins, en unités Godot.
@export var hauteur: float = 0.8
## Largeur d'un brin au pied.
@export var largeur: float = 0.15
## Distance la plus grande entre un brin et le centre de la touffe.
@export var etalement: float = 0.4
## Couleur des brins.
@export var couleur: Color = Color(0.35, 0.65, 0.3)
## Graine du tirage au hasard : chaque touffe a la sienne.
@export var graine: int = 0

# Inclinaison la plus forte d'un brin, en part de sa hauteur.
const PENTE_MAX: float = 0.5
# Hauteur du brin le plus court, en part de `hauteur`.
const HAUTEUR_MIN: float = 0.6


func _ready() -> void:
	var hasard: RandomNumberGenerator = RandomNumberGenerator.new()
	hasard.seed = graine
	var outil: SurfaceTool = SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	for b: int in nb_brins:
		var angle: float = hasard.randf_range(0.0, TAU)
		var pied: Vector3 = Vector3(cos(angle), 0.0, sin(angle)) * hasard.randf_range(0.0, etalement)
		# Le brin s'élargit perpendiculairement à sa direction, et sa pointe penche vers l'extérieur.
		var cote: Vector3 = Vector3(-sin(angle), 0.0, cos(angle)) * largeur / 2.0
		var pointe: Vector3 = pied + Vector3(cos(angle), 0.0, sin(angle)) * hauteur * hasard.randf_range(0.0, PENTE_MAX)
		pointe.y = hauteur * hasard.randf_range(HAUTEUR_MIN, 1.0)
		for sommet: Vector3 in [pied - cote, pointe, pied + cote]:
			outil.add_vertex(sommet)
	outil.generate_normals()
	mesh = outil.commit()
	var matiere: StandardMaterial3D = StandardMaterial3D.new()
	matiere.albedo_color = couleur
	matiere.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_override = matiere
