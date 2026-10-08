extends Node3D
class_name CielVivant
## Le ciel de l'accueil prend vie : des nuages qui dérivent lentement et des mouettes
## qui le traversent en battant des ailes. Les deux reviennent par l'autre côté
## quand ils sortent de la scène.

## Nombre de nuages et de mouettes.
@export var nb_nuages: int = 8
@export var nb_mouettes: int = 3
## Vitesse de dérive des nuages et de vol des mouettes, en unités Godot par seconde.
@export var vitesse_nuages: float = 2.0
@export var vitesse_mouettes: float = 6.0
## Battements d'ailes par seconde.
@export var battements: float = 1.5
@export var couleur_nuages: Color = Color(0.98, 0.72, 0.62)
@export var couleur_mouettes: Color = Color(0.15, 0.12, 0.2)
@export var graine: int = 5

# Les nuages : demi-largeur de la bande où ils dérivent, distance (au plus près, au plus loin),
# hauteur (au plus bas, au plus haut), nombre de boules et taille d'une boule (au moins, au plus).
const BANDE_NUAGES: float = 300.0
const DISTANCE_NUAGES: Vector2 = Vector2(200.0, 350.0)
const HAUTEUR_NUAGES: Vector2 = Vector2(40.0, 90.0)
const BOULES: Vector2i = Vector2i(4, 6)
const TAILLE_BOULE: Vector2 = Vector2(10.0, 20.0)
# Une boule de nuage est écrasée en hauteur.
const APLATISSEMENT: float = 0.4
# Décalage d'une boule à la suivante, en largeur et en hauteur, en part de sa taille.
const ECART_BOULES: float = 0.6
const BOSSE_BOULES: float = 0.2
# Les mouettes : demi-largeur de leur trajet, distance, hauteur, envergure.
const BANDE_MOUETTES: float = 60.0
const DISTANCE_MOUETTES: Vector2 = Vector2(30.0, 50.0)
const HAUTEUR_MOUETTES: Vector2 = Vector2(8.0, 16.0)
const ENVERGURE: float = 5.0
# Angle des ailes au repos et ampleur du battement, en degrés.
const ANGLE_AILES: float = 15.0
const AMPLEUR_BATTEMENT: float = 25.0

var _hasard: RandomNumberGenerator = RandomNumberGenerator.new()
var _nuages: Array[Node3D] = []
var _mouettes: Array[Node3D] = []
# Pour chaque mouette : son aile gauche, son aile droite et son décalage dans le battement.
var _ailes: Array[Array] = []
var _phases: Array[float] = []
var _temps: float = 0.0


func _ready() -> void:
	_hasard.seed = graine
	for n: int in nb_nuages:
		_nuages.append(_nuage())
	for n: int in nb_mouettes:
		_mouettes.append(_mouette())


func _process(delta: float) -> void:
	_temps += delta
	for nuage: Node3D in _nuages:
		nuage.position.x = _avancer(nuage.position.x, vitesse_nuages * delta, BANDE_NUAGES)
	for i: int in _mouettes.size():
		_mouettes[i].position.x = _avancer(_mouettes[i].position.x, vitesse_mouettes * delta, BANDE_MOUETTES)
		var angle: float = deg_to_rad(ANGLE_AILES + AMPLEUR_BATTEMENT * sin(_temps * TAU * battements + _phases[i]))
		_ailes[i][0].rotation.z = angle
		_ailes[i][1].rotation.z = -angle


# Avance sur l'axe x et revient de l'autre côté une fois sorti de la bande [-bande, bande].
func _avancer(x: float, pas: float, bande: float) -> float:
	return wrapf(x + pas, -bande, bande)


# Un nuage : quelques boules aplaties, serrées les unes contre les autres.
func _nuage() -> Node3D:
	var nuage: Node3D = Node3D.new()
	var matiere: StandardMaterial3D = _matiere(couleur_nuages)
	for b: int in _hasard.randi_range(BOULES.x, BOULES.y):
		var taille: float = _hasard.randf_range(TAILLE_BOULE.x, TAILLE_BOULE.y)
		var boule: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = taille / 2.0
		sphere.height = taille * APLATISSEMENT
		boule.mesh = sphere
		boule.material_override = matiere
		# Chaque boule se décale un peu, surtout en largeur.
		boule.position = Vector3(b * taille * ECART_BOULES, _hasard.randf_range(0.0, taille * BOSSE_BOULES), 0.0)
		nuage.add_child(boule)
	nuage.position = Vector3(_hasard.randf_range(-BANDE_NUAGES, BANDE_NUAGES),
			_hasard.randf_range(HAUTEUR_NUAGES.x, HAUTEUR_NUAGES.y),
			-_hasard.randf_range(DISTANCE_NUAGES.x, DISTANCE_NUAGES.y))
	add_child(nuage)
	return nuage


# Une mouette : deux ailes en triangle, accrochées au corps, qui tournent en sens contraire.
func _mouette() -> Node3D:
	var mouette: Node3D = Node3D.new()
	var matiere: StandardMaterial3D = _matiere(couleur_mouettes)
	var ailes: Array[Node3D] = []
	for cote: float in [1.0, -1.0]:
		var aile: MeshInstance3D = MeshInstance3D.new()
		aile.mesh = _triangle(cote * ENVERGURE / 2.0)
		aile.material_override = matiere
		mouette.add_child(aile)
		ailes.append(aile)
	mouette.position = Vector3(_hasard.randf_range(-BANDE_MOUETTES, BANDE_MOUETTES),
			_hasard.randf_range(HAUTEUR_MOUETTES.x, HAUTEUR_MOUETTES.y),
			-_hasard.randf_range(DISTANCE_MOUETTES.x, DISTANCE_MOUETTES.y))
	add_child(mouette)
	_ailes.append(ailes)
	_phases.append(_hasard.randf_range(0.0, TAU))
	return mouette


# Une aile : un triangle plat qui part du corps (x = 0) jusqu'à la pointe (x = bout).
func _triangle(bout: float) -> ArrayMesh:
	var largeur: float = absf(bout) / 3.0
	var outil: SurfaceTool = SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	for sommet: Vector3 in [Vector3(0.0, 0.0, -largeur / 2.0), Vector3(bout, 0.0, 0.0), Vector3(0.0, 0.0, largeur / 2.0)]:
		outil.add_vertex(sommet)
	return outil.commit()


# Couleur unie, sans ombre, visible des deux côtés : des silhouettes de dessin animé.
func _matiere(couleur: Color) -> StandardMaterial3D:
	var matiere: StandardMaterial3D = StandardMaterial3D.new()
	matiere.albedo_color = couleur
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
	return matiere
