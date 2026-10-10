extends Thon
class_name Requin
## Le requin : il erre dans l'aquarium en évitant les parois, le sol, les plantes, les coraux
## et le rocher, et il suit le thon le plus proche qu'il voit, sans jamais l'attraper.
## Les thons ne le fuient pas encore.
##
## Héritage : le requin est un `Thon` qui ne fait pas partie du banc. Il garde donc, sans les
## réécrire, la vision, l'errance, l'évitement, le contournement et la vitesse bornée du thon
## (mêmes formules, voir thon.gd).
## Il voit les thons comme un thon voit ses voisins (rayon de vision, angle mort), mais il n'a
## ni séparation, ni alignement, ni cohésion : `decider` est réécrit ici sans ces trois forces.
## Il n'est pas dans la liste des thons : ils ne le voient pas, et les curseurs du banc
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


# Les réglages du requin qui diffèrent de ceux du thon, donnés à sa création.
# Valeurs proposées par Claude, à confirmer par Lou et Simon.
func _init() -> void:
	# Il part en patrouille : `decider` fait ensuite monter ou descendre sa vitesse max.
	vitesse_max = vitesse_patrouille
	# Son museau est à 2 de son centre, contre 1 pour le thon : il est repoussé 1 plus tôt (4 + 1).
	portee_evitement = 5.0
	portee_obstacles = 5.0


## Comme pour le thon, mais sans les trois forces du banc, et avec la poursuite en plus.
func decider(delta: float) -> void:
	var proie: Thon = _plus_proche(_voisins())
	# Deux allures : la vitesse max glisse vers celle de la chasse ou de la patrouille,
	# sans changer d'un coup. `_borner` s'en sert plus bas.
	var allure: float = vitesse_chasse if proie != null else vitesse_patrouille
	vitesse_max = move_toward(vitesse_max, allure, acceleration * delta)
	var force: Vector3 = _errance(delta) * poids_errance + _evitement() * poids_evitement \
			+ _contournement() * poids_obstacles + _poursuite(proie) * poids_poursuite
	_vitesse_suivante = _borner(_vitesse + force * delta)


# Le plus proche des thons vus, ou `null` s'il n'y en a aucun.
func _plus_proche(vus: Array[Thon]) -> Thon:
	var proche: Thon = null
	for thon: Thon in vus:
		if proche == null or position.distance_to(thon.position) < position.distance_to(proche.position):
			proche = thon
	return proche


# Force de poursuite : un ressort entre le requin et sa proie, au repos à la distance de suivi.
# Plus loin, elle tire le requin vers la proie ; plus près, elle le repousse et il ralentit.
# Sans proie, la force est nulle : il reste au requin l'errance, l'évitement et le contournement.
func _poursuite(proie: Thon) -> Vector3:
	if proie == null:
		return Vector3.ZERO
	var ecart: Vector3 = proie.position - position
	# Si le requin est exactement sur sa proie, `normalized` rend le vecteur nul : la force vaut zéro.
	return ecart.normalized() * (ecart.length() - distance_suivi)
