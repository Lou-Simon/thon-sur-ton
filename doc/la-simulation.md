# La simulation

Cette page explique la simulation dans son ensemble. Le détail de chaque agent est dans [Le thon](/le-thon) et [Le requin](/le-requin).

## Ce qu'il y a dans l'aquarium {#vue-d-ensemble}

![Vue d'ensemble : un aquarium de 40 × 20 × 20, un banc de 30 thons, un requin, un rocher, des plantes et des coraux sur un sol de sable](/schemas/vue-ensemble.png)

- **Deux sortes d'agents** : les thons (30 au lancement) et un requin. Eux seuls perçoivent et décident.
- **Le décor** : les parois, le sol de sable, le rocher, les plantes et les coraux. Il ne bouge pas et ne perçoit rien : les agents l'évitent.
- Les distances sont en unités Godot. Un thon mesure 2, l'aquarium 40 × 20 × 20.

## Qui agit sur qui {#interactions}

![Interactions : un thon s'écarte, s'aligne et se rapproche de ses voisins, fuit le requin, évite le décor ; le requin charge le banc et évite le décor](/schemas/interactions-agents.png)

Une flèche part de celui qui agit. Personne ne donne d'ordre à personne : un thon réagit à ce qu'il voit autour de lui, le requin aussi.

## L'organisation du code {#code}

![Organisation du code : l'aquarium crée les thons, le requin et le décor ; le requin hérite du thon et ajoute la poursuite et l'éloignement](/schemas/organisation-code.svg)

| Script | Rôle |
| --- | --- |
| `godot/aquarium/aquarium.gd` | Crée le requin puis les thons, leur donne ce qu'ils ont le droit de connaître (`installer`), et les fait décider puis avancer à chaque pas. |
| `godot/thon/thon.gd` | Le comportement du thon : sa vision et ses sept forces. |
| `godot/obstacles/requin.gd` | Le requin. Il hérite du thon : il garde sa vision, son errance, son évitement et sa vitesse bornée, et ajoute ses deux états, la poursuite et l'éloignement. |
| `godot/decor/obstacle.gd` | Un obstacle : un segment entouré d'une épaisseur (plante, corail, rocher). |
| `godot/thon/modele_thon.gd` | L'apparence du thon, construite par code. Elle ne change rien au comportement. |

Le thon reçoit la liste de tous les thons, mais il n'y cherche que ses voisins : ceux qu'il voit (voir [Ce qu'il voit](/le-thon#vision)). Le requin reçoit la même liste, sans y figurer.

## Le départ {#etat-initial}

![État initial : 30 thons et 1 requin placés au hasard, direction au hasard ; les thons partent à la vitesse 2, le requin en patrouille](/schemas/etat-initial.png)

- Chaque thon et le requin reçoivent une position et une direction au hasard.
- Un thon part à sa vitesse la plus faible (2). Le requin part en patrouille.
- Personne n'est placé près d'une paroi, du sable ou d'un obstacle : au départ, rien ne repousse personne.
- Le bouton « Relancer » retire les thons et en crée de nouveaux. Le requin, lui, reste où il est.

## Un pas de simulation {#pas}

![Un pas de simulation : tous les thons décident, le requin décide, tous les thons avancent, le requin avance](/schemas/pas-de-simulation.png)

Chaque pas se fait en deux temps (`_physics_process` dans `aquarium.gd`) :

1. **Décider** : chaque thon, puis le requin, calcule sa vitesse suivante et la range à part (`_vitesse_suivante`). Personne ne bouge.
2. **Avancer** : chacun applique cette vitesse et se déplace.

Pourquoi deux temps : avec une seule boucle, le deuxième thon verrait le premier déjà déplacé, et le résultat dépendrait de l'ordre de la liste. Ici, tous décident à partir des positions et des vitesses du même instant.

Le pas est fixe : le hasard de l'errance ne dépend pas du nombre d'images par seconde.

## Ce qui émerge {#emergence}

![Quatre instants d'une même simulation vue de dessus : départ au hasard, tous dans le même sens après 1 s, banc coupé en 2 à 92 s, banc ressoudé à 103 s](/schemas/emergence-banc.png)

Aucun thon ne connaît le banc. Pourtant, à partir de positions au hasard, les thons nagent vite dans le même sens. Le banc se coupe (rocher, requin), puis se ressoude.

![Nombre de groupes au cours du temps sur deux simulations de 5 minutes : le banc passe de 1 à 2 groupes, parfois 3, puis se ressoude](/schemas/groupes-temps.png)

Deux simulations de 5 minutes, avec deux graines de hasard différentes. Un groupe : des thons reliés de proche en proche, à moins du rayon de vision. Le banc est entier 54 % du temps avec la graine 1, 70 % avec la graine 2.

Les chiffres viennent du script de mesure sans fenêtre :

```bash
godot --headless --path godot/ --fixed-fps 60 -s mesures/mesure_banc.gd -- graine=1 n=18000
```
