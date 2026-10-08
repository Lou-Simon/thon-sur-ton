extends Node3D
class_name Decor
## Le décor vivant : des massifs de plantes et de coraux dans l'aquarium, que le thon contourne,
## du décor autour de l'aquarium, qui ne gêne personne, des bulles qui montent et du plancton.
## Tout est tiré au hasard avec une graine fixe : le décor est le même à chaque lancement.

## Nombre de massifs dans l'aquarium.
@export var nb_massifs: int = 4
## Nombre d'éléments de décor autour de l'aquarium.
@export var nb_autour: int = 40
## Distance entre les parois et les massifs, et entre deux massifs, en unités Godot.
@export var marge_massifs: float = 4.0
@export var ecart_massifs: float = 8.0
## Distance, vue de dessus, entre le centre de l'aquarium (départ du thon) et les massifs.
@export var degagement_centre: float = 7.0
## Largeur de la bande autour de l'aquarium où l'on pose du décor.
@export var bande_autour: float = 20.0
## Nombre de bulles et de grains de plancton présents en même temps.
@export var nb_bulles: int = 40
@export var nb_plancton: int = 300
@export var graine: int = 11

# Rayon d'un massif : ses éléments sont posés à cette distance de son centre, au plus.
const RAYON_MASSIF: float = 3.0
# Épaisseur d'une algue pour les thons : sa largeur plus ce qu'elle ondule.
const RAYON_ALGUE: float = 1.0
# Nombre d'éléments de chaque sorte dans un massif : (au moins, au plus).
const ALGUES_PAR_MASSIF: Vector2i = Vector2i(3, 5)
const RONDS_PAR_MASSIF: Vector2i = Vector2i(1, 2)
const BRANCHUS_PAR_MASSIF: Vector2i = Vector2i(1, 2)
const HERBES_PAR_MASSIF: Vector2i = Vector2i(3, 6)
# Hauteur d'une algue et rayon d'un corail rond, en unités Godot : (au moins, au plus).
const HAUTEUR_ALGUE: Vector2 = Vector2(7.0, 12.0)
const RAYON_ROND: Vector2 = Vector2(0.8, 1.5)
# Bulles : vitesse de montée en unités Godot par seconde, à plus ou moins ECART_VITESSE près,
# rayon et variation de taille (au moins, au plus), couleur.
const VITESSE_BULLES: float = 2.0
const ECART_VITESSE: float = 0.25
const RAYON_BULLE: float = 0.12
const TAILLE_BULLES: Vector2 = Vector2(0.5, 1.5)
const COULEUR_BULLES: Color = Color(0.85, 0.95, 1.0, 0.5)
# Plancton : vitesse de dérive (au moins, au plus), durée de vie en secondes, taille, couleur.
const VITESSE_PLANCTON: Vector2 = Vector2(0.05, 0.2)
const DUREE_PLANCTON: float = 12.0
const TAILLE_GRAIN: float = 0.05
const COULEUR_PLANCTON: Color = Color(1.0, 1.0, 0.9, 0.6)

var _hasard: RandomNumberGenerator = RandomNumberGenerator.new()
var _sol: Sol
var _obstacles: Array[Obstacle] = []


# C'est l'aquarium qui appelle cette fonction : lui seul connaît ses dimensions et son sol.
func construire(dimensions: Vector3, sol: Sol) -> void:
	_hasard.seed = graine
	_sol = sol
	var demi: Vector3 = dimensions / 2.0
	for centre: Vector2 in _centres_massifs(demi):
		_massif(centre)
	for n: int in nb_autour:
		_element_autour(demi)
	_bulles(demi)
	_plancton(demi)


## Les obstacles que les thons doivent contourner : les plantes et coraux des massifs.
func obstacles() -> Array[Obstacle]:
	return _obstacles


# Centres des massifs, vus de dessus : tirés au hasard, en refusant ceux qui sont trop près
# d'une paroi, du centre ou d'un massif déjà placé. On s'arrête après un nombre d'essais.
func _centres_massifs(demi: Vector3) -> Array[Vector2]:
	var centres: Array[Vector2] = []
	var limite: Vector2 = Vector2(demi.x, demi.z) - Vector2.ONE * marge_massifs
	for essai: int in 1000:
		if centres.size() == nb_massifs:
			break
		var c: Vector2 = Vector2(_hasard.randf_range(-limite.x, limite.x), _hasard.randf_range(-limite.y, limite.y))
		if c.length() < degagement_centre:
			continue
		if centres.any(func(autre: Vector2) -> bool: return c.distance_to(autre) < ecart_massifs):
			continue
		centres.append(c)
	return centres


# Un massif : des algues, des coraux et des herbes autour d'un centre. Tous sont des obstacles,
# sauf les herbes, trop basses pour gêner.
func _massif(centre: Vector2) -> void:
	for n: int in _hasard.randi_range(ALGUES_PAR_MASSIF.x, ALGUES_PAR_MASSIF.y):
		var algue: Algue = _algue(_autour(centre))
		_obstacles.append(Obstacle.new(algue.position, algue.position + Vector3.UP * algue.hauteur, RAYON_ALGUE))
	for n: int in _hasard.randi_range(RONDS_PAR_MASSIF.x, RONDS_PAR_MASSIF.y):
		var rond: CorailRond = _corail_rond(_autour(centre))
		_obstacles.append(Obstacle.new(rond.position, rond.position, rond.rayon))
	for n: int in _hasard.randi_range(BRANCHUS_PAR_MASSIF.x, BRANCHUS_PAR_MASSIF.y):
		var branchu: CorailBranchu = _corail_branchu(_autour(centre))
		var milieu: Vector3 = branchu.position + Vector3.UP * branchu.taille() / 2.0
		_obstacles.append(Obstacle.new(milieu, milieu, branchu.taille() / 2.0))
	for n: int in _hasard.randi_range(HERBES_PAR_MASSIF.x, HERBES_PAR_MASSIF.y):
		_herbe(_autour(centre))


