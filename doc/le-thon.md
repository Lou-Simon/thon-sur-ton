# Le thon

*Schémas et textes proposés par Claude (12 octobre 2026) à partir du code du 12 octobre 2026, à relire et valider par Lou et Simon.*

Tout le comportement du thon est dans `godot/thon/thon.gd`. Il n'a pas de machine à états : à chaque pas, il additionne sept forces et en tire sa nouvelle vitesse.

## Ce qu'il voit {#vision}

![Vision du thon : un rayon de vision de 8, un angle mort de 90° derrière lui, et une distance « trop proche » de 3](/schemas/vision-thon.png)

- Un thon voit les thons à moins de 8 (le **rayon de vision**).
- Il ne voit pas ceux qui sont dans l'**angle mort** : un cône de 90° derrière lui, 45° de chaque côté de l'axe arrière.
- Les thons qu'il voit sont ses **voisins**. Les trois forces du banc ne comptent qu'eux.

Fonction : `_voisins()`.

## Comment il nage {#nage}

![La nage du thon : il avance vers où il regarde, sa vitesse reste entre 2 et 5, sa queue bat](/schemas/nage-thon.svg)

Le thon a une **vitesse** : un vecteur. Sa direction est le sens de nage, sa longueur est la vitesse en unités par seconde.

À chaque pas :

1. `decider` additionne les forces et calcule la vitesse suivante : `vitesse + force × durée du pas`.
2. `_borner` ramène la longueur de cette vitesse entre 2 et 5, sans changer sa direction. Le thon ne s'arrête donc jamais.
3. `avancer` applique la vitesse : `position + vitesse × durée du pas`, puis tourne le thon vers le point où il va (`look_at`).

La queue qui bat (2 battements par seconde, 25° de chaque côté) est dans `modele_thon.gd`. C'est seulement l'apparence : elle ne dépend pas de la vitesse et ne change pas le déplacement.

## L'errance {#errance}

