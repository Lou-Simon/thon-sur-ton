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
| Errance | v1.4.0 | Le thon change doucement de direction au hasard. | à écrire | à renseigner |
| Évitement | v1.5.0, v2.2.0 | Plus le thon s'approche d'une paroi, du sol ou du rocher, plus il est repoussé. | à écrire | à renseigner |
| Séparation | v2.0.0 | Le thon s'écarte des voisins trop proches. | à écrire | à renseigner |
| Alignement | v2.1.0 | Le thon nage dans la même direction que ses voisins. | à écrire | à renseigner |
| Cohésion | v2.1.0 | Le thon se rapproche du centre de ses voisins. | à écrire | à renseigner |
| Fuite | v3.2.0, v3.4.0 | Un thon qui voit le requin ou le filet s'en éloigne, d'autant plus fort qu'il est proche. | à écrire | à renseigner |

## Les paramètres

| Paramètre | Sert à | Valeur |
| --- | --- | --- |
| Rayon de vision | Distance jusqu'où un thon voit ses voisins. | à fixer |
| Angle mort | Zone derrière le thon où il ne voit pas. | à fixer |
| Vitesse minimale | Borne basse de la vitesse. | à fixer |
| Vitesse maximale | Borne haute de la vitesse. | à fixer |
| Poids de chaque force | Importance de la force dans la somme. | à fixer |

Les poids, les vitesses et le rayon de vision sont réglables par curseur (v2.3.0).

## Questions à trancher avant de coder
- Séparation : à partir de quelle distance un voisin est « trop proche », et comment la force
  grandit quand il se rapproche.
- Évitement et fuite : comment la force grandit quand l'obstacle se rapproche.
- Somme des forces : simple somme pondérée, ou force totale bornée.
- Vitesse : comment on la ramène entre le minimum et le maximum.
- Un thon sans voisin : quelles forces restent actives.

## Référence
Le modèle des boids est attribué à Craig Reynolds (1987). Référence exacte à vérifier par
Lou et Simon avant de la citer dans le code ou le rapport.

## Pour chaque formule ajoutée
Noter ici : la formule, ce que veut dire chaque symbole, la source, et qui l'a validée.
