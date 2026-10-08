extends Node3D
class_name ModeleThon
## L'apparence du thon, construite par code : un corps fuselé, des nageoires,
## des yeux et une queue en croissant qui bat. Le thon regarde vers -Z.
##
## Les tailles sont données en « h », la demi-hauteur du corps à son point le plus épais,
## et les positions le long du corps en « t », de 0 (museau) à 1 (base de la queue).

## Longueur totale du thon, du museau au bout de la queue, en unités Godot.
@export var longueur: float = 2.0
## Couleur du dos.
@export var couleur_dos: Color = Color(0.08, 0.12, 0.3)
## Couleur du ventre.
@export var couleur_ventre: Color = Color(0.82, 0.85, 0.9)
## Couleur des nageoires, le jaune du logo.
@export var couleur_nageoires: Color = Color("#f2c230")
## Battements de queue par seconde.
@export var frequence_queue: float = 2.0
## Angle le plus grand de la queue de chaque côté, en degrés.
@export var amplitude_queue: float = 25.0

# Profil du corps vu de côté : (t, demi-hauteur en h). Pointu devant, épais au premier tiers,
# très fin juste avant la queue, comme un thon.
const PROFIL: Array[Vector2] = [
	Vector2(0.0, 0.0), Vector2(0.04, 0.35), Vector2(0.1, 0.62), Vector2(0.2, 0.86),
	Vector2(0.32, 1.0), Vector2(0.45, 0.97), Vector2(0.58, 0.8), Vector2(0.7, 0.52),
	Vector2(0.82, 0.25), Vector2(0.94, 0.12), Vector2(1.0, 0.0),
]
# Nombre de sommets sur le tour du corps.
const SEGMENTS: int = 16
# Demi-hauteur du corps, en part de la longueur totale.
const DEMI_HAUTEUR: float = 0.13
# Largeur du corps par rapport à sa hauteur : un thon est un peu aplati sur les côtés.
const LARGEUR: float = 0.75
# Part de la longueur occupée par le corps ; la queue occupe le reste.
const PART_CORPS: float = 0.8
# Nageoires du dessus et du dessous : (t début, t fin, hauteur en h, 1 dessus / -1 dessous).
const NAGEOIRES: Array[Vector4] = [
	Vector4(0.28, 0.42, 0.45, 1.0),  # première dorsale
	Vector4(0.52, 0.6, 0.7, 1.0),    # deuxième dorsale
	Vector4(0.52, 0.6, 0.7, -1.0),   # anale
]
# Pinnules : petites nageoires en rangée entre la dorsale et la queue, dessus et dessous.
const NB_PINNULES: int = 6
const DEBUT_PINNULES: float = 0.66
const FIN_PINNULES: float = 0.92
const HAUTEUR_PINNULE: float = 0.18
# Part de l'espace entre deux pinnules occupée par chacune.
const LONGUEUR_PINNULE: float = 0.6
# Nageoire pectorale droite (x > 0) : (x en h, y en h, t). La gauche en est le reflet.
const PECTORALE: Array[Vector3] = [Vector3(0.65, -0.2, 0.24), Vector3(0.65, -0.2, 0.3), Vector3(1.0, -0.35, 0.5)]
# Queue en croissant, vue de côté : (y en h, distance à la base en h).
const QUEUE: Array[Vector2] = [
	Vector2(0.12, 0.0), Vector2(1.3, 1.4), Vector2(0.0, 0.6), Vector2(-1.3, 1.4), Vector2(-0.12, 0.0),
]
# Œil : position (t, hauteur en h) et rayon en h.
const POSITION_OEIL: Vector2 = Vector2(0.09, 0.15)
const RAYON_OEIL: float = 0.09

# Demi-hauteur du corps, en unités Godot.
var _h: float
# Position du museau sur l'axe z, et longueur du corps sans la queue.
var _z_museau: float
var _longueur_corps: float
var _queue: Node3D
var _temps: float = 0.0


func _ready() -> void:
	_h = longueur * DEMI_HAUTEUR
	_z_museau = -longueur / 2.0
	_longueur_corps = longueur * PART_CORPS
	_construire_corps()
	_construire_queue()
	_construire_yeux()


# La queue bat de gauche à droite en suivant une sinusoïde.
func _process(delta: float) -> void:
	_temps += delta
	_queue.rotation.y = sin(_temps * TAU * frequence_queue) * deg_to_rad(amplitude_queue)


