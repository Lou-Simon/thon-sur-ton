extends Node3D
## Le tournage du trailer : lance le jeu sans personne aux commandes, enchaîne des plans de caméra
## écrits à l'avance, puis quitte. Le mode Movie Maker de Godot enregistre la vidéo.
## Cette scène ne fait pas partie du jeu : rien ne l'appelle.
##
## À lancer depuis la racine du dépôt avec `sh godot/tournage/tourner.sh` (voir ce script).
## Movie Maker calcule chaque image comme si le jeu tournait à 60 images par seconde, quel que soit
## le temps de calcul : la vidéo est fluide même si la fenêtre rame. Ne pas toucher à la souris ni
## au clavier pendant l'enregistrement.
## Au début de chaque plan, une ligne donne son temps dans la vidéo : ce sont les repères du montage.
##
## Pour filmer, il lit des variables internes du jeu (`_accueil`, `_aquarium`, `_banc`, `_requin`,
## `_rocher`, `_sol`, `_chasse`) : c'est un écart voulu à la convention, limité à ce script,
## comme dans les mesures.

const SCENE_JEU: PackedScene = preload("res://jeu/jeu.tscn")

# Les plans, dans l'ordre. `camera` : comment la caméra filme (voir `_viser`). `duree` : durée du plan
# dans la vidéo, en secondes. `attente` : le plan ne commence qu'au bon moment (voir `_pret`) ; en
# attendant, la caméra tourne autour du banc (un plan large qu'on peut toujours monter). `ralenti` : vitesse du temps pendant le plan (1 : normale).
const PLANS: Array[Dictionary] = [
	{nom = "Accueil", camera = &"accueil", duree = 10.0},
	{nom = "Plongée", camera = &"plongee", duree = 9.5},
	{nom = "Le banc", camera = &"orbite", duree = 12.0},
	{nom = "Caméra embarquée", camera = &"embarquee", duree = 10.0},
	{nom = "Le rocher", camera = &"rocher", duree = 15.0, attente = &"banc_au_rocher"},
	{nom = "L'ombre", camera = &"ombre", duree = 8.0},
	{nom = "La charge", camera = &"requin", duree = 12.0, attente = &"chasse"},
	{nom = "Le banc éclate", camera = &"cote", duree = 12.0, ralenti = 0.3, attente = &"requin_au_banc"},
	{nom = "Le banc se reforme", camera = &"orbite", duree = 15.0},
]

# Taille de base du jeu (celle de Godot par défaut : project.godot ne la change pas), en pixels.
const TAILLE_JEU: Vector2i = Vector2i(1152, 648)

# Valeurs proposées par Claude, à régler en regardant les rushes.
# Temps d'attente le plus long d'un plan, en secondes : passé ce temps, il commence quand même.
const ATTENTE_MAX: float = 40.0
# Champ de vision, en degrés : un peu plus serré que celui du jeu, l'image fait plus « cinéma ».
const CHAMP: float = 55.0
# Rapidité avec laquelle la caméra rejoint sa place (comme `douceur` dans camera.gd).
const DOUCEUR: float = 3.0
# Orbite autour du banc : distance, hauteur au-dessus de son centre, vitesse en radians par seconde.
const ORBITE: Vector3 = Vector3(16.0, 4.0, 0.15)
# Caméra embarquée derrière un thon, et caméra derrière le requin : recul, hauteur, distance du point regardé devant lui.
const EMBARQUEE: Vector3 = Vector3(3.0, 0.8, 6.0)
const DERRIERE_REQUIN: Vector3 = Vector3(7.0, 2.5, 6.0)
# Rapidité avec laquelle la caméra qui suit un poisson prend sa direction : faible, elle ne suit pas
# chaque coup de tête du poisson, elle prend sa direction moyenne.
const DOUCEUR_CAP: float = 0.8
# Caméra fixe face au rocher : décalage depuis le pied du rocher, et hauteur du haut du rocher.
# Elle regarde entre le haut du rocher et le banc, qui nage au-dessus : on voit les deux.
const FACE_ROCHER: Vector3 = Vector3(0.0, 3.0, 14.0)
const HAUTEUR_REGARD_ROCHER: float = 2.0
# Caméra posée sur le sable devant le requin, qui le regarde passer au-dessus : avance devant lui,
# décalage sur le côté (pour ne jamais regarder à la verticale exacte), hauteur au-dessus du sable.
const OMBRE: Vector3 = Vector3(8.0, 3.0, 0.8)
# Caméra sur le côté de la charge, et distance au rocher ou au banc sous laquelle on dit « arrivé ».
const COTE: Vector2 = Vector2(9.0, 2.0)
const PROCHE: float = 10.0

