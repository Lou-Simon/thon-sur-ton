extends Node3D
class_name CorailBranchu
## Un corail branchu : un tronc qui se divise en branches, qui se divisent à leur tour.
## Chaque branche est un cylindre, enfant de la branche dont elle part : elle suit sa direction,
## puis s'écarte d'un angle tiré au hasard.

## Longueur du tronc, en unités Godot ; chaque génération de branches est plus courte.
@export var longueur: float = 1.6
## Épaisseur du tronc.
@export var epaisseur: float = 0.18
## Nombre de divisions successives.
@export var generations: int = 3
## Couleur du corail.
@export var couleur: Color = Color(1.0, 0.55, 0.25)
## Graine du tirage au hasard : chaque corail a la sienne.
@export var graine: int = 0

# D'une génération à la suivante, la longueur et l'épaisseur sont multipliées par ces facteurs.
const REDUCTION_LONGUEUR: float = 0.75
const REDUCTION_EPAISSEUR: float = 0.65
# Écart d'une branche par rapport à celle dont elle part, en degrés.
const ECART_MIN: float = 25.0
const ECART_MAX: float = 45.0
# Désordre dans la répartition des branches autour de l'axe, en radians.
const DESORDRE: float = 0.5

var _hasard: RandomNumberGenerator = RandomNumberGenerator.new()
var _matiere: StandardMaterial3D


func _ready() -> void:
	_hasard.seed = graine
	_matiere = StandardMaterial3D.new()
	_matiere.albedo_color = couleur
	_matiere.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	_matiere.specular_mode = BaseMaterial3D.SPECULAR_TOON
	_branche(self, longueur, epaisseur, generations)


# Ajoute une branche au bout de `parent`, puis 2 ou 3 branches plus petites au bout de celle-ci.
# La fonction s'appelle elle-même jusqu'à la dernière génération.
func _branche(parent: Node3D, l: float, e: float, reste: int) -> void:
	var cylindre: CylinderMesh = CylinderMesh.new()
	cylindre.height = l
	cylindre.bottom_radius = e
	cylindre.top_radius = e * REDUCTION_EPAISSEUR
	var morceau: MeshInstance3D = MeshInstance3D.new()
	morceau.mesh = cylindre
	morceau.material_override = _matiere
	# Le cylindre de Godot est centré : on le remonte pour que la branche parte de son pied.
	morceau.position.y = l / 2.0
	parent.add_child(morceau)
	if reste == 0:
		return
	var nb: int = _hasard.randi_range(2, 3)
	for n: int in nb:
		var suite: Node3D = Node3D.new()
		suite.position.y = l
		# Les branches se répartissent autour de l'axe, puis s'en écartent.
		suite.rotation.y = TAU * n / nb + _hasard.randf_range(-DESORDRE, DESORDRE)
		suite.rotate_object_local(Vector3.RIGHT, deg_to_rad(_hasard.randf_range(ECART_MIN, ECART_MAX)))
		parent.add_child(suite)
		_branche(suite, l * REDUCTION_LONGUEUR, e * REDUCTION_EPAISSEUR, reste - 1)


## Hauteur que le corail atteindrait si toutes ses branches montaient tout droit :
## la somme des longueurs d'une génération à l'autre. Le vrai corail est un peu moins haut.
func taille() -> float:
	var total: float = 0.0
	var l: float = longueur
	for g: int in generations + 1:
		total += l
		l *= REDUCTION_LONGUEUR
	return total
