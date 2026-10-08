extends SceneTree
## Mesure sans fenêtre : charge l'aquarium, règle les poids de l'alignement et de la cohésion,
## laisse tourner, puis écrit une ligne de résultat. Sert à choisir les poids sur des chiffres.
## Ce script ne fait pas partie du jeu : rien ne l'appelle.
##
## À lancer depuis la racine du dépôt (les arguments après `--` sont facultatifs) :
##   godot --headless --path godot/ --fixed-fps 60 -s mesures/mesure_banc.gd -- pa=6 pc=1 graine=1 n=18000
## pa : poids de l'alignement, pc : poids de la cohésion, graine : graine du hasard,
## n : nombre de pas (18 000 pas = 5 minutes à 60 pas par seconde).
##
## Pour mesurer, il lit des variables internes de l'aquarium et du thon (`_banc`, `_decor`,
## `_sol`, `_vitesse`) : c'est un écart voulu à la convention, limité à ce script.

# Nombre de pas à la fin de la simulation sur lesquels on fait les moyennes : la dernière minute.
const PAS_FIN: int = 3600
# Distance entre deux centres sous laquelle on compte que deux thons se frôlent (un thon mesure 2).
const SEUIL_PROCHE: float = 1.0

var _aquarium: Aquarium
var _pas: int = 0
var _duree: int = 18000
var _poids_alignement: float = 6.0
var _poids_cohesion: float = 1.0
# Distance la plus faible entre deux thons, et nombre de pas où une paire est sous le seuil.
var _distance_min: float = INF
var _pas_proches: int = 0
# Nombre de fois où un thon est vu hors de la boîte, sous le sable ou dans un obstacle.
var _hors: int = 0
var _sous_sable: int = 0
var _dans_obstacle: int = 0
# Sommes sur la dernière minute, pour les moyennes.
var _somme_groupes: float = 0.0
var _somme_directions: float = 0.0
var _pas_un_seul_banc: int = 0
# Premier pas où tous les thons forment un seul groupe (-1 : jamais).
var _premier_banc: int = -1


func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("pa="):
			_poids_alignement = float(argument.trim_prefix("pa="))
		if argument.begins_with("pc="):
			_poids_cohesion = float(argument.trim_prefix("pc="))
		if argument.begins_with("graine="):
			seed(int(argument.trim_prefix("graine=")))
		if argument.begins_with("n="):
			_duree = int(argument.trim_prefix("n="))
	_aquarium = (load("res://aquarium/aquarium.tscn") as PackedScene).instantiate() as Aquarium
	root.add_child(_aquarium)


# Appelée à chaque pas de la physique. Rendre `true` arrête la simulation.
func _physics_process(_delta: float) -> bool:
	var banc: Array[Thon] = _aquarium._banc
	if _pas == 0:
		for thon: Thon in banc:
			thon.poids_alignement = _poids_alignement
			thon.poids_cohesion = _poids_cohesion
	_relever(banc)
	_pas += 1
	if _pas < _duree:
		return false
	_ecrire_resultat(banc.size())
	return true


# Relève les mesures d'un pas.
func _relever(banc: Array[Thon]) -> void:
	var demi: Vector3 = _aquarium.dimensions / 2.0
	var distance_pas: float = INF
	var somme_directions: Vector3 = Vector3.ZERO
	for i: int in banc.size():
		var point: Vector3 = banc[i].position
		if absf(point.x) > demi.x or absf(point.y) > demi.y or absf(point.z) > demi.z:
			_hors += 1
		if point.y < _aquarium._sol.hauteur_sable(point.x, point.z):
			_sous_sable += 1
		for obstacle: Obstacle in _aquarium._decor.obstacles():
			if obstacle.ecart(point).length() < obstacle.rayon:
				_dans_obstacle += 1
				break
		somme_directions += banc[i]._vitesse.normalized()
		for j: int in range(i + 1, banc.size()):
			distance_pas = minf(distance_pas, point.distance_to(banc[j].position))
	_distance_min = minf(_distance_min, distance_pas)
	if distance_pas < SEUIL_PROCHE:
		_pas_proches += 1
	var groupes: int = _compter_groupes(banc)
	if groupes == 1 and _premier_banc < 0:
		_premier_banc = _pas
	if _pas >= _duree - PAS_FIN:
		_somme_groupes += groupes
		# Longueur de la moyenne des directions : 1 si tous nagent dans le même sens, 0 dans le désordre.
		_somme_directions += somme_directions.length() / banc.size()
		if groupes == 1:
			_pas_un_seul_banc += 1


# Nombre de groupes : deux thons sont du même groupe s'ils sont à moins du rayon de vision
# l'un de l'autre, directement ou de proche en proche par d'autres thons.
func _compter_groupes(banc: Array[Thon]) -> int:
	var deja_vu: Array[bool] = []
	deja_vu.resize(banc.size())
	deja_vu.fill(false)
	var groupes: int = 0
	for depart: int in banc.size():
		if deja_vu[depart]:
			continue
		# Un thon pas encore vu ouvre un nouveau groupe : on parcourt tous ceux qu'il relie.
		groupes += 1
		deja_vu[depart] = true
		var a_visiter: Array[int] = [depart]
		while not a_visiter.is_empty():
			var i: int = a_visiter.pop_back()
			for j: int in banc.size():
				if not deja_vu[j] and banc[i].position.distance_to(banc[j].position) < banc[i].rayon_vision:
					deja_vu[j] = true
					a_visiter.append(j)
	return groupes


func _ecrire_resultat(nombre_thons: int) -> void:
	var moyenne_sur: float = float(mini(PAS_FIN, _duree))
	print("pa=%s pc=%s thons=%d | groupes=%.2f un_seul_banc=%d%% directions=%.2f premier_banc=%s | distance_min=%.2f pas_proches=%d | hors=%d sous_sable=%d dans_obstacle=%d" % [
		_poids_alignement, _poids_cohesion, nombre_thons,
		_somme_groupes / moyenne_sur, roundi(100.0 * _pas_un_seul_banc / moyenne_sur),
		_somme_directions / moyenne_sur,
		("%.0f s" % (_premier_banc / 60.0)) if _premier_banc >= 0 else "jamais",
		_distance_min, _pas_proches, _hors, _sous_sable, _dans_obstacle])
