extends SceneTree
## Mesure sans fenêtre : charge l'aquarium, règle le nombre de thons, le rayon de vision et les poids
## de la séparation, de l'alignement et de la cohésion, laisse tourner, puis écrit une ligne de résultat.
## Sert à choisir les réglages sur des chiffres.
## Ce script ne fait pas partie du jeu : rien ne l'appelle.
##
## À lancer depuis la racine du dépôt (les arguments après `--` sont facultatifs) :
##   godot --headless --path godot/ --fixed-fps 60 -s mesures/mesure_banc.gd -- pa=6 pc=1 graine=1 n=18000
## pa : poids de l'alignement, pc : poids de la cohésion, ps : poids de la séparation,
## rv : rayon de vision, thons : nombre de thons, hr : hauteur du segment du rocher au-dessus du sable, rocher=0 : les thons ne sentent plus le rocher
## (pour comparer, à la même place, avec et sans lui), graine : graine du hasard,
## n : nombre de pas (18 000 pas = 5 minutes à 60 pas par seconde).
## Sans argument, les valeurs sont celles du jeu.
##
## Pour mesurer, il lit des variables internes de l'aquarium et du thon (`_banc`, `_decor`,
## `_rocher`, `_obstacles`, `_sol`, `_vitesse`) : c'est un écart voulu à la convention, limité à ce script.

# Nombre de pas à la fin de la simulation sur lesquels on fait les moyennes : la dernière minute.
const PAS_FIN: int = 3600
# Distance entre deux centres sous laquelle on compte que deux thons se frôlent (un thon mesure 2).
const SEUIL_PROCHE: float = 1.0
# Nombre de thons qu'il faut de chaque côté du rocher pour dire que le banc passe des deux côtés.
const MIN_COTE: int = 3

var _aquarium: Aquarium
var _pas: int = 0
var _duree: int = 18000
# Réglages demandés en argument ; NAN ou -1 : on garde la valeur du jeu.
var _poids_alignement: float = NAN
var _poids_cohesion: float = NAN
var _poids_separation: float = NAN
var _rayon_vision: float = NAN
var _nombre_thons: int = -1
var _sans_rocher: bool = false
var _hauteur_rocher: float = NAN
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
# Somme, sur la dernière minute, de la distance moyenne d'un thon à son plus proche voisin.
var _somme_plus_proche: float = 0.0
# Vitesse de chaque thon au pas précédent, et somme sur la dernière minute de l'angle moyen
# dont un thon tourne en un pas : une nage nerveuse tourne beaucoup.
var _vitesses_avant: Array[Vector3] = []
var _somme_virage: float = 0.0
# Rocher. Une rencontre commence quand un thon arrive à portée du rocher et finit quand plus aucun
# ne l'est. Elle compte comme une coupure si le banc y a plus de groupes qu'au début de la rencontre.
# Après une coupure, on mesure le temps qu'il faut au banc pour redevenir un seul groupe.
var _forme_rocher: Obstacle
var _rencontres: int = 0
var _coupures: int = 0
var _en_rencontre: bool = false
var _groupes_debut: int = 0
var _coupee: bool = false
# Rencontres où, au même pas, au moins MIN_COTE thons passent de chaque côté du rocher.
var _deux_cotes: int = 0
var _deux_cotes_vu: bool = false
var _debut_attente: int = -1
var _reformes: int = 0
var _somme_reforme: int = 0
# Distance la plus faible entre un thon et la surface du rocher, nombre de fois où un thon est
# dans le rocher, à portée du rocher, et à portée mais juste au-dessus de lui (il passe par-dessus).
var _distance_rocher: float = INF
var _dans_rocher: int = 0
var _pres_rocher: int = 0
var _par_dessus: int = 0


