extends MeshInstance3D
class_name CorailRond
## Un corail rond, façon corail cerveau : une demi-sphère aplatie, couverte de bosses.
## Elle est construite anneau par anneau, comme le corps du thon.

## Rayon du corail, en unités Godot.
@export var rayon: float = 1.2
## Couleur du corail.
@export var couleur: Color = Color(0.95, 0.45, 0.55)

# Nombre d'anneaux du pied au sommet, et de sommets sur chaque anneau.
const ANNEAUX: int = 12
const SEGMENTS: int = 24
# Hauteur par rapport au rayon : le corail est plus large que haut.
const APLATISSEMENT: float = 0.75
# Nombre de bosses sur un tour, et leur hauteur en part du rayon.
const NB_BOSSES: float = 8.0
const HAUTEUR_BOSSES: float = 0.08


func _ready() -> void:
	var outil: SurfaceTool = SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in ANNEAUX:
		for j: int in SEGMENTS:
			for k: Vector2i in [Vector2i(i, j), Vector2i(i + 1, j + 1), Vector2i(i + 1, j),
					Vector2i(i, j), Vector2i(i, j + 1), Vector2i(i + 1, j + 1)]:
				outil.add_vertex(_sommet(k.x, k.y))
	outil.generate_normals()
	mesh = outil.commit()
	var matiere: StandardMaterial3D = StandardMaterial3D.new()
	matiere.albedo_color = couleur
	matiere.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	matiere.specular_mode = BaseMaterial3D.SPECULAR_TOON
	material_override = matiere


# Sommet j de l'anneau i. La hauteur sur la demi-sphère va de 0 (pied) à PI / 2 (sommet),
# et le rayon y est modulé par des bosses dans les deux directions.
func _sommet(i: int, j: int) -> Vector3:
	var hauteur: float = PI / 2.0 * i / ANNEAUX
	var tour: float = TAU * j / SEGMENTS
	var bosse: float = 1.0 + HAUTEUR_BOSSES * sin(NB_BOSSES * tour) * sin(NB_BOSSES * hauteur)
	var r: float = rayon * bosse
	return Vector3(cos(hauteur) * cos(tour) * r, sin(hauteur) * r * APLATISSEMENT, cos(hauteur) * sin(tour) * r)
