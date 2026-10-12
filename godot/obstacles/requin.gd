extends Thon
class_name Requin
## Le requin : il erre dans l'aquarium en évitant les parois, le sol, les plantes, les coraux
## et le rocher. Dès qu'il voit des thons, il charge le centre du groupe qu'il voit, sans jamais
## les attraper : le banc s'ouvre devant lui. Après un temps de chasse, il patrouille un moment
## en s'écartant du banc : son attaque suivante part de loin.
## Plus gros qu'un thon, il nage plutôt à plat et ne peut pas tourner aussi sec.
## Les thons le fuient (voir `_fuite` dans thon.gd).
##
## Héritage : le requin est un `Thon` qui ne fait pas partie du banc. Il garde donc, sans les
## réécrire, la vision, l'errance, l'évitement, le contournement et la vitesse bornée du thon
## (mêmes formules, voir thon.gd).
## Il voit les thons comme un thon voit ses voisins (angle mort), mais de plus loin. Il n'a ni
## séparation, ni alignement, ni cohésion, ni fuite comme forces : `decider` est réécrit ici sans
## elles. Il reprend seulement les calculs de la cohésion et de l'alignement pour viser le banc.
## Il n'est pas dans la liste des thons : il n'est pas un voisin pour eux, et les curseurs du banc
## ne changent pas ses réglages.
##
## Comme pour un thon, c'est l'aquarium qui appelle `installer`, puis `decider` et `avancer`
## à chaque pas.

# Valeurs proposées par Claude, à confirmer par Lou et Simon.
## Poids de la poursuite dans la somme des forces.
@export var poids_poursuite: float = 10.0
## Distance au centre des thons qu'il voit à laquelle il ralentit à leur vitesse, en unités Godot.
@export var distance_suivi: float = 4.0
## Vitesse max quand il ne chasse pas : il patrouille lentement.
@export var vitesse_patrouille: float = 2.5
## Vitesse max quand il chasse : plus que celle d'un thon (5), pour que ses attaques soient rapides.
@export var vitesse_chasse: float = 7.0
## Ce que la vitesse max gagne ou perd par seconde quand il change d'allure.
@export var acceleration: float = 6.0
## Temps, en secondes, dont il anticipe la nage des thons : il vise là où ils seront, pas là où ils sont.
@export var anticipation: float = 1.0
## Temps de chasse, en secondes, au bout duquel il part en patrouille.
@export var duree_chasse: float = 5.0
## Temps de patrouille, en secondes, avant de pouvoir chasser à nouveau.
@export var duree_repos: float = 6.0
## Longueur la plus grande de la somme des forces : elle borne ses virages, il tourne large.
@export var force_max: float = 5.0
## Poids de l'éloignement du banc pendant la patrouille.
@export var poids_eloignement: float = 2.0
## Poids du redressement dans la somme des forces : il nage plutôt à plat.
@export var poids_redressement: float = 3.0

# Temps de chasse cumulé depuis la dernière patrouille, et temps de patrouille qui reste.
var _chasse: float = 0.0
var _repos: float = 0.0


# Les réglages du requin qui diffèrent de ceux du thon, donnés à sa création.
# Valeurs proposées par Claude, à confirmer par Lou et Simon.
func _init() -> void:
	# Il part en patrouille : `decider` fait ensuite monter ou descendre sa vitesse max.
	vitesse_max = vitesse_patrouille
	# Son museau est à 2 de son centre, contre 1 pour le thon : il est repoussé 1 plus tôt (4 + 1).
	portee_evitement = 5.0
	portee_obstacles = 5.0
	# Il voit plus loin que les thons ne le sentent (8) : il repère les thons avant qu'ils fuient.
	rayon_vision = 14.0


## Comme pour le thon, mais sans les trois forces du banc ni la fuite, avec la poursuite,
## l'éloignement et le redressement en plus, et une somme des forces bornée.
func decider(delta: float) -> void:
	var vus: Array[Thon] = _voisins()
	var chasse: bool = _en_chasse(not vus.is_empty(), delta)
	# Deux allures : la vitesse max glisse vers celle de la chasse ou de la patrouille,
	# sans changer d'un coup. `_borner` s'en sert plus bas.
	var allure: float = vitesse_chasse if chasse else vitesse_patrouille
	vitesse_max = move_toward(vitesse_max, allure, acceleration * delta)
	# Sa réaction aux thons qu'il voit : en chasse il les charge, sinon il s'en écarte.
	var reaction: Vector3 = _poursuite(vus) * poids_poursuite if chasse else _eloignement(vus) * poids_eloignement
	var force: Vector3 = _errance(delta) * poids_errance + _evitement() * poids_evitement \
			+ _contournement() * poids_obstacles + reaction + _redressement() * poids_redressement
	# Bornée, la force ne peut ni le retourner d'un coup, ni changer sa vitesse brutalement.
	_vitesse_suivante = _borner(_vitesse + force.limit_length(force_max) * delta)


# Il chasse dès qu'il voit un thon, sauf pendant une patrouille. Après `duree_chasse` secondes
# de chasse, il patrouille `duree_repos` secondes : sans ces pauses, il ne quitte jamais le banc.
func _en_chasse(voit_un_thon: bool, delta: float) -> bool:
	if _repos > 0.0:
		_repos -= delta
		return false
	if not voit_un_thon:
		return false
	_chasse += delta
	if _chasse < duree_chasse:
		return true
	_chasse = 0.0
	_repos = duree_repos
	return false


# Force de poursuite (« pursuit » de Reynolds) : l'écart entre la vitesse voulue et la vitesse du
# requin. La vitesse voulue va vers là où sera le centre des thons qu'il voit dans `anticipation`
# secondes. Il charge le centre et non le thon le plus proche : celui-ci est au bord du banc, et
# le charger poussait tout le banc du même côté, sans le faire éclater.
# Le centre et la vitesse moyenne des thons vus viennent de la cohésion et de l'alignement du thon.
# La longueur de la vitesse voulue est la vitesse moyenne des thons, plus l'écart à la distance
# de suivi : trop loin il accélère, trop près il ralentit. Il n'est appelé que s'il voit un thon.
func _poursuite(vus: Array[Thon]) -> Vector3:
	var vers_centre: Vector3 = _cohesion(vus)
	var vitesse_thons: Vector3 = _vitesse + _alignement(vus)
	var visee: Vector3 = vers_centre + vitesse_thons * anticipation
	var allure: float = vitesse_thons.length() + vers_centre.length() - distance_suivi
	# Si le point visé est sur le requin, `normalized` rend le vecteur nul : il freine seulement.
	return visee.normalized() * clampf(allure, 0.0, vitesse_chasse) - _vitesse


# Force d'éloignement, quand il ne chasse pas : l'écart entre une vitesse de patrouille qui
# l'écarte du centre des thons qu'il voit (l'inverse de la cohésion d'un thon) et sa vitesse.
# Il prend du large : le banc se reforme, et sa prochaine attaque part de loin, avec de l'élan.
func _eloignement(vus: Array[Thon]) -> Vector3:
	# Sans thon vu, pas de centre : la force est nulle.
	if vus.is_empty():
		return Vector3.ZERO
	return -_cohesion(vus).normalized() * vitesse_patrouille - _vitesse


# Force de redressement : elle ramène sa vitesse verticale vers zéro, comme un alignement sur
# l'horizontale. Sans elle, il garde la pente que l'errance lui a donnée et pique comme un thon.
func _redressement() -> Vector3:
	return Vector3(0.0, -_vitesse.y, 0.0)
