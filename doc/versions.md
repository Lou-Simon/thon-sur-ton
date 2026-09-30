# Versions

Ce que contient chaque version du projet, et quand on la considère comme finie.
Les règles de numérotation (`vX.Y.Z`) sont dans les [pratiques git](/pratiques-git#numeros-de-version).

## Vue d'ensemble

| Grande version | Ce qu'on voit à l'écran |
| --- | --- |
| **V1** — L'aquarium | Un aquarium avec un sol de sable, et un thon qui y nage sans se cogner. |
| **V2** — Le banc et le rocher | Un banc de thons qui se sépare pour contourner un rocher, puis se reforme derrière. |
| **V3** — Le requin et le bateau de pêche | Un requin chasse le banc, qui éclate puis se reforme. Un bateau de pêche traîne un filet que le banc doit éviter. |

Chaque petite version ci-dessous est une étape qu'on peut montrer : on la développe sur sa branche `vX.Y.Z`, on la valide à deux, puis on la fusionne dans `main` avec son tag.

| Version | Étape | État |
| --- | --- | --- |
| [v1.0.0](#v1-0-0) | Projet Godot et aquarium vide | En cours |
| [v1.1.0](#v1-1-0) | Sol de sable avec du relief, ambiance sous-marine | À faire |
| [v1.2.0](#v1-2-0) | Caméra qu'on peut déplacer | À faire |
| [v1.3.0](#v1-3-0) | Un thon qui nage | À faire |
| [v1.4.0](#v1-4-0) | Le thon évite les parois et le sol | À faire |
| [v2.0.0](#v2-0-0) | Plusieurs thons qui ne se cognent pas | À faire |
| [v2.1.0](#v2-1-0) | Les thons forment un banc | À faire |
| [v2.2.0](#v2-2-0) | Un rocher que le banc contourne | À faire |
| [v2.3.0](#v2-3-0) | Mesures du banc | À faire |
| [v2.4.0](#v2-4-0) | Temps de regroupement et export CSV | À faire |
| [v2.5.0](#v2-5-0) | Curseurs de réglage | À faire |
| [v3.0.0](#v3-0-0) | Un requin qui nage | À faire |
| [v3.1.0](#v3-1-0) | Le requin chasse | À faire |
| [v3.2.0](#v3-2-0) | Les thons fuient le requin | À faire |
| [v3.3.0](#v3-3-0) | Un bateau de pêche qui traîne un filet | À faire |
| [v3.4.0](#v3-4-0) | Le filet attrape les thons, qui le fuient | À faire |
| [v3.5.0](#v3-5-0) | Campagne de mesures et graphiques | À faire |

## V1 — L'aquarium

**But** : un décor sous-marin crédible et un thon qui s'y déplace seul, sans jamais traverser une paroi ni le sol.

### v1.0.0 — Projet Godot et aquarium vide {#v1-0-0}

- Projet Godot 4 dans `godot/`, qui se lance chez chacun.
- Scène principale : un aquarium en forme de boîte, avec des parois (invisibles ou en verre) et une lumière.

**Terminée quand** : on lance le projet et on voit l'aquarium vide.

### v1.1.0 — Sol de sable et ambiance {#v1-1-0}

- Sol de sable avec un peu de relief (petites dunes).
- Ambiance sous-marine : couleur bleutée, brouillard qui s'épaissit avec la distance.

**Terminée quand** : l'aquarium ressemble à un fond marin.

### v1.2.0 — Caméra {#v1-2-0}

- Caméra qui tourne autour de l'aquarium, avec zoom à la souris.

**Terminée quand** : on peut regarder l'aquarium sous tous les angles.

### v1.3.0 — Un thon qui nage {#v1-3-0}

- Un thon (forme simple au début) qui avance, orienté dans le sens de sa nage.
- Vitesse bornée entre un minimum et un maximum.
- Petite errance : le thon change doucement de direction au hasard.

**Terminée quand** : le thon nage de façon fluide, même s'il finit par sortir de l'aquarium.

### v1.4.0 — Le thon évite les parois et le sol {#v1-4-0}

- Force d'évitement : plus le thon s'approche d'une paroi ou du sol, plus il est repoussé.

**Terminée quand** : le thon nage plusieurs minutes sans jamais sortir ni toucher le sol.

## V2 — Le banc et le rocher

**But** : plusieurs thons forment un banc, se séparent pour contourner un rocher, puis se remettent en banc derrière.
Les règles du banc sont détaillées dans la [technique mathématique](/technique-mathematique).

### v2.0.0 — Plusieurs thons qui ne se cognent pas {#v2-0-0}

- N thons placés au hasard (N réglable).
- Chaque thon ne voit que ses voisins proches (rayon de vision, angle mort derrière lui).
- Force de **séparation** : un thon s'écarte des voisins trop proches.

**Terminée quand** : les thons nagent ensemble sans se rentrer dedans.

### v2.1.0 — Les thons forment un banc {#v2-1-0}

- Force d'**alignement** : nager dans la même direction que ses voisins.
- Force de **cohésion** : se rapprocher du centre de ses voisins.

**Terminée quand** : en partant de positions au hasard, les thons finissent en un seul banc.

### v2.2.0 — Un rocher que le banc contourne {#v2-2-0}

- Un rocher placé sur la trajectoire du banc.
- Les thons l'évitent avec la même force d'évitement que pour les parois.

**Terminée quand** : le banc se sépare autour du rocher puis se reforme derrière.

### v2.3.0 — Mesures du banc {#v2-3-0}

- **Alignement** du banc : de 0 (chacun va dans son sens) à 1 (tout le monde va dans la même direction).
- **Nombre de sous-groupes** : combien de petits bancs séparés il y a.
- Affichage des deux valeurs à l'écran.

**Terminée quand** : les valeurs affichées changent quand le banc passe le rocher.

### v2.4.0 — Temps de regroupement et export CSV {#v2-4-0}

- Détection « banc reformé » : un seul groupe et alignement supérieur à 0,9.
- Mesure du temps entre le passage du rocher et le regroupement.
- Export des mesures en CSV.

**Terminée quand** : chaque passage du rocher écrit une ligne dans le CSV avec son temps de regroupement.

### v2.5.0 — Curseurs de réglage {#v2-5-0}

- Curseurs pour les poids des forces, la vitesse min / max et le rayon de vision.
- Bouton pour relancer avec de nouvelles positions au hasard.

**Terminée quand** : chaque curseur change le comportement en direct, sans redémarrer.

## V3 — Le requin et le bateau de pêche

**But** : un requin chasse les thons, et un bateau de pêche traîne un filet dans l'aquarium. Le banc éclate à l'approche du danger, puis se reforme une fois qu'il est passé.

### v3.0.0 — Un requin qui nage {#v3-0-0}

- Un requin qui erre dans l'aquarium en évitant les parois, le sol et le rocher.
- Il est plus gros que les thons et a sa propre vitesse max.

**Terminée quand** : le requin nage au milieu du banc (les thons ne le fuient pas encore).

### v3.1.0 — Le requin chasse {#v3-1-0}

- Le requin fonce sur le thon le plus proche qu'il voit.
- Règle en cas de capture : le thon disparaît, ou on compte seulement les captures.

**Terminée quand** : le requin poursuit les thons et les captures sont comptées.

### v3.2.0 — Les thons fuient le requin {#v3-2-0}

- Force de **fuite** : un thon qui voit le requin s'en éloigne, d'autant plus fort qu'il est proche.

**Terminée quand** : le banc éclate à l'approche du requin puis se reforme après son passage.

### v3.3.0 — Un bateau de pêche qui traîne un filet {#v3-3-0}

- Un bateau de pêche qui avance à la surface, d'un bout à l'autre de l'aquarium, puis repart.
- Il traîne derrière lui un filet : une zone sous l'eau (une nappe ou une poche) qui suit le bateau.

**Terminée quand** : le bateau traverse l'aquarium avec son filet, sans que les thons réagissent encore.

### v3.4.0 — Le filet attrape les thons, qui le fuient {#v3-4-0}

- Un thon qui entre dans le filet est capturé : il disparaît et on compte les prises.
- Force de **fuite** face au filet, comme pour le requin : un thon qui voit le filet s'en éloigne.

**Terminée quand** : le banc s'écarte au passage du filet, et les thons trop lents sont comptés comme pêchés.

### v3.5.0 — Campagne de mesures et graphiques {#v3-5-0}

- Plusieurs simulations lancées à la suite, sans affichage, en faisant varier un paramètre (taille du rocher, vitesse du requin, vitesse du bateau, nombre de thons…).
- Script Python qui lit les CSV et trace le temps de regroupement selon ce paramètre.

**Terminée quand** : une seule commande produit les graphiques de la soutenance.

## Idées pour plus tard

Seulement si V3 est finie et validée :
- plusieurs rochers et des algues dans l'aquarium ;
- un courant qui pousse les thons dans une direction ;
- une grille spatiale pour accélérer la recherche des voisins s'il y a beaucoup de thons.

## Corrections

Une correction de bug ou un petit réglage sur une version augmente le dernier chiffre (`v1.3.1`, `v1.3.2`…). Pas besoin de les lister ici : les commits `fix:` suffisent.