var _jeu: Plongee
var _aquarium: Aquarium
var _camera: Camera3D = Camera3D.new()
# Plan en cours, temps passé dans ce plan et depuis le début de la vidéo, en secondes de vidéo.
var _plan: int = 0
var _temps_plan: float = 0.0
var _temps_video: float = 0.0
# Vrai au premier pas d'un plan : la caméra saute à sa place (une coupe) au lieu d'y glisser.
var _coupe: bool = true
# Vrai quand le plan est fini mais que le suivant attend son moment.
var _attente: bool = false
# Direction adoucie du poisson que la caméra suit.
var _cap: Vector3
var _angle_orbite: float = 0.0
# Place de la caméra quand elle est fixe pendant tout un plan (rocher, ombre).
var _point_fixe: Vector3
# Là où la caméra regarde, adouci comme sa position.
var _regard: Vector3


func _ready() -> void:
	# Une fenêtre cachée derrière une autre n'est plus dessinée : Movie Maker répéterait la dernière image.
	get_window().always_on_top = true
	# `tourner.sh` filme en 1920 × 1080 : on garde la taille de base du jeu pour l'interface
	# (titre, boutons), qui s'agrandit alors dans les mêmes proportions qu'à l'écran.
	get_window().content_scale_size = TAILLE_JEU
	seed(_graine())
	_jeu = SCENE_JEU.instantiate() as Plongee
	add_child(_jeu)
	_aquarium = _jeu._aquarium
	_camera.fov = CHAMP
	# La caméra du tournage filme sous l'eau : elle prend l'ambiance de la caméra de l'aquarium.
	_camera.environment = _aquarium.camera().environment
	add_child(_camera)
	_commencer(0)


func _process(delta: float) -> void:
	# `delta` est ralenti avec le temps : on le remet en secondes de vidéo.
	var reel: float = delta / Engine.time_scale
	_temps_video += reel
	_temps_plan += reel
	if _temps_plan >= PLANS[_plan].duree:
		if _plan + 1 == PLANS.size():
			get_tree().quit()
			return
		var suivant: Dictionary = PLANS[_plan + 1]
		if _pret(suivant.get("attente", &"")) or _temps_plan >= PLANS[_plan].duree + ATTENTE_MAX:
			_commencer(_plan + 1)
		elif not _attente:
			_attente = true
			_coupe = true
			Engine.time_scale = 1.0
			print("%6.1f s  (attente : plan large du banc)" % _temps_video)
	_filmer(&"orbite" if _attente else PLANS[_plan].camera, reel)


func _commencer(numero: int) -> void:
	_plan = numero
	_temps_plan = 0.0
	_coupe = true
	_attente = false
	var plan: Dictionary = PLANS[numero]
	Engine.time_scale = plan.get("ralenti", 1.0)
	print("%6.1f s  %s" % [_temps_video, plan.nom])
	match plan.camera:
		&"accueil":
			pass
		&"plongee":
			# Comme un clic sur « Plonger » : c'est la plongée du jeu qui filme.
			_jeu._accueil.plonger_demande.emit()
		_:
			# Sous l'eau, la caméra du tournage prend la main : plus de panneau, plus de commandes.
			_aquarium.activer(false)
			_camera.make_current()


# Vrai quand le moment attendu par un plan est arrivé.
func _pret(attente: StringName) -> bool:
	var requin: Requin = _aquarium._requin
	match attente:
		&"banc_au_rocher":
			# Le rocher est posé sur le sable et le banc nage au-dessus : on ne compte que l'écart à l'horizontale.
			var ecart: Vector3 = _centre_banc() - _aquarium._rocher.global_position
			return Vector2(ecart.x, ecart.z).length() < PROCHE
		&"chasse":
			return requin._chasse > 0.0
		&"requin_au_banc":
			return requin._chasse > 0.0 and requin.global_position.distance_to(_centre_banc()) < PROCHE
	return true


