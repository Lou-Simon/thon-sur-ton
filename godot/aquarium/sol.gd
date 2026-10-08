extends MeshInstance3D
class_name Sol
## Le sol de sable : une grille de petits carrés posée au fond de l'aquarium,
## dont chaque sommet est remonté pour former des dunes.

## Hauteur d'une dune, du creux à la crête, en unités Godot.
@export var hauteur_dunes: float = 0.6
## Distance entre deux crêtes voisines, en unités Godot.
@export var espacement_dunes: float = 8.0
## Côté d'un carré de la grille : plus il est petit, plus les dunes sont lisses.
@export var taille_maille: float = 0.5
## Couleur du sable.
@export var couleur_sable: Color = Color(0.85, 0.75, 0.55)


# Construit le sol au fond d'une boîte de la taille donnée.
# C'est l'aquarium qui appelle cette fonction : lui seul connaît les dimensions.
func construire(dimensions: Vector3) -> void:
	var demi: Vector3 = dimensions / 2.0
	# Le creux des dunes est exactement au fond de la boîte : le sable ne passe jamais dessous.
	position.y = -demi.y
	# Nombre de carrés sur chaque axe, arrondi au-dessus pour couvrir tout le fond.
	var nb_x: int = ceili(dimensions.x / taille_maille)
	var nb_z: int = ceili(dimensions.z / taille_maille)
	var pas_x: float = dimensions.x / nb_x
	var pas_z: float = dimensions.z / nb_z

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

	var sable: StandardMaterial3D = StandardMaterial3D.new()
	sable.albedo_color = couleur_sable
	material_override = sable


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
	return hauteur_dunes * (vague_x + vague_z + 2.0) / 4.0
