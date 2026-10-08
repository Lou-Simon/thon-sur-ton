extends MeshInstance3D
class_name Sol
## Le sol de sable : une grille de petits carrés posée au fond de l'aquarium,
## dont chaque sommet est remonté pour former des dunes.
## Autour de l'aquarium, les dunes s'aplatissent peu à peu, puis un grand plan de sable
## plat prend le relais jusqu'à l'horizon, où le brouillard l'efface.

## Hauteur d'une dune, du creux à la crête, en unités Godot.
@export var hauteur_dunes: float = 0.6
## Distance entre deux crêtes voisines, en unités Godot.
@export var espacement_dunes: float = 8.0
## Côté d'un carré de la grille : plus il est petit, plus les dunes sont lisses.
@export var taille_maille: float = 0.5
## Couleur du sable.
@export var couleur_sable: Color = Color(0.85, 0.75, 0.55)
## Distance, au-delà des parois, sur laquelle les dunes s'aplatissent, en unités Godot.
@export var etendue_dunes: float = 20.0
## Côté du plan de sable plat qui va jusqu'à l'horizon, en unités Godot.
@export var taille_horizon: float = 2000.0

# Le shader du sable : éclairage toon et reflets de lumière.
const SHADER_SABLE: Shader = preload("res://aquarium/sable.gdshader")
# Taille du motif des reflets, en pixels, et nombre de cellules sur sa largeur.
const TAILLE_MOTIF: int = 256
const CELLULES_MOTIF: float = 8.0

# Le plan plat est posé un peu sous le creux des dunes : sous la grille, les deux surfaces
# ne se disputent pas le même pixel.
const DECALAGE_HORIZON: float = 0.02

var _demi: Vector3


# Construit le sol au fond d'une boîte de la taille donnée.
# C'est l'aquarium qui appelle cette fonction : lui seul connaît les dimensions.
func construire(dimensions: Vector3) -> void:
	_demi = dimensions / 2.0
	# Le creux des dunes est exactement au fond de la boîte : le sable ne passe jamais dessous.
	position.y = -_demi.y
	# La grille couvre le fond de la boîte, plus la bande où les dunes s'aplatissent.
	var demi: Vector3 = _demi + Vector3(etendue_dunes, 0.0, etendue_dunes)
	# Nombre de carrés sur chaque axe, arrondi au-dessus pour couvrir toute la grille.
	var nb_x: int = ceili(2.0 * demi.x / taille_maille)
	var nb_z: int = ceili(2.0 * demi.z / taille_maille)
	var pas_x: float = 2.0 * demi.x / nb_x
	var pas_z: float = 2.0 * demi.z / nb_z

	var outil: SurfaceTool = SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in nb_x:
		for j: int in nb_z:
			var x0: float = -demi.x + i * pas_x
			var z0: float = -demi.z + j * pas_z
			_ajouter_carre(outil, x0, z0, x0 + pas_x, z0 + pas_z)
	# Les normales disent à la lumière de quel côté penche chaque pente :
	# c'est ce qui rend les dunes visibles.
	outil.generate_normals()
	mesh = outil.commit()

	var sable: ShaderMaterial = ShaderMaterial.new()
	sable.shader = SHADER_SABLE
	sable.set_shader_parameter("couleur_sable", couleur_sable)
	sable.set_shader_parameter("motif", _motif_reflets())
	material_override = sable
	_construire_horizon(sable)


# Motif des reflets : du bruit cellulaire de Godot. DISTANCE2_SUB vaut 0 sur le bord des cellules,
# là où deux points du motif sont à égale distance : ce sont ces bords qui deviennent les reflets.
# « seamless » : le motif se raccorde à lui-même, on peut le répéter sur tout le sol.
func _motif_reflets() -> NoiseTexture2D:
	var bruit: FastNoiseLite = FastNoiseLite.new()
	bruit.noise_type = FastNoiseLite.TYPE_CELLULAR
	bruit.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
	bruit.frequency = CELLULES_MOTIF / TAILLE_MOTIF
	var motif: NoiseTexture2D = NoiseTexture2D.new()
	motif.width = TAILLE_MOTIF
	motif.height = TAILLE_MOTIF
	motif.seamless = true
	motif.generate_mipmaps = true
	motif.noise = bruit
	return motif


# Le grand plan plat, centré sous l'aquarium. Le bord de la grille est à hauteur 0 :
# il se raccorde au plan sans marche visible.
func _construire_horizon(sable: Material) -> void:
	var plan: PlaneMesh = PlaneMesh.new()
	plan.size = Vector2(taille_horizon, taille_horizon)
	var horizon: MeshInstance3D = MeshInstance3D.new()
	horizon.mesh = plan
	horizon.material_override = sable
	horizon.position.y = -DECALAGE_HORIZON
	add_child(horizon)


# Hauteur du sable en (x, z), dans le repère de l'aquarium : c'est ce que les thons évitent.
func hauteur_sable(x: float, z: float) -> float:
	return position.y + _hauteur(x, z)


# Ajoute un carré de la grille, découpé en deux triangles.
# Vus de dessus, les sommets tournent dans le sens des aiguilles d'une montre :
# c'est ce sens qui indique à Godot que la face visible est celle du dessus.
func _ajouter_carre(outil: SurfaceTool, x0: float, z0: float, x1: float, z1: float) -> void:
	var a: Vector3 = _sommet(x0, z0)
	var b: Vector3 = _sommet(x1, z0)
	var c: Vector3 = _sommet(x1, z1)
	var d: Vector3 = _sommet(x0, z1)
	for sommet: Vector3 in [a, b, c, a, c, d]:
		outil.add_vertex(sommet)


# Le point du sol à la verticale de (x, z).
func _sommet(x: float, z: float) -> Vector3:
	return Vector3(x, _hauteur(x, z), z)


# Hauteur du sable en (x, z) : une vague dans la longueur plus une vague dans la profondeur.
func _hauteur(x: float, z: float) -> float:
	# TAU = un tour complet : la vague se répète tous les `espacement_dunes`.
	var vague_x: float = sin(x * TAU / espacement_dunes)
	var vague_z: float = sin(z * TAU / espacement_dunes)
	# La somme des deux vagues va de -2 à 2 : on la ramène entre 0 et 1.
	return hauteur_dunes * (vague_x + vague_z + 2.0) / 4.0 * _aplatissement(x, z)


# 1 au-dessus du fond de la boîte, puis descend en ligne droite jusqu'à 0
# à `etendue_dunes` des parois : les dunes rejoignent le sable plat en douceur.
func _aplatissement(x: float, z: float) -> float:
	var dehors: float = maxf(absf(x) - _demi.x, absf(z) - _demi.z)
	return clampf(1.0 - dehors / etendue_dunes, 0.0, 1.0)
