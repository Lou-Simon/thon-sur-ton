extends Node3D
class_name Sauts
## Des thons qui sautent hors de la mer, de temps en temps, au loin.
## Un seul thon sert à tous les sauts : il attend sous l'eau, jaillit avec une vitesse
## de départ, puis la gravité courbe sa trajectoire en arc jusqu'à ce qu'il replonge.
## Une gerbe d'écume marque sa sortie et son entrée dans l'eau.

## Attente entre deux sauts, en secondes (au moins, au plus).
@export var attente_min: float = 2.0
@export var attente_max: float = 4.5
## Distance du saut devant la caméra, en unités Godot (au plus près, au plus loin).
@export var distance_min: float = 18.0
@export var distance_max: float = 32.0
## Largeur de la bande où les thons peuvent sauter, de gauche à droite.
@export var largeur: float = 30.0
## Vitesse de départ, vers le haut et vers l'avant, en unités Godot par seconde.
@export var elan_vertical: float = 7.0
@export var elan_avant: float = 6.0
## Gravité, en unités Godot par seconde au carré.
@export var gravite: float = 9.8
## Taille du thon par rapport au modèle de la simulation.
@export var echelle: float = 1.5
@export var graine: int = 3

# Profondeur sous la surface d'où part le thon et où il disparaît.
const PROFONDEUR: float = 1.0
# Gerbe d'écume : nombre de gouttes, durée de vie, rayon d'une goutte, vitesse (au moins, au plus).
const GOUTTES: int = 24
const DUREE_GERBE: float = 1.0
const RAYON_GOUTTE: float = 0.12
const VITESSE_GOUTTES: Vector2 = Vector2(3.0, 6.0)

var _hasard: RandomNumberGenerator = RandomNumberGenerator.new()
var _thon: ModeleThon
var _gerbe: GPUParticles3D
var _vitesse: Vector3
var _en_vol: bool = false
var _attente: float


func _ready() -> void:
	_hasard.seed = graine
	_thon = ModeleThon.new()
	_thon.scale = Vector3.ONE * echelle
	_thon.visible = false
	add_child(_thon)
	_gerbe = _creer_gerbe()
	_attente = _hasard.randf_range(attente_min, attente_max)


func _process(delta: float) -> void:
	if not _en_vol:
		_attente -= delta
		if _attente <= 0.0:
			_sauter()
		return
	# Chute libre : la gravité diminue la vitesse verticale, la position suit la vitesse.
	_vitesse.y -= gravite * delta
	_thon.position += _vitesse * delta
	_thon.look_at(_thon.global_position + _vitesse)
	if _thon.position.y < -PROFONDEUR and _vitesse.y < 0.0:
		_en_vol = false
		_thon.visible = false
		_eclabousser(_thon.position)
		_attente = _hasard.randf_range(attente_min, attente_max)


# Le thon part sous l'eau, à un endroit tiré au hasard, vers la gauche ou vers la droite.
func _sauter() -> void:
	var sens: float = 1.0 if _hasard.randf() < 0.5 else -1.0
	_thon.position = Vector3(_hasard.randf_range(-largeur, largeur) / 2.0, -PROFONDEUR,
			-_hasard.randf_range(distance_min, distance_max))
	_vitesse = Vector3(sens * elan_avant, elan_vertical, 0.0)
	_thon.visible = true
	_en_vol = true
	_eclabousser(_thon.position)


# Relance la gerbe d'écume à la surface, à la verticale du point donné.
func _eclabousser(point: Vector3) -> void:
	_gerbe.position = Vector3(point.x, 0.0, point.z)
	_gerbe.restart()


# Une gerbe : des gouttes lancées toutes ensemble vers le haut, que la gravité fait retomber.
func _creer_gerbe() -> GPUParticles3D:
	var processus: ParticleProcessMaterial = ParticleProcessMaterial.new()
	processus.direction = Vector3.UP
	processus.spread = 35.0
	processus.initial_velocity_min = VITESSE_GOUTTES.x
	processus.initial_velocity_max = VITESSE_GOUTTES.y
	processus.gravity = Vector3.DOWN * gravite
	var goutte: SphereMesh = SphereMesh.new()
	goutte.radius = RAYON_GOUTTE
	goutte.height = 2.0 * RAYON_GOUTTE
	var ecume: StandardMaterial3D = StandardMaterial3D.new()
	ecume.albedo_color = Color.WHITE
	ecume.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	goutte.material = ecume
	var gerbe: GPUParticles3D = GPUParticles3D.new()
	gerbe.amount = GOUTTES
	gerbe.lifetime = DUREE_GERBE
	gerbe.one_shot = true
	gerbe.emitting = false
	# Toutes les gouttes partent au même instant.
	gerbe.explosiveness = 1.0
	gerbe.process_material = processus
	gerbe.draw_pass_1 = goutte
	add_child(gerbe)
	return gerbe
