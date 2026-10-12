extends Thon
class_name Requin
## Le requin : il erre dans l'aquarium en évitant les parois, le sol, les plantes, les coraux
## et le rocher. Il prend pour proie le thon le plus proche qu'il voit, et la suit sans jamais
## l'attraper, tant qu'il la voit.
## Les thons le fuient (voir `_fuite` dans thon.gd).
##
## Héritage : le requin est un `Thon` qui ne fait pas partie du banc. Il garde donc, sans les
## réécrire, la vision, l'errance, l'évitement, le contournement et la vitesse bornée du thon
## (mêmes formules, voir thon.gd).
## Il voit les thons comme un thon voit ses voisins (rayon de vision, angle mort), mais il n'a
## ni séparation, ni alignement, ni cohésion, ni fuite : `decider` est réécrit ici sans ces forces.
## Il n'est pas dans la liste des thons : il n'est pas un voisin pour eux, et les curseurs du banc
## ne changent pas ses réglages.
##
## Comme pour un thon, c'est l'aquarium qui appelle `installer`, puis `decider` et `avancer`
## à chaque pas.

# Valeurs proposées par Claude, à confirmer par Lou et Simon.
## Poids de la poursuite dans la somme des forces.
@export var poids_poursuite: float = 10.0
## Distance à laquelle le requin se tient de sa proie, en unités Godot.
@export var distance_suivi: float = 4.0
## Vitesse max sans proie en vue : il patrouille lentement.
@export var vitesse_patrouille: float = 2.5
## Vitesse max avec une proie en vue : il accélère pour la suivre.
@export var vitesse_chasse: float = 4.5
## Ce que la vitesse max gagne ou perd par seconde quand il change d'allure.
@export var acceleration: float = 2.0
## Part de l'écart de vitesse avec la proie que la poursuite corrige : elle freine le va-et-vient
## autour de la distance de suivi. Valeur choisie par Simon sur mesures.
@export var amortissement: float = 1.0

# La proie suivie, ou `null` s'il n'en voit aucune.
var _proie: Thon = null


# Les réglages du requin qui diffèrent de ceux du thon, donnés à sa création.
# Valeurs proposées par Claude, à confirmer par Lou et Simon.
func _init() -> void:
	# Il part en patrouille : `decider` fait ensuite monter ou descendre sa vitesse max.
	vitesse_max = vitesse_patrouille
	# Son museau est à 2 de son centre, contre 1 pour le thon : il est repoussé 1 plus tôt (4 + 1).
	portee_evitement = 5.0
	portee_obstacles = 5.0


## Comme pour le thon, mais sans les trois forces du banc ni la fuite, et avec la poursuite en plus.
func decider(delta: float) -> void:
	var vus: Array[Thon] = _voisins()
	# Il garde sa proie tant qu'il la voit. Reprendre le plus proche à chaque pas le faisait
	# changer de cible dès que deux thons échangeaient leur rang, et zigzaguer.
	if not vus.has(_proie):
		_proie = _plus_proche(vus)
	# Deux allures : la vitesse max glisse vers celle de la chasse ou de la patrouille,
	# sans changer d'un coup. `_borner` s'en sert plus bas.
	var allure: float = vitesse_chasse if _proie != null else vitesse_patrouille
	vitesse_max = move_toward(vitesse_max, allure, acceleration * delta)
	var force: Vector3 = _errance(delta) * poids_errance + _evitement() * poids_evitement \
			+ _contournement() * poids_obstacles + _poursuite(_proie) * poids_poursuite
	_vitesse_suivante = _borner(_vitesse + force * delta)


# Le plus proche des thons vus, ou `null` s'il n'y en a aucun.
func _plus_proche(vus: Array[Thon]) -> Thon:
	var proche: Thon = null
	for thon: Thon in vus:
		if proche == null or position.distance_to(thon.position) < position.distance_to(proche.position):
			proche = thon
	return proche


# Force de poursuite : un ressort amorti entre le requin et sa proie, au repos à la distance de suivi.
# Plus loin, elle tire le requin vers la proie ; plus près, elle le repousse et il ralentit.
# L'amortissement le rapproche aussi de la vitesse de sa proie (comme l'alignement d'un thon,
# avec un seul voisin) : sans lui, le ressort le fait osciller autour de la distance de suivi.
# Sans proie, la force est nulle : il reste au requin l'errance, l'évitement et le contournement.
func _poursuite(proie: Thon) -> Vector3:
	if proie == null:
		return Vector3.ZERO
	var ecart: Vector3 = proie.position - position
	# Si le requin est exactement sur sa proie, `normalized` rend le vecteur nul : la force vaut zéro.
	return ecart.normalized() * (ecart.length() - distance_suivi) + amortissement * (proie._vitesse - _vitesse)
