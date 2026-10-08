---
name: boids
description: Forces du thon (errance, évitement, séparation, alignement, cohésion, fuite), leurs paramètres et leurs formules avec leur source. À lire avant d'écrire, de modifier ou d'expliquer le comportement du thon.
---
# Forces du thon

Les descriptions viennent de `doc/versions.md`. Les formules et leurs sources sont écrites
par Lou et Simon : une case « à écrire » n'est pas encore décidée.

**Règle** : on ne code jamais une force dont la formule est « à écrire ». On s'arrête et on
demande. On n'invente ni formule, ni valeur, ni référence.

## Principe
- Un thon ne voit que ses voisins proches : ceux dans son rayon de vision, sauf dans l'angle
  mort derrière lui. Il ne connaît jamais le banc entier.
- À chaque instant, il additionne ses forces, chacune multipliée par son poids.
- Sa vitesse reste entre un minimum et un maximum.
- Tous les thons bougent en même temps.

## Les forces

| Force | Version | Ce qu'elle fait | Formule | Source |
| --- | --- | --- | --- | --- |
| Errance | v1.4.0 | Le thon change doucement de direction au hasard. | voir [Errance](#errance) | Reynolds 1999, à vérifier |
| Évitement | v1.5.0, v1.7.0, v2.2.0 | Plus le thon s'approche d'une paroi, du sol, d'une plante, d'un corail ou du rocher, plus il est repoussé. | parois et sol : voir [Évitement](#evitement) ; plantes, coraux et rocher : voir [Contournement](#contournement) | choix de Lou et Simon |
| Séparation | v2.0.0 | Le thon s'écarte des voisins trop proches. | voir [Séparation](#separation) | choix de Lou, rampe validée par Simon |
| Alignement | v2.1.0 | Le thon nage dans la même direction que ses voisins. | voir [Alignement et cohésion](#alignement-cohesion) | Reynolds, à vérifier |
| Cohésion | v2.1.0 | Le thon se rapproche du centre de ses voisins. | voir [Alignement et cohésion](#alignement-cohesion) | Reynolds, à vérifier |
| Fuite | v3.2.0, v3.4.0 | Un thon qui voit le requin ou le filet s'en éloigne, d'autant plus fort qu'il est proche. | à écrire | à renseigner |

## Les paramètres

| Paramètre | Sert à | Valeur |
| --- | --- | --- |
| Nombre de thons | Taille du banc au lancement (`Aquarium.nombre_thons`). | 30 (Simon, 8 oct. 2026, v2.1.1) |
| Rayon de vision | Distance jusqu'où un thon voit ses voisins. | 8 unités (Simon, 8 oct. 2026, v2.1.1 ; 6 en v2.0.0) |
| Angle mort | Zone derrière le thon où il ne voit pas. | 90° (Lou, 8 oct. 2026, proposition de Claude, à régler à l'écran) |
| Vitesse minimale | Borne basse de la vitesse. | 2 unités/s (Simon, 8 oct. 2026, à ajuster à l'écran) |
| Vitesse maximale | Borne haute de la vitesse. | 5 unités/s (Simon, 8 oct. 2026, à ajuster à l'écran) |
| Portée et poids de l'évitement | Distance où une paroi commence à repousser, et force de la poussée (voir [Évitement](#evitement)). | 4 et 30 (Simon, 8 oct. 2026, d'après des essais) |
| Portée et poids du contournement | Plantes, coraux et rocher (voir [Contournement](#contournement)). | 4 et 30, comme les parois (Simon, 8 oct. 2026, d'après des essais) |
| Distance et poids de la séparation | Distance sous laquelle un voisin repousse, et force de la poussée (voir [Séparation](#separation)). | 3 (Lou, 8 oct. 2026, confirmé par Simon) et 60 (Simon, 8 oct. 2026, v2.1.1, d'après des mesures : voir [Séparation](#separation)) |
| Poids de l'alignement et de la cohésion | Importance de chaque force dans la somme (voir [Alignement et cohésion](#alignement-cohesion)). | 6 et 1 (Lou, 8 oct. 2026, d'après des essais) |
| Distance, rayon, hasard de l'errance | Forme de l'errance (voir [Errance](#errance)). | 2, 2 et 3 : proposition de Claude, à régler à l'écran |
| Poids de l'errance | Importance de l'errance dans la somme. | 1 (valeur du code depuis la v1.4.0, source à noter par Lou et Simon) |
| Poids de la fuite | Importance de la fuite dans la somme (v3). | à fixer |

Les poids, les vitesses et le rayon de vision sont réglables par curseur (v2.3.0).

## Questions à trancher avant de coder
- Fuite : comment la force grandit quand le requin ou le filet se rapproche.

Tranché par Simon le 8 octobre 2026 (v2.2.0) :
- Le rocher est un obstacle comme les plantes, avec la même force de contournement. Chaque thon ne le sent qu'à portée : le contournement par le banc doit émerger, sans coordination. Un thon qui passe par-dessus est un comportement émergent, pas un défaut.

Tranché par Lou le 8 octobre 2026 (v2.0.0) :
- Somme des forces : simple somme pondérée.
- Un thon sans voisin garde l'errance, l'évitement et le contournement.

## Référence
Le modèle des boids est attribué à Craig Reynolds (1987). Référence exacte à vérifier par
Lou et Simon avant de la citer dans le code ou le rapport.

## Pour chaque formule ajoutée
Noter ici : la formule, ce que veut dire chaque symbole, la source, et qui l'a validée.

### Errance {#errance}

Choisie par Simon le 8 octobre 2026 (v1.4.0). Code : `godot/thon/thon.gd`.

À chaque pas de temps `Δt` :

1. `c ← r · normaliser(c + ξ · j · Δt)` : la cible `c` glisse un peu au hasard, puis revient sur la sphère de rayon `r`.
2. `F = d · v / |v| + c` : la force va du thon vers la cible, posée sur une sphère placée à la distance `d` devant lui.
3. `v ← v + w · F · Δt`, puis `|v|` est ramenée entre `v_min` et `v_max` sans changer sa direction.

| Symbole | Sens | Variable |
| --- | --- | --- |
| `c` | cible d'errance, par rapport au centre de la sphère | `_cible_errance` |
| `ξ` | vecteur au hasard, chaque composante entre -1 et 1 | `hasard` |
| `j` | déplacement de la cible par seconde | `hasard_errance` |
| `r` | rayon de la sphère | `rayon_errance` |
| `d` | distance entre le thon et le centre de la sphère | `distance_errance` |
| `v` | vitesse du thon | `_vitesse` |
| `w` | poids de l'errance | `poids_errance` |

Source : C. W. Reynolds, « Steering Behaviors For Autonomous Characters », Game Developers Conference, 1999 (comportement *wander*). Référence exacte à vérifier par Lou et Simon avant de la citer dans le rapport. Écart avec l'article : il travaille en 2D ; ici la cible glisse sur une sphère, en 3D.

### Évitement des parois et du sol {#evitement}

Choisi par Simon le 8 octobre 2026 (v1.5.0). Code : `godot/thon/thon.gd`.

Une rampe linéaire : pour une paroi à la distance `δ`, la poussée vaut `P(δ) = max(0, 1 - δ / p)`. Elle vaut 0 à la portée `p` ou plus loin, 1 contre la paroi, et plus de 1 si le thon l'a dépassée.

`F = ( P(x + Lx) - P(Lx - x),  P(y - s(x, z)) - P(Ly - y),  P(z + Lz) - P(Lz - z) )`, puis la force s'ajoute avec le poids `w_e`.

| Symbole | Sens | Variable |
| --- | --- | --- |
| `x, y, z` | position du thon, repère centré sur l'aquarium | `position` |
| `Lx, Ly, Lz` | demi-dimensions de l'aquarium | `_demi` |
| `s(x, z)` | hauteur du sable sous le thon (les vraies dunes) | `Sol.hauteur_sable()` |
| `p` | portée | `portee_evitement` |
| `w_e` | poids de l'évitement | `poids_evitement` |

Le sol remplace la paroi du bas, et il pousse tout droit vers le haut, même sur la pente d'une dune.

Source : pas d'article, c'est un choix du projet. Valeurs : portée 4 et poids 20 ont été choisis d'abord. Sur 6 simulations de 5 minutes, le museau du thon est sorti une fois de 0,14. Avec un poids de 30, sur 5 simulations, il est resté à au moins 0,68 des parois et 0,98 du sable.

### Contournement des plantes, des coraux et du rocher {#contournement}

Choisi par Simon le 8 octobre 2026 (v1.7.0). Code : `_contournement()` dans `godot/thon/thon.gd`, obstacles dans `godot/decor/obstacle.gd`.

Chaque obstacle est un segment `[A, B]` entouré d'une épaisseur `e` : une algue va de son pied à son sommet, un corail est un segment réduit à un point. On note `q` le point du segment le plus proche du thon. La même rampe linéaire que pour les parois s'applique à la distance à la surface :

`F = Σ normaliser(p - q) · P(|p - q| - e)`, avec `P(δ) = max(0, 1 - δ / p_o)`, puis la force s'ajoute avec le poids `w_o`.

| Symbole | Sens | Variable |
| --- | --- | --- |
| `p` | position du thon | `position` |
| `q` | point de l'obstacle le plus proche du thon | `Geometry3D.get_closest_point_to_segment()` |
| `e` | épaisseur de l'obstacle (algue : largeur plus ondulation) | `Obstacle.rayon` |
| `p_o` | portée | `portee_obstacles` |
| `w_o` | poids | `poids_obstacles` |

Source : pas d'article, la même rampe que pour les parois. Valeurs : sur 5 simulations de 5 minutes, avec 31 obstacles, le thon (centre et museau) est resté à au moins 1,22 de la surface des obstacles, 0,77 des parois et 1,02 du sable.

Rocher (v2.2.0, choisi par Simon le 8 octobre 2026) : le même modèle, avec un segment couché. Au centre de l'aquarium, un segment de longueur 6 dans le sens de la longueur (axe x), à 0,5 au-dessus du sable, entouré d'une épaisseur de 3,5 (une capsule) : un rocher long et bas, d'environ 13 de long. Code : `godot/obstacles/rocher.gd` ; l'aquarium ajoute son obstacle à la fin de la liste des plantes et coraux. Le rocher dessiné est cette capsule aplatie et cabossée vers l'intérieur : il reste dans la zone que les thons évitent. Taille, forme et place : propositions de Claude, ajustées par Simon après essai à l'écran (d'abord debout, puis « plus long et moins haut »).

Mesures : `godot/mesures/mesure_banc.gd` (30 thons, vision 8, séparation 60, 5 minutes simulées). `rocher=0` laisse le rocher à l'écran mais le retire de la liste des thons : c'est le témoin, à la même place.

Rocher couché, graines 1 à 3 : 16 à 25 rencontres ; aucun thon dans la capsule sur deux simulations, et sur la troisième un thon y entre de 0,16 au plus pendant 20 pas×thons (un tiers de seconde), sans sortir du creux laissé par le dessin ; 43 à 53 % des thons à portée passent au-dessus.

Premier rocher, debout (segment vertical de hauteur 7), graines 1 à 6 :

| | Avec le rocher | Témoin, sans rocher |
| --- | --- | --- |
| Pas×thons dans le rocher | 0 sur les 6 simulations | 14 728 à 31 772 |
| Distance la plus faible à sa surface | 0,65 à 1,23 | — |
| Rencontres (un thon arrive à portée) | 30 à 40 | 17 à 32 |
| Part des thons à portée qui passent au-dessus | 28 à 44 % | 37 à 42 % |
| Un seul banc sur la dernière minute | 100 % | 100 % |

Le banc ouvre un trou à la place du rocher, puis se reforme. Avec un rocher debout plus haut (11), la part de thons qui passent au-dessus tombe à 8 à 16 % : ils le contournent davantage par les côtés. Les chiffres ne montrent pas que le banc se coupe en deux groupes séparés plus souvent qu'à vide : avec une vision de 8, les deux moitiés restent reliées par les thons qui passent au-dessus ou près du rocher.

### Vision et séparation {#separation}

Choisies par Lou le 8 octobre 2026 (v2.0.0), rampe linéaire validée par Simon. Code : `_voisins()` et `_separation()` dans `godot/thon/thon.gd`.

Vision : le thon `i` voit le thon `j` si `|p_j - p_i| < R` et si `j` n'est pas dans l'angle mort, un cône d'ouverture `α` autour de l'axe arrière `-v_i`. Avec `α = 90°`, le cône s'étend à 45° de chaque côté de cet axe.

Séparation, sur les voisins vus seulement, avec la même rampe linéaire que pour les parois :

`F = Σ normaliser(p_i - p_j) · P(|p_i - p_j|)`, avec `P(δ) = max(0, 1 - δ / d_s)`, puis la force s'ajoute avec le poids `w_s`.

| Symbole | Sens | Variable |
| --- | --- | --- |
| `p_i`, `p_j` | positions du thon et d'un voisin vu | `position` |
| `v_i` | vitesse du thon | `_vitesse` |
| `R` | rayon de vision | `rayon_vision` |
| `α` | angle mort | `angle_mort` |
| `d_s` | distance sous laquelle un voisin repousse | `distance_separation` |
| `w_s` | poids de la séparation | `poids_separation` |

Tous les thons décident avant qu'aucun ne bouge : chaque force est calculée sur les positions du même instant (et, depuis la v2.1.0, sur les vitesses du même instant).

Source : pas d'article, la même rampe que pour les parois. Valeurs : `d_s` = 3, proposition de Claude retenue par Lou. Vision 8, 30 thons et poids 60 choisis par Simon en v2.1.1, d'après les mesures ci-dessous : `godot/mesures/mesure_banc.gd`, 5 minutes simulées, avant le rocher. « Un seul banc » et « paires sous 1,0 » comme dans [Alignement et cohésion](#alignement-cohesion).

| Vision / thons / `w_s` | Graines | Un seul banc | Distance moyenne au plus proche voisin | Pas avec une paire sous 1,0 (sur 18 000) |
| --- | --- | --- | --- | --- |
| 6 / 15 / 30 (v2.1.0) | 1 à 3 | 100 % | 2,51 à 2,55 | 0 |
| 6 / 30 / 30 | 1 à 3 | 22 à 100 % | 2,47 à 2,50 | 0 |
| 8 / 30 / 10 | 1 à 3 | 100 % | 1,86 à 1,90 | 1 391 à 1 994 |
| 8 / 30 / 20 | 1 à 3 | 100 % | 2,24 à 2,25 | 26 à 47 |
| 8 / 30 / 30 | 1 à 6 | 86 à 100 % | 2,45 à 2,51 | 0 à 18 |
| 8 / 30 / 60 | 1 à 6 | 95 à 100 % | 2,68 à 2,70 | 0 à 2 |
| 8 / 30 / 90 | 1 à 6 | 100 % | 2,77 à 2,80 | 0 à 2 |

Retenu : 60. Plus fort que 30, le banc se coupe moins souvent ; à 90, plus de thons dépassent un peu des parois une fois le rocher posé (jusqu'à 49 pas×thons contre 29 à 60). Le virage moyen ne change presque pas (44 à 60 °/s). Avec 30 thons, les positions de départ forment déjà un seul groupe : « premier banc » ne dit plus rien.

### Alignement et cohésion {#alignement-cohesion}

Choisies par Lou le 8 octobre 2026 (v2.1.0), à valider par Simon. Code : `_alignement()` et `_cohesion()` dans `godot/thon/thon.gd`.

Sur les `n` voisins vus par le thon `i` (voir [Vision et séparation](#separation)) :

- Alignement : `F_a = (1 / n) · Σ v_j - v_i`, l'écart entre la vitesse moyenne des voisins et celle du thon.
- Cohésion : `F_c = (1 / n) · Σ p_j - p_i`, du thon vers le centre de ses voisins.

Chacune s'ajoute avec son poids, `w_a` et `w_c`. Sans voisin vu (`n = 0`), les deux valent zéro.

| Symbole | Sens | Variable |
| --- | --- | --- |
| `v_i`, `v_j` | vitesses du thon et d'un voisin vu | `_vitesse` |
| `p_i`, `p_j` | positions du thon et d'un voisin vu | `position` |
| `n` | nombre de voisins vus | `voisins.size()` |
| `w_a` | poids de l'alignement | `poids_alignement` |
| `w_c` | poids de la cohésion | `poids_cohesion` |

L'alignement lit la vitesse des voisins : `decider` range donc la nouvelle vitesse dans `_vitesse_suivante`, et `avancer` l'applique, pour que tous les thons lisent les vitesses du même instant.

Source : les deux règles sont attribuées à Craig Reynolds (alignement, ou *velocity matching*, et cohésion, ou *flock centering*). Référence et noms exacts à vérifier par Lou et Simon avant de les citer.

Valeurs : essais sans fenêtre (Godot 4.7.2), 15 thons, 5 minutes simulées, 3 simulations par couple de poids. Faits par Claude avec `godot/mesures/mesure_banc.gd`, graines 1, 2 et 3 : la commande est en tête du script. « Un seul banc » : part de la dernière minute où tous les thons sont reliés de proche en proche à moins du rayon de vision. « Directions » : longueur de la moyenne des directions, 1 quand tous nagent dans le même sens.

| `w_a` / `w_c` | Un seul banc | Directions | Distance la plus faible entre deux thons | Pas avec une paire sous 1,0 (sur 18 000) |
| --- | --- | --- | --- | --- |
| 0 / 0 | 0 % | 0,22 à 0,26 | 0,57 | 28 à 46 |
| 1 / 1 | 17 à 39 % | 0,55 à 0,62 | 0,89 | 0 à 9 |
| 1 / 3 | 100 % | 0,84 à 0,86 | 0,79 | 9 à 51 |
| 3 / 1 | 50 à 74 % | 0,78 à 0,88 | 1,15 | 0 |
| 3 / 3 | 100 % | 0,95 à 0,96 | 0,88 | 0 à 13 |
| 6 / 1 | 100 % | 0,96 à 0,97 | 1,12 | 0 |
| 6 / 3 | 100 % | 0,97 à 0,98 | 1,01 | 0 |
| 6 / 6 | 100 % | 0,98 | 0,88 | 0 à 72 |

Retenu : 6 et 1, le couple qui forme un seul banc en gardant les thons le plus écartés. Pas d'essai au-delà de 6, et pas encore regardé à l'écran.