![L'errance : une cible glisse au hasard sur une sphère placée devant le thon, et le thon est attiré vers elle](/schemas/errance.svg)

Seul, sans paroi ni voisin, le thon ne nage pas tout droit : il change doucement de direction au hasard.

- Une sphère de rayon 2 est placée à 2 devant lui.
- Une cible est posée sur cette sphère. À chaque pas, elle est poussée un peu au hasard, puis ramenée sur la sphère.
- La force d'errance va du thon vers la cible.

Tirer une direction au hasard à chaque pas ferait trembler le thon. Ici la cible bouge peu d'un pas à l'autre : le virage est doux.

Fonction : `_errance()`. Source : comportement *wander* de C. W. Reynolds (1999). **Référence exacte à vérifier** avant de la citer dans le rapport. Écart avec l'article : il travaille en 2D, ici la cible glisse sur une sphère.

## Une force, un poids {#poids}

![Le poids d'une force : une force est une flèche, le poids change sa longueur, le thon suit la somme](/schemas/poids-force.png)

Une force est un vecteur : une direction et une longueur. Avant la somme, chaque force est multipliée par son **poids**. Le poids ne change pas la direction, seulement l'importance de la force. Les curseurs du panneau « Réglages » changent ces poids en direct.

## Les sept forces {#forces}

![Les sept forces du thon, leur poids et leur origine, additionnées en une somme pondérée qui donne une vitesse bornée entre 2 et 5](/schemas/forces-thon.png)

| Force | Ce qu'elle fait | Poids | Fonction |
| --- | --- | --- | --- |
| [Errance](#errance) | Changer doucement de direction au hasard. | 1 | `_errance` |
| [Parois et sol](#rampe) | S'éloigner d'une paroi ou du sable à moins de 4. | 30 | `_evitement` |
| [Plantes, coraux et rocher](#contournement) | S'éloigner d'un obstacle à moins de 4 de sa surface. | 30 | `_contournement` |
| [Séparation](#banc) | S'écarter d'un voisin à moins de 3. | 60 | `_separation` |
| [Alignement](#banc) | Prendre la vitesse moyenne de ses voisins. | 6 | `_alignement` |
| [Cohésion](#banc) | Aller vers le centre de ses voisins. | 1 | `_cohesion` |
| [Fuite](#fuite) | S'éloigner du requin à moins de 8. | 50 | `_fuite` |

Les poids ne se comparent pas directement : les forces n'ont pas la même longueur. La cohésion est une distance (jusqu'à 8), la séparation une poussée entre 0 et 1 par voisin.

## La rampe de poussée {#rampe}

![La rampe de poussée : nulle à la portée, 1 au contact, utilisée pour les parois, les obstacles et les voisins trop proches](/schemas/rampe-poussee.svg)

Trois forces utilisent la même règle, `_poussee()` : plus le thon est proche, plus il est repoussé.

`poussée = max(0, 1 − distance / portée)`

- À la portée ou plus loin : 0.
- Au contact : 1.
- Si le thon a franchi une paroi : plus de 1, il est ramené plus fort.

Pour les parois, chaque axe a deux poussées opposées : la paroi de gauche pousse vers la droite, celle de droite vers la gauche. Le sol remplace la paroi du bas et pousse vers le haut ; sa hauteur est celle du sable sous le thon, dunes comprises.

## Le contournement des obstacles {#contournement}

![Le contournement : le rocher est un segment entouré d'une épaisseur de 3,5 ; il repousse le thon à moins de 4 de sa surface, depuis le point du segment le plus proche](/schemas/contournement.svg)

Un obstacle est un **segment entouré d'une épaisseur** (`godot/decor/obstacle.gd`) :

- une algue : un segment debout, du pied au sommet ;
- un corail : un segment réduit à un point ;
- le rocher : un segment couché de longueur 6, épaisseur 3,5.

Le thon cherche le point du segment le plus proche de lui. La poussée part de ce point vers le thon, avec la [rampe](#rampe) appliquée à la distance à la surface.

Chaque thon ne sent le rocher qu'une fois à portée. Aucun ne connaît sa forme ni le chemin pour le contourner : le banc qui s'ouvre et se referme n'est écrit nulle part.

## Les trois règles du banc {#banc}

![Les trois règles du banc : séparation (poids 60), alignement (poids 6), cohésion (poids 1)](/schemas/regles-banc.svg)

| Règle | Formule | En mots |
| --- | --- | --- |
| Séparation | `Σ normaliser(p_i − p_j) · poussée(distance)`, portée 3 | Chaque voisin trop proche pousse le thon à l'opposé de lui. |
| Alignement | `moyenne(v_j) − v_i` | L'écart entre la vitesse moyenne des voisins et la sienne. |
| Cohésion | `moyenne(p_j) − p_i` | Du thon vers le centre de ses voisins. |

`p` est une position, `v` une vitesse, `i` le thon, `j` un voisin vu.

- Sans voisin vu, l'alignement et la cohésion valent zéro : le thon garde l'errance, l'évitement, le contournement et la fuite.
- L'alignement lit la vitesse des voisins. C'est pour cela que la nouvelle vitesse est rangée à part jusqu'à ce que tous aient décidé (voir [Un pas de simulation](/la-simulation#pas)).

Source : ces trois règles sont attribuées à Craig Reynolds (modèle des boids, 1987). **Référence exacte à vérifier** avant de la citer.

## La fuite {#fuite}

![La fuite : l'inverse de la distance au requin, nulle au-delà du rayon de vision de 8](/schemas/fuite.svg)

`fuite = normaliser(p_thon − p_requin) / distance`

- Elle vaut zéro si le requin est à 8 ou plus (le rayon de vision).
- Pas d'angle mort pour le requin : le thon le sent tout autour de lui. C'est une exception voulue à la règle de vision.
- Tout près, la force est très grande. La vitesse reste bornée à 5 : le thon tourne et accélère jusqu'à sa vitesse max, pas plus.
- Le requin, lui, voit les thons à 14 : il les repère avant qu'ils le sentent (voir [Le requin](/le-requin#heritage)).

Ce n'est pas la [rampe](#rampe) : la fuite grandit beaucoup plus vite quand le requin est tout près.

## D'où viennent les valeurs {#valeurs}

Les poids, les portées et le rayon de vision ont été choisis par Lou et Simon, à l'écran et sur des mesures sans fenêtre (`godot/mesures/mesure_banc.gd`). Les curseurs permettent d'en changer une partie pendant la démo (voir [Interface et ergonomie](/interface#curseurs)).
