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
| Évitement | v1.5.0, v1.7.0, v2.2.0 | Plus le thon s'approche d'une paroi, du sol, d'une plante, d'un corail ou du rocher, plus il est repoussé. | parois et sol : voir [Évitement](#evitement) ; plantes et coraux : voir [Contournement](#contournement) ; rocher : à écrire | choix de Lou et Simon |
| Séparation | v2.0.0 | Le thon s'écarte des voisins trop proches. | voir [Séparation](#separation) | choix de Lou, à valider par Simon |
| Alignement | v2.1.0 | Le thon nage dans la même direction que ses voisins. | à écrire | à renseigner |
| Cohésion | v2.1.0 | Le thon se rapproche du centre de ses voisins. | à écrire | à renseigner |
| Fuite | v3.2.0, v3.4.0 | Un thon qui voit le requin ou le filet s'en éloigne, d'autant plus fort qu'il est proche. | à écrire | à renseigner |

## Les paramètres

| Paramètre | Sert à | Valeur |
| --- | --- | --- |
| Rayon de vision | Distance jusqu'où un thon voit ses voisins. | 6 unités (Lou, 8 oct. 2026, proposition de Claude, à régler à l'écran) |
| Angle mort | Zone derrière le thon où il ne voit pas. | 90° (Lou, 8 oct. 2026, proposition de Claude, à régler à l'écran) |
| Vitesse minimale | Borne basse de la vitesse. | 2 unités/s (Simon, 8 oct. 2026, à ajuster à l'écran) |
| Vitesse maximale | Borne haute de la vitesse. | 5 unités/s (Simon, 8 oct. 2026, à ajuster à l'écran) |
| Portée et poids de l'évitement | Distance où une paroi commence à repousser, et force de la poussée (voir [Évitement](#evitement)). | 4 et 30 (Simon, 8 oct. 2026, d'après des essais) |
| Portée et poids du contournement | Plantes et coraux (voir [Contournement](#contournement)). | 4 et 30, comme les parois (Simon, 8 oct. 2026, d'après des essais) |
| Distance et poids de la séparation | Distance sous laquelle un voisin repousse, et force de la poussée (voir [Séparation](#separation)). | 3 et 30 (Lou, 8 oct. 2026, proposition de Claude, à régler à l'écran) |
| Distance, rayon, hasard de l'errance | Forme de l'errance (voir [Errance](#errance)). | 2, 2 et 3 : proposition de Claude, à régler à l'écran |
| Poids de chaque force | Importance de la force dans la somme. | à fixer |

Les poids, les vitesses et le rayon de vision sont réglables par curseur (v2.3.0).

## Questions à trancher avant de coder
- Évitement des plantes, des coraux et du rocher, et fuite : comment la force grandit quand l'obstacle se rapproche.

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

### Contournement des plantes et des coraux {#contournement}

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

### Vision et séparation {#separation}

Choisies par Lou le 8 octobre 2026 (v2.0.0). Code : `_voisins()` et `_separation()` dans `godot/thon/thon.gd`.

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

Tous les thons décident avant qu'aucun ne bouge : chaque force est calculée sur les positions du même instant.

Source : pas d'article, la même rampe que pour les parois. Valeurs : propositions de Claude retenues par Lou, pas encore essayées à l'écran.