func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("pa="):
			_poids_alignement = float(argument.trim_prefix("pa="))
		if argument.begins_with("pc="):
			_poids_cohesion = float(argument.trim_prefix("pc="))
		if argument.begins_with("ps="):
			_poids_separation = float(argument.trim_prefix("ps="))
		if argument.begins_with("rv="):
			_rayon_vision = float(argument.trim_prefix("rv="))
		if argument.begins_with("thons="):
			_nombre_thons = int(argument.trim_prefix("thons="))
		if argument.begins_with("hr="):
			_hauteur_rocher = float(argument.trim_prefix("hr="))
		if argument == "rocher=0":
			_sans_rocher = true
		if argument.begins_with("graine="):
			seed(int(argument.trim_prefix("graine=")))
		if argument.begins_with("n="):
			_duree = int(argument.trim_prefix("n="))
	_aquarium = (load("res://aquarium/aquarium.tscn") as PackedScene).instantiate() as Aquarium
	# Le nombre de thons doit être réglé avant `_ready`, où l'aquarium crée le banc.
	if _nombre_thons >= 0:
		_aquarium.nombre_thons = _nombre_thons
	# Le rocher se construit dans `_ready` de l'aquarium : sa hauteur se règle avant.
	if not is_nan(_hauteur_rocher):
		(_aquarium.get_node("Rocher") as Rocher).hauteur = _hauteur_rocher
	root.add_child(_aquarium)


# Appelée à chaque pas de la physique. Rendre `true` arrête la simulation.
func _physics_process(_delta: float) -> bool:
	var banc: Array[Thon] = _aquarium._banc
	if _pas == 0:
		for thon: Thon in banc:
			if not is_nan(_poids_alignement):
				thon.poids_alignement = _poids_alignement
			if not is_nan(_poids_cohesion):
				thon.poids_cohesion = _poids_cohesion
			if not is_nan(_poids_separation):
				thon.poids_separation = _poids_separation
			if not is_nan(_rayon_vision):
				thon.rayon_vision = _rayon_vision
		_forme_rocher = _aquarium._rocher.obstacle()
		# Le rocher est le dernier obstacle de la liste, la même que celle des thons.
		if _sans_rocher:
			_aquarium._obstacles.pop_back()
	_relever(banc)
	_pas += 1
	if _pas < _duree:
		return false
	_ecrire_resultat(banc)
	return true


# Relève les mesures d'un pas.
func _relever(banc: Array[Thon]) -> void:
	var demi: Vector3 = _aquarium.dimensions / 2.0
	var distance_pas: float = INF
	var somme_directions: Vector3 = Vector3.ZERO
	var somme_plus_proche: float = 0.0
	var somme_virage: float = 0.0
	_vitesses_avant.resize(banc.size())
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
		if _pas > 0:
			somme_virage += _vitesses_avant[i].angle_to(banc[i]._vitesse)
		_vitesses_avant[i] = banc[i]._vitesse
		var plus_proche: float = INF
		for j: int in banc.size():
			if j != i:
				plus_proche = minf(plus_proche, point.distance_to(banc[j].position))
		somme_plus_proche += plus_proche
		distance_pas = minf(distance_pas, plus_proche)
	_distance_min = minf(_distance_min, distance_pas)
	if distance_pas < SEUIL_PROCHE:
		_pas_proches += 1
	var groupes: int = _compter_groupes(banc)
	_relever_rocher(banc, groupes)
	if groupes == 1 and _premier_banc < 0:
		_premier_banc = _pas
	if _pas >= _duree - PAS_FIN:
		_somme_groupes += groupes
		# Longueur de la moyenne des directions : 1 si tous nagent dans le même sens, 0 dans le désordre.
		_somme_directions += somme_directions.length() / banc.size()
		_somme_plus_proche += somme_plus_proche / banc.size()
		_somme_virage += somme_virage / banc.size()
		if groupes == 1:
			_pas_un_seul_banc += 1


