extends Node3D
class_name Rayons
## Les rayons de lumière qui descendent de la surface : des bandes verticales aux bords doux,
## dont l'éclat monte et descend doucement.
## Chaque bande tourne autour de l'axe vertical pour toujours faire face à la caméra.

## Nombre de rayons.
@export var nombre: int = 18
## Largeur la plus petite et la plus grande d'un rayon, en unités Godot.
@export var largeur_min: float = 1.5
@export var largeur_max: float = 4.0
## Éclat d'un rayon là où il est le plus clair, de 0 (invisible) à 1.
@export var eclat: float = 0.2
## Durée d'une respiration de l'éclat, en secondes.
@export var periode: float = 6.0
## Hauteur au-dessus de l'aquarium d'où partent les rayons, en unités Godot.
@export var depart_au_dessus: float = 5.0
## Distance au-delà des parois où l'on place encore des rayons, en unités Godot.
@export var debord: float = 10.0
## Graine du tirage au hasard : mêmes rayons à chaque lancement, pour des démos qui se ressemblent.
@export var graine: int = 7

# Une bande est une grille de 3 × 3 sommets. Chaque colonne et chaque rangée a sa position
# (en part de la largeur ou de la hauteur) et son éclat : clair au centre et aux trois quarts
# de la hauteur, transparent sur les bords, en haut et en bas.
const COLONNES: Array[Vector2] = [Vector2(-0.5, 0.0), Vector2(0.0, 1.0), Vector2(0.5, 0.0)]
const RANGEES: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.75, 1.0), Vector2(1.0, 0.0)]

# Un matériau par rayon, pour que chacun respire à son rythme.
var _materiaux: Array[StandardMaterial3D] = []
# Décalage de chaque rayon dans sa respiration, en radians.
var _phases: Array[float] = []
var _temps: float = 0.0


# C'est l'aquarium qui appelle cette fonction : lui seul connaît ses dimensions.
func construire(dimensions: Vector3) -> void:
	var demi: Vector3 = dimensions / 2.0 + Vector3(debord, 0.0, debord)
	var hasard: RandomNumberGenerator = RandomNumberGenerator.new()
	hasard.seed = graine
	# Du haut (au-dessus de l'aquarium) jusqu'au sable.
	var hauteur: float = dimensions.y + depart_au_dessus
	for i: int in nombre:
		var largeur: float = hasard.randf_range(largeur_min, largeur_max)
		var rayon: MeshInstance3D = MeshInstance3D.new()
		rayon.mesh = _bande(largeur, hauteur)
		var materiau: StandardMaterial3D = _materiau()
		rayon.material_override = materiau
		rayon.position = Vector3(hasard.randf_range(-demi.x, demi.x), -dimensions.y / 2.0, hasard.randf_range(-demi.z, demi.z))
		add_child(rayon)
		_materiaux.append(materiau)
		_phases.append(hasard.randf_range(0.0, TAU))


func _process(delta: float) -> void:
	_temps += delta
	for i: int in _materiaux.size():
		# Entre 40 % et 100 % de l'éclat, selon une sinusoïde propre à chaque rayon.
		var respiration: float = 0.7 + 0.3 * sin(_temps * TAU / periode + _phases[i])
		_materiaux[i].albedo_color.a = eclat * respiration


# Une bande de la largeur et de la hauteur données, posée sur son bas : 4 carrés entre
# les 3 × 3 sommets. La couleur de chaque sommet porte sa transparence, que la carte graphique
# fait varier en douceur d'un sommet à l'autre.
func _bande(largeur: float, hauteur: float) -> ArrayMesh:
	var outil: SurfaceTool = SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	for c: int in COLONNES.size() - 1:
		for r: int in RANGEES.size() - 1:
			for coin: Vector2i in [Vector2i(c, r), Vector2i(c, r + 1), Vector2i(c + 1, r + 1),
					Vector2i(c, r), Vector2i(c + 1, r + 1), Vector2i(c + 1, r)]:
				var colonne: Vector2 = COLONNES[coin.x]
				var rangee: Vector2 = RANGEES[coin.y]
				outil.set_color(Color(1.0, 1.0, 1.0, colonne.y * rangee.y))
				outil.add_vertex(Vector3(colonne.x * largeur, rangee.x * hauteur, 0.0))
	return outil.commit()


func _materiau() -> StandardMaterial3D:
	var materiau: StandardMaterial3D = StandardMaterial3D.new()
	materiau.vertex_color_use_as_albedo = true
	# Lumière pure : pas d'ombre, et elle s'ajoute à ce qui est derrière au lieu de le cacher.
	materiau.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	materiau.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	materiau.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	materiau.cull_mode = BaseMaterial3D.CULL_DISABLED
	# La bande tourne autour de l'axe vertical pour faire face à la caméra.
	materiau.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	return materiau