# Le corps et ses nageoires : deux surfaces d'un même maillage, chacune avec sa matière.
func _construire_corps() -> void:
	var corps: SurfaceTool = SurfaceTool.new()
	corps.begin(Mesh.PRIMITIVE_TRIANGLES)
	# On relie chaque anneau du profil au suivant par des carrés, coupés en deux triangles.
	for i: int in PROFIL.size() - 1:
		for j: int in SEGMENTS:
			for k: Vector2i in [Vector2i(i, j), Vector2i(i + 1, j), Vector2i(i + 1, j + 1),
					Vector2i(i, j), Vector2i(i + 1, j + 1), Vector2i(i, j + 1)]:
				_ajouter_sommet_corps(corps, k.x, k.y)
	corps.generate_normals()
	var maillage: ArrayMesh = corps.commit()

	var nageoires: SurfaceTool = SurfaceTool.new()
	nageoires.begin(Mesh.PRIMITIVE_TRIANGLES)
	for n: Vector4 in NAGEOIRES:
		_ajouter_nageoire(nageoires, n.x, n.y, n.z, n.w)
	var pas: float = (FIN_PINNULES - DEBUT_PINNULES) / NB_PINNULES
	for p: int in NB_PINNULES:
		var t: float = DEBUT_PINNULES + p * pas
		for cote: float in [1.0, -1.0]:
			_ajouter_nageoire(nageoires, t, t + pas * LONGUEUR_PINNULE, HAUTEUR_PINNULE, cote)
	for cote: float in [1.0, -1.0]:
		var sommets: Array[Vector3] = []
		for s: Vector3 in PECTORALE:
			sommets.append(Vector3(cote * s.x * _h, s.y * _h, _z(s.z)))
		_ajouter_triangle(nageoires, sommets[0], sommets[1], sommets[2])
	nageoires.commit(maillage)

	var peau: StandardMaterial3D = StandardMaterial3D.new()
	# La couleur vient de chaque sommet : bleu sur le dos, argent sous le ventre.
	peau.vertex_color_use_as_albedo = true
	peau.vertex_color_is_srgb = true
	# Rendu toon : la lumière tombe en aplats francs, comme sur le logo.
	peau.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	peau.specular_mode = BaseMaterial3D.SPECULAR_TOON
	maillage.surface_set_material(0, peau)
	maillage.surface_set_material(1, _matiere_nageoires())

	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = maillage
	add_child(instance)


# La queue est un nœud à part, placé à la base de la queue : c'est le point autour duquel elle bat.
func _construire_queue() -> void:
	var outil: SurfaceTool = SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points: Array[Vector3] = []
	for q: Vector2 in QUEUE:
		points.append(Vector3(0.0, q.x * _h, q.y * _h))
	# Trois triangles : lobe du haut, milieu, lobe du bas.
	_ajouter_triangle(outil, points[0], points[1], points[2])
	_ajouter_triangle(outil, points[0], points[2], points[4])
	_ajouter_triangle(outil, points[4], points[2], points[3])

	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = outil.commit()
	instance.material_override = _matiere_nageoires()
	_queue = Node3D.new()
	_queue.position.z = _z(1.0)
	_queue.add_child(instance)
	add_child(_queue)


func _construire_yeux() -> void:
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = RAYON_OEIL * _h
	sphere.height = 2.0 * sphere.radius
	var noir: StandardMaterial3D = StandardMaterial3D.new()
	noir.albedo_color = Color.BLACK
	sphere.material = noir
	var t: float = POSITION_OEIL.x
	for cote: float in [1.0, -1.0]:
		var oeil: MeshInstance3D = MeshInstance3D.new()
		oeil.mesh = sphere
		# Posé sur le flanc : à cette hauteur, le flanc est presque à la largeur maximale.
		oeil.position = Vector3(cote * LARGEUR * _rayon(t) * _h, POSITION_OEIL.y * _h, _z(t))
		add_child(oeil)


# Ajoute le sommet j de l'anneau i, avec sa couleur.
func _ajouter_sommet_corps(outil: SurfaceTool, i: int, j: int) -> void:
	var angle: float = TAU * j / SEGMENTS
	var rayon: float = PROFIL[i].y * _h
	# Sur le tour, le sommet passe du ventre (sinus à -1) au dos (sinus à 1).
	var dos: float = smoothstep(-0.3, 0.3, sin(angle))
	outil.set_color(couleur_ventre.lerp(couleur_dos, dos))
	outil.add_vertex(Vector3(cos(angle) * rayon * LARGEUR, sin(angle) * rayon, _z(PROFIL[i].x)))


# Nageoire triangulaire posée sur le dos (cote = 1) ou sous le ventre (cote = -1),
# de t_debut à t_fin, avec la pointe tirée vers l'arrière.
func _ajouter_nageoire(outil: SurfaceTool, t_debut: float, t_fin: float, hauteur: float, cote: float) -> void:
	var avant: Vector3 = Vector3(0.0, cote * _rayon(t_debut) * _h, _z(t_debut))
	var arriere: Vector3 = Vector3(0.0, cote * _rayon(t_fin) * _h, _z(t_fin))
	var pointe: Vector3 = Vector3(0.0, cote * (_rayon(t_fin) + hauteur) * _h, _z(t_fin + (t_fin - t_debut) / 2.0))
	_ajouter_triangle(outil, avant, pointe, arriere)


func _ajouter_triangle(outil: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	for sommet: Vector3 in [a, b, c]:
		outil.add_vertex(sommet)


# Nageoires vues des deux côtés : on désactive le masquage des faces arrière.
# Sans éclairage, elles gardent le jaune du logo même côté ombre, au lieu de virer au vert sombre.
func _matiere_nageoires() -> StandardMaterial3D:
	var matiere: StandardMaterial3D = StandardMaterial3D.new()
	matiere.albedo_color = couleur_nageoires
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
	return matiere


# Position sur l'axe z du point situé à t le long du corps.
func _z(t: float) -> float:
	return _z_museau + t * _longueur_corps


# Demi-hauteur du corps (en h) à t, lue dans le profil entre les deux points qui l'encadrent.
func _rayon(t: float) -> float:
	for i: int in PROFIL.size() - 1:
		if t <= PROFIL[i + 1].x:
			var part: float = (t - PROFIL[i].x) / (PROFIL[i + 1].x - PROFIL[i].x)
			return lerpf(PROFIL[i].y, PROFIL[i + 1].y, part)
	return 0.0