# Relève ce qui se passe autour du rocher pendant un pas : distances, rencontres et coupures.
func _relever_rocher(banc: Array[Thon], groupes: int) -> void:
	var pres: int = 0
	# Thons à portée et sur le côté du rocher (pas au-dessus), avec leur position vue de dessus
	# par rapport à l'axe, et leur direction moyenne.
	var cotes: Array[Vector2] = []
	var direction: Vector2 = Vector2.ZERO
	for thon: Thon in banc:
		var surface: float = _forme_rocher.ecart(thon.position).length() - _forme_rocher.rayon
		_distance_rocher = minf(_distance_rocher, surface)
		if surface < 0.0:
			_dans_rocher += 1
		if surface < thon.portee_obstacles:
			pres += 1
			# Au-dessus du rocher : vu d'en haut, le thon est sur la forme du rocher.
			var vu_de_dessus: Vector2 = Vector2(thon.position.x, thon.position.z)
			var axe: Vector2 = vu_de_dessus - Geometry2D.get_closest_point_to_segment(vu_de_dessus,
					Vector2(_forme_rocher.bas.x, _forme_rocher.bas.z), Vector2(_forme_rocher.haut.x, _forme_rocher.haut.z))
			if axe.length() < _forme_rocher.rayon:
				_par_dessus += 1
			else:
				cotes.append(axe)
				direction += Vector2(thon._vitesse.x, thon._vitesse.z).normalized()
	_pres_rocher += pres
	if pres > 0 and not _en_rencontre:
		_en_rencontre = true
		_rencontres += 1
		_groupes_debut = groupes
		_coupee = false
		_deux_cotes_vu = false
	# Gauche ou droite du rocher, par rapport au sens de nage moyen des thons qui le longent.
	var gauche: int = cotes.filter(func(c: Vector2) -> bool: return direction.cross(c) > 0.0).size()
	if not _deux_cotes_vu and gauche >= MIN_COTE and cotes.size() - gauche >= MIN_COTE:
		_deux_cotes_vu = true
		_deux_cotes += 1
	if _en_rencontre and groupes > _groupes_debut:
		_coupee = true
	if pres == 0 and _en_rencontre:
		_en_rencontre = false
		if _coupee:
			_coupures += 1
			if _debut_attente < 0:
				_debut_attente = _pas
	if _debut_attente >= 0 and groupes == 1:
		_reformes += 1
		_somme_reforme += _pas - _debut_attente
		_debut_attente = -1


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


func _ecrire_resultat(banc: Array[Thon]) -> void:
	var moyenne_sur: float = float(mini(PAS_FIN, _duree))
	var thon: Thon = banc[0]
	print("pa=%s pc=%s ps=%s rv=%s thons=%d hr=%s | groupes=%.2f un_seul_banc=%d%% directions=%.2f premier_banc=%s | plus_proche=%.2f virage=%.0f°/s distance_min=%.2f pas_proches=%d | hors=%d sous_sable=%d dans_obstacle=%d | rocher=%s rencontres=%d deux_cotes=%d coupures=%d reforme=%s distance_rocher=%.2f dans_rocher=%d par_dessus=%d%%" % [
		thon.poids_alignement, thon.poids_cohesion, thon.poids_separation, thon.rayon_vision, banc.size(), _aquarium._rocher.hauteur,
		_somme_groupes / moyenne_sur, roundi(100.0 * _pas_un_seul_banc / moyenne_sur),
		_somme_directions / moyenne_sur,
		("%.0f s" % (_premier_banc / 60.0)) if _premier_banc >= 0 else "jamais",
		_somme_plus_proche / moyenne_sur, rad_to_deg(_somme_virage / moyenne_sur) * Engine.physics_ticks_per_second, _distance_min, _pas_proches, _hors, _sous_sable, _dans_obstacle,
		"non" if _sans_rocher else "oui", _rencontres, _deux_cotes, _coupures,
		("%.1f s" % (_somme_reforme / 60.0 / _reformes)) if _reformes > 0 else "-",
		_distance_rocher, _dans_rocher, roundi(100.0 * _par_dessus / maxi(1, _pres_rocher))])