# Un élément au hasard dans la bande autour de l'aquarium : on tire dans le grand rectangle
# et on recommence tant que le point tombe dans l'aquarium.
func _element_autour(demi: Vector3) -> void:
	var exterieur: Vector2 = Vector2(demi.x, demi.z) + Vector2.ONE * bande_autour
	var p: Vector2 = Vector2.ZERO
	while absf(p.x) < demi.x + RAYON_MASSIF and absf(p.y) < demi.z + RAYON_MASSIF:
		p = Vector2(_hasard.randf_range(-exterieur.x, exterieur.x), _hasard.randf_range(-exterieur.y, exterieur.y))
	match _hasard.randi_range(0, 3):
		0: _algue(p)
		1: _corail_rond(p)
		2: _corail_branchu(p)
		3: _herbe(p)


# Un point au hasard dans le massif, à au plus RAYON_MASSIF de son centre.
func _autour(centre: Vector2) -> Vector2:
	var angle: float = _hasard.randf_range(0.0, TAU)
	return centre + Vector2(cos(angle), sin(angle)) * _hasard.randf_range(0.0, RAYON_MASSIF)


# Pose un élément sur le sable, à la verticale du point p (vu de dessus).
func _poser(element: Node3D, p: Vector2) -> void:
	element.position = Vector3(p.x, _sol.hauteur_sable(p.x, p.y), p.y)
	element.rotation.y = _hasard.randf_range(0.0, TAU)
	add_child(element)


func _algue(p: Vector2) -> Algue:
	var algue: Algue = Algue.new()
	algue.hauteur = _hasard.randf_range(HAUTEUR_ALGUE.x, HAUTEUR_ALGUE.y)
	algue.phase = _hasard.randf_range(0.0, TAU)
	_poser(algue, p)
	return algue


func _corail_rond(p: Vector2) -> CorailRond:
	var rond: CorailRond = CorailRond.new()
	rond.rayon = _hasard.randf_range(RAYON_ROND.x, RAYON_ROND.y)
	_poser(rond, p)
	return rond


func _corail_branchu(p: Vector2) -> CorailBranchu:
	var branchu: CorailBranchu = CorailBranchu.new()
	branchu.graine = _hasard.randi()
	_poser(branchu, p)
	return branchu


func _herbe(p: Vector2) -> void:
	var herbe: Herbe = Herbe.new()
	herbe.graine = _hasard.randi()
	_poser(herbe, p)


# Bulles : des particules de Godot qui naissent sur tout le fond et montent jusqu'en haut.
func _bulles(demi: Vector3) -> void:
	var processus: ParticleProcessMaterial = ParticleProcessMaterial.new()
	processus.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	processus.emission_box_extents = Vector3(demi.x, 0.0, demi.z)
	processus.direction = Vector3.UP
	processus.spread = 5.0
	processus.gravity = Vector3.ZERO
	processus.initial_velocity_min = VITESSE_BULLES * (1.0 - ECART_VITESSE)
	processus.initial_velocity_max = VITESSE_BULLES * (1.0 + ECART_VITESSE)
	processus.scale_min = TAILLE_BULLES.x
	processus.scale_max = TAILLE_BULLES.y
	var bulle: SphereMesh = SphereMesh.new()
	bulle.radius = RAYON_BULLE
	bulle.height = 2.0 * RAYON_BULLE
	var matiere: StandardMaterial3D = StandardMaterial3D.new()
	matiere.albedo_color = COULEUR_BULLES
	matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bulle.material = matiere
	# Durée de vie : le temps de monter du fond jusqu'en haut de l'aquarium.
	var particules: GPUParticles3D = _particules(nb_bulles, 2.0 * demi.y / VITESSE_BULLES, processus, bulle, demi)
	particules.position.y = -demi.y


# Plancton : de minuscules grains clairs qui dérivent lentement dans toute l'eau.
func _plancton(demi: Vector3) -> void:
	var processus: ParticleProcessMaterial = ParticleProcessMaterial.new()
	processus.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	processus.emission_box_extents = demi
	processus.spread = 180.0
	processus.gravity = Vector3.ZERO
	processus.initial_velocity_min = VITESSE_PLANCTON.x
	processus.initial_velocity_max = VITESSE_PLANCTON.y
	var grain: QuadMesh = QuadMesh.new()
	grain.size = Vector2.ONE * TAILLE_GRAIN
	var matiere: StandardMaterial3D = StandardMaterial3D.new()
	matiere.albedo_color = COULEUR_PLANCTON
	matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Le grain est un carré plat : il fait toujours face à la caméra.
	matiere.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	grain.material = matiere
	_particules(nb_plancton, DUREE_PLANCTON, processus, grain, demi)


# Un émetteur de particules déjà rempli au lancement, visible dans tout l'aquarium.
func _particules(nombre: int, duree: float, processus: ParticleProcessMaterial, forme: Mesh, demi: Vector3) -> GPUParticles3D:
	var particules: GPUParticles3D = GPUParticles3D.new()
	particules.amount = nombre
	particules.lifetime = duree
	# On simule `duree` secondes avant la première image : l'eau n'est jamais vide.
	particules.preprocess = duree
	particules.process_material = processus
	particules.draw_pass_1 = forme
	# Godot ne dessine les particules que si cette boîte est à l'écran : elle couvre tout l'aquarium.
	particules.visibility_aabb = AABB(-demi * 2.0, demi * 4.0)
	add_child(particules)
	return particules