# Place la caméra pour ce pas : elle glisse vers sa place, sauf au premier pas du plan.
func _filmer(camera: StringName, reel: float) -> void:
	if camera == &"accueil" or camera == &"plongee":
		return
	var vise: Array[Vector3] = _viser(camera, reel)
	var part: float = 1.0 if _coupe else 1.0 - exp(-DOUCEUR * reel)
	_coupe = false
	_regard = _regard.lerp(vise[1], part)
	_camera.look_at_from_position(_camera.global_position.lerp(vise[0], part), _regard)


# Où la caméra veut être, et ce qu'elle veut regarder.
func _viser(camera: StringName, reel: float) -> Array[Vector3]:
	var centre: Vector3 = _centre_banc()
	var requin: Requin = _aquarium._requin
	match camera:
		&"orbite":
			_angle_orbite += ORBITE.z * reel
			var autour: Vector3 = Vector3(sin(_angle_orbite), 0.0, cos(_angle_orbite)) * ORBITE.x
			return [centre + autour + Vector3.UP * ORBITE.y, centre]
		&"embarquee":
			return _derriere(_aquarium._banc[0], EMBARQUEE, reel)
		&"requin":
			return _derriere(requin, DERRIERE_REQUIN, reel)
		&"rocher":
			var pied: Vector3 = _aquarium._rocher.global_position
			if _coupe:
				_point_fixe = pied + FACE_ROCHER
			return [_point_fixe, (pied + Vector3.UP * HAUTEUR_REGARD_ROCHER).lerp(centre, 0.5)]
		&"ombre":
			if _coupe:
				_point_fixe = _sur_le_sable(requin, OMBRE)
			return [_point_fixe, requin.global_position]
		&"cote":
			# Au milieu entre le requin et le banc, vu de côté : on voit la charge et le banc qui s'ouvre.
			var milieu: Vector3 = (requin.global_position + centre) / 2.0
			var cote: Vector3 = (centre - requin.global_position).cross(Vector3.UP).normalized()
			return [milieu + cote * COTE.x + Vector3.UP * COTE.y, milieu]
	return [_camera.global_position, _regard]


# Une place derrière un poisson, et un point devant lui, le long de sa direction adoucie.
# Le modèle regarde vers -Z (voir thon.gd). `reglage` : recul, hauteur, distance du point regardé.
func _derriere(poisson: Node3D, reglage: Vector3, reel: float) -> Array[Vector3]:
	var avant: Vector3 = -poisson.global_basis.z
	_cap = avant if _coupe else _cap.lerp(avant, 1.0 - exp(-DOUCEUR_CAP * reel)).normalized()
	var lieu: Vector3 = poisson.global_position
	return [lieu - _cap * reglage.x + Vector3.UP * reglage.y, lieu + _cap * reglage.z]


# Un point posé sur le sable, devant le poisson et un peu sur le côté, dans l'aquarium.
# `reglage` : avance devant lui, décalage sur le côté, hauteur au-dessus du sable.
func _sur_le_sable(poisson: Node3D, reglage: Vector3) -> Vector3:
	var avant: Vector3 = -poisson.global_basis.z
	var cote: Vector3 = avant.cross(Vector3.UP).normalized()
	var point: Vector3 = poisson.global_position + avant * reglage.x + cote * reglage.y
	# On reste dans l'aquarium, à 1 des parois : le sable n'est calculé qu'à l'intérieur.
	var demi: Vector3 = _aquarium.dimensions / 2.0 - Vector3.ONE
	point.x = clampf(point.x, -demi.x, demi.x)
	point.z = clampf(point.z, -demi.z, demi.z)
	point.y = _aquarium._sol.hauteur_sable(point.x, point.z) + reglage.z
	return point


# Le centre du banc : la moyenne des positions des thons.
func _centre_banc() -> Vector3:
	var somme: Vector3 = Vector3.ZERO
	for thon: Thon in _aquarium._banc:
		somme += thon.global_position
	return somme / _aquarium._banc.size()


# La graine du hasard, lue après `--` sur la ligne de commande (`graine=2`) ; 1 sinon.
func _graine() -> int:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("graine="):
			return argument.trim_prefix("graine=").to_int()
	return 1
