extends MeshInstance3D
class_name Rocher
## Le rocher posé sur le sable, sur le chemin du banc : long et bas, couché dans le sens
## de la longueur de l'aquarium (l'axe x).
##
## Pour les thons, c'est un obstacle comme une algue : un segment entouré d'une épaisseur
## (une capsule), qu'ils contournent avec la même force. Ici le segment est couché.
## Chaque thon ne le sent qu'une fois à portée : aucun ne connaît sa forme entière,
## ni le chemin pour le contourner.
##
## À l'écran, c'est cette capsule aplatie et cabossée : chaque sommet est rentré vers l'axe
## d'une quantité tirée d'un bruit. La forme dessinée reste donc dans la capsule,
## et un thon qui évite la capsule ne traverse jamais le rocher.

## Rayon de la capsule, en unités Godot.
@export var rayon: float = 3.5
## Longueur du segment couché : le rocher mesure cette longueur plus deux rayons.
@export var longueur: float = 6.0
## Hauteur du segment au-dessus du sable : le bas de la capsule est enfoui.
@export var hauteur: float = 0.5
## Couleur du rocher.
@export var couleur: Color = Color(0.45, 0.42, 0.4)
@export var graine: int = 7

# Nombre de sommets sur un tour, et d'anneaux sur chaque bout arrondi puis sur le flanc.
# Peu de sommets : les faces restent visibles, comme un rocher taillé à la main.
const SEGMENTS: int = 16
const ANNEAUX_BOUT: int = 5
const ANNEAUX_FLANC: int = 6
# Hauteur du rocher dessiné par rapport à sa largeur : il est plus plat que la capsule.
const APLATISSEMENT: float = 0.8
# Part du rayon dont un sommet peut rentrer, et taille des bosses (fréquence du bruit).
const CREUX: float = 0.25
const FREQUENCE_BOSSES: float = 0.35

var _bruit: FastNoiseLite = FastNoiseLite.new()


# C'est l'aquarium qui appelle cette fonction : le rocher se pose sur le sable, à la verticale
# de la position donnée dans la scène.
func construire(sol: Sol) -> void:
	position.y = sol.hauteur_sable(position.x, position.z)
	_bruit.seed = graine
	_bruit.frequency = FREQUENCE_BOSSES
	# On parcourt la capsule d'un bout à l'autre : bout arrondi, flanc, bout arrondi.
	# `latitude` va de -PI / 2 (pointe du bout gauche) à PI / 2 (pointe du bout droit).
	var demi: float = longueur / 2.0
	var anneaux: Array[PackedVector3Array] = []
	for i: int in ANNEAUX_BOUT:
		anneaux.append(_anneau(-demi, -PI / 2.0 + PI / 2.0 * i / ANNEAUX_BOUT))
	for i: int in ANNEAUX_FLANC + 1:
		anneaux.append(_anneau(lerpf(-demi, demi, float(i) / ANNEAUX_FLANC), 0.0))
	for i: int in range(1, ANNEAUX_BOUT + 1):
		anneaux.append(_anneau(demi, PI / 2.0 * i / ANNEAUX_BOUT))
	var outil: SurfaceTool = SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in anneaux.size() - 1:
		for j: int in SEGMENTS:
			var suivant: int = (j + 1) % SEGMENTS
			for sommet: Vector3 in [anneaux[i][j], anneaux[i + 1][suivant], anneaux[i + 1][j],
					anneaux[i][j], anneaux[i][suivant], anneaux[i + 1][suivant]]:
				outil.add_vertex(sommet)
	outil.generate_normals()
	mesh = outil.commit()
	var matiere: StandardMaterial3D = StandardMaterial3D.new()
	matiere.albedo_color = couleur
	matiere.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	matiere.specular_mode = BaseMaterial3D.SPECULAR_TOON
	material_override = matiere


## L'obstacle que les thons contournent, dans le repère de l'aquarium (le parent du rocher).
func obstacle() -> Obstacle:
	var centre: Vector3 = position + Vector3.UP * hauteur
	var demi: Vector3 = Vector3.RIGHT * longueur / 2.0
	return Obstacle.new(centre - demi, centre + demi, rayon)


# Un anneau de sommets autour du segment, centré au point x du segment. `latitude` vaut 0 sur
# le flanc ; vers ±PI / 2, l'anneau avance sur la demi-sphère du bout et rétrécit.
func _anneau(x: float, latitude: float) -> PackedVector3Array:
	var anneau: PackedVector3Array = []
	var axe: Vector3 = Vector3(x, hauteur, 0.0)
	for j: int in SEGMENTS:
		var tour: float = TAU * j / SEGMENTS
		var direction: Vector3 = Vector3(sin(latitude), cos(latitude) * sin(tour), cos(latitude) * cos(tour))
		# Le bruit vaut entre -1 et 1 : on le ramène entre 0 et 1, et le sommet ne fait que rentrer.
		var creux: float = CREUX * (_bruit.get_noise_3dv(axe + direction * rayon) + 1.0) / 2.0
		direction.y *= APLATISSEMENT
		anneau.append(axe + direction * rayon * (1.0 - creux))
	return anneau
