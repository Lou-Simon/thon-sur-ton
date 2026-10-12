# Le requin

Le comportement du requin est dans `godot/obstacles/requin.gd`. Contrairement au thon, il a deux états : il patrouille ou il chasse.

## Un thon qui n'est pas dans le banc {#heritage}

Le requin **hérite** du thon (`extends Thon`). Il garde, sans les réécrire :

- l'[errance](/le-thon#errance), l'évitement des parois et du sol, le [contournement](/le-thon#contournement) ;
- la [vision](/le-thon#vision), avec le même angle mort de 90° ;
- la vitesse bornée.

Il n'a ni séparation, ni alignement, ni cohésion, ni fuite : sa fonction `decider` est réécrite sans ces forces. Il reprend seulement les calculs de la cohésion et de l'alignement, pour viser le banc.

Il n'est pas dans la liste des thons. Pour eux, il n'est donc pas un voisin, et les curseurs du banc ne changent pas ses réglages.

| Réglage | Thon | Requin | Pourquoi |
| --- | --- | --- | --- |
| Rayon de vision | 8 | 14 | Il repère les thons avant qu'ils le sentent (à 8). |
| Portées d'évitement | 4 | 5 | Son museau est plus loin de son centre. |
| Vitesse max | 5 | 2,5 ou 7 | Selon son état (voir plus bas). |
| Longueur | 2 | 4 | Seulement l'apparence. |

## Deux états {#etats}

![Machine à états du requin : patrouille (vitesse max 2,5) et chasse (vitesse max 7) ; il chasse quand il voit un thon, et retourne en patrouille après 5 secondes de chasse](/schemas/etats-requin.png)

| État | Quand | Vitesse max | Ce qu'il fait des thons qu'il voit |
| --- | --- | --- | --- |
| Patrouille | Il ne voit aucun thon, ou il est en repos. | 2,5 | Il s'en écarte ([éloignement](#eloignement)). |
| Chasse | Il voit au moins un thon, hors repos. | 7 | Il charge leur centre ([poursuite](#poursuite)). |

- **Les pauses** : après 5 secondes de chasse, il patrouille 6 secondes sans pouvoir chasser, même s'il voit des thons. Sans ces pauses, il ne quitte jamais le banc, qui n'a pas le temps de se reformer.
- Les 5 secondes se cumulent : s'il perd les thons de vue puis les retrouve, le compte reprend où il en était.
- La vitesse max ne saute pas d'une allure à l'autre : elle glisse de 6 par seconde.
- Dans les deux états, il garde l'errance, l'évitement et le contournement.

Fonction : `_en_chasse()`.

## La poursuite {#poursuite}

![La poursuite du requin : il vise le point où sera le centre des thons qu'il voit dans 1 seconde, et ralentit à la distance de suivi de 4](/schemas/poursuite-requin.svg)

En chasse, le requin ne choisit pas de proie : il charge le **centre** des thons qu'il voit. Il ne les attrape jamais.

`poursuite = normaliser(c + v_thons × 1 s − p_requin) · allure − v_requin`

`allure = |v_thons| + distance − 4`, gardée entre 0 et 7

`c` est le centre des thons vus, `v_thons` leur vitesse moyenne, `distance` celle du requin à ce centre.

- **Il vise où le banc sera** : le centre, avancé d'une seconde de nage des thons (l'**anticipation**).
- **Il règle son allure sur la distance** : loin, il accélère ; à la **distance de suivi** (4), il nage à la vitesse des thons ; plus près, il ralentit.
- **La force est un écart de vitesses** : la vitesse voulue moins la sienne, comme l'alignement d'un thon. C'est ce qui l'empêche d'osciller autour de la distance de suivi.
- **Pourquoi le centre** : le thon le plus proche est au bord du banc. Le charger poussait tout le banc du même côté, sans le faire éclater.

Fonction : `_poursuite()`. Source : comportement *pursuit* de C. W. Reynolds (1999). **Référence exacte à vérifier** avant de la citer dans le rapport.

## L'éloignement {#eloignement}

`éloignement = −normaliser(c − p_requin) · 2,5 − v_requin`

En patrouille, s'il voit des thons, le requin s'écarte de leur centre à sa vitesse de patrouille : c'est l'inverse de la cohésion d'un thon. Il prend du large, le banc se reforme, et l'attaque suivante part de loin, avec de l'élan. Sans thon en vue, cette force vaut zéro.

Fonction : `_eloignement()`.

## La somme des forces {#forces}

| Force | Ce qu'elle fait | Poids | Fonction |
| --- | --- | --- | --- |
| [Errance](/le-thon#errance) | Changer doucement de direction au hasard. | 1 | `_errance` |
| [Parois et sol](/le-thon#rampe) | S'éloigner d'une paroi ou du sable à moins de 5. | 30 | `_evitement` |
| [Plantes, coraux et rocher](/le-thon#contournement) | S'éloigner d'un obstacle à moins de 5 de sa surface. | 30 | `_contournement` |
| [Poursuite](#poursuite) | En chasse : charger le centre des thons vus. | 10 | `_poursuite` |
| [Éloignement](#eloignement) | En patrouille : s'écarter du centre des thons vus. | 2 | `_eloignement` |
| Redressement | Ramener sa vitesse verticale vers zéro : il nage plutôt à plat. | 3 | `_redressement` |

La poursuite et l'éloignement ne s'ajoutent jamais : c'est l'une ou l'autre, selon l'état.

Deux bornes s'appliquent ensuite :

- **La force** : la somme est ramenée à une longueur de 5 au plus. Plus gros qu'un thon, le requin ne peut ni se retourner d'un coup, ni changer brutalement de vitesse : il tourne large.
- **La vitesse** : entre 2 et sa vitesse max du moment, comme pour le thon.

Limite à connaître : sa vitesse ne descend pas sous 2 (vitesse min héritée du thon). Il ne peut pas s'arrêter.

## Ce que font les thons {#fuite}

Un thon qui a le requin à moins de 8 s'en éloigne : voir [La fuite](/le-thon#fuite). Comme le requin entre dans le banc par son centre, les thons fuient de part et d'autre : le banc éclate, puis se reforme pendant la patrouille.

## D'où viennent les valeurs {#valeurs}

Les réglages du requin ont été choisis sur des mesures sans fenêtre, le 10 et le 12 octobre 2026. Dans le code, ils portent encore la mention « à confirmer par Lou et Simon » : ils restent à régler à l'écran. Le détail des essais est dans le skill `boids` du dépôt.
