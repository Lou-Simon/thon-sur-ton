extends Thon
class_name Requin
## Le requin : il erre dans l'aquarium en évitant les parois, le sol, les plantes, les coraux
## et le rocher. Il ne chasse pas encore, et les thons ne le fuient pas encore.
##
## Héritage : le requin est un `Thon` sans banc. Il garde donc, sans les réécrire, l'errance,
## l'évitement, le contournement et la vitesse bornée du thon (mêmes formules, voir thon.gd).
## Sa liste `_banc` reste vide : il ne voit aucun voisin, et la séparation, l'alignement
## et la cohésion valent zéro. Il n'est pas non plus dans la liste des thons :
## ils ne le voient pas, et les curseurs du banc ne changent pas ses réglages.
##
## Comme pour un thon, c'est l'aquarium qui appelle `installer`, puis `decider` et `avancer`
## à chaque pas.


# Les réglages du requin qui diffèrent de ceux du thon, donnés à sa création.
# Valeurs proposées par Claude, à confirmer par Lou et Simon.
func _init() -> void:
	# Sa propre vitesse max : un peu moins que celle du thon (5).
	vitesse_max = 4.0
	# Son museau est à 2 de son centre, contre 1 pour le thon : il est repoussé 1 plus tôt (4 + 1).
	portee_evitement = 5.0
	portee_obstacles = 5.0
