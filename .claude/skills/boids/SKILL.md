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
| Évitement | v1.5.0, v1.7.0, v2.2.0 | Plus le thon s'approche d'une paroi, du sol, d'une plante, d'un corail ou du rocher, plus il est repoussé. | parois et sol : voir [Évitement](#evitement) ; plantes, coraux et rocher : à écrire | choix de Lou et Simon |
| Séparation | v2.0.0 | Le thon s'écarte des voisins trop proches. | à écrire | à renseigner |
| Alignement | v2.1.0 | Le thon nage dans la même direction que ses voisins. | à écrire | à renseigner |
| Cohésion | v2.1.0 | Le thon se rapproche du centre de ses voisins. | à écrire | à renseigner |
| Fuite | v3.2.0, v3.4.0 | Un thon qui voit le requin ou le filet s'en éloigne, d'autant plus fort qu'il est proche. | à écrire | à renseigner |

## Les paramètres

| Paramètre | Sert à | Valeur |
| --- | --- | --- |
| Rayon de vision | Distance jusqu'où un thon voit ses voisins. | à fixer |
| Angle mort | Zone derrière le thon où il ne voit pas. | à fixer |
| Vitesse minimale | Borne basse de la vitesse. | 2 unités/s (Simon, 8 oct. 2026, à ajuster à l'écran) |
| Vitesse maximale | Borne haute de la vitesse. | 5 unités/s (Simon, 8 oct. 2026, à ajuster à l'écran) |
| Portée et poids de l'évitement | Distance où une paroi commence à repousser, et force de la poussée (voir [Évitement](#evitement)). | 4 et 30 (Simon, 8 oct. 2026, d'après des essais) |
| Distance, rayon, hasard de l'errance | Forme de l'errance (voir [Errance](#errance)). | 2, 2 et 3 : proposition de Claude, à régler à l'écran |
| Poids de chaque force | Importance de la force dans la somme. | à fixer |

Les poids, les vitesses et le rayon de vision sont réglables par curseur (v2.3.0).

## Questions à trancher avant de coder
- Séparation : à partir de quelle distance un voisin est « trop proche », et comment la force
  grandit quand il se rapproche.
- Évitement des plantes, des coraux et du rocher, et fuite : comment la force grandit quand l'obstacle se rapproche.
- Somme des forces : simple somme pondérée, ou force totale bornée.
- Un thon sans voisin : quelles forces restent actives.

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
