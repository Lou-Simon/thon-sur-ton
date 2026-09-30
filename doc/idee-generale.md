# Idée générale

*Projet SMA – M2 ILIADE. Un projet qui ne manque pas de thon.*

Un banc de thons nage dans un grand aquarium en 3D. Un obstacle le traverse, le banc éclate, puis il se reforme tout seul. Aucun thon ne connaît la forme du banc : chacun ne voit que ses voisins proches. Bref, c'est chacun pour soi, mais tous ensemble.

## Le paysage

- Un grand aquarium (un bocal) en 3D, avec des parois qui servent de murs. Pas de fuite possible : ici, on ne met pas les voiles.
- : des tas d'algues fixes posés sur la route du banc. Il doit se séparer pour les contourner, puis se ressouder derrière. Les algues, elles, ne bougent pas : elles sont restées de marbre (enfin, de varech).
- un obstacle qui bouge. D'abord un simple objet qui traverse en ligne droite, puis un vrai prédateur qui chasse. Là, ça va thonner.
- des rochers dans l'aquarium, puis éventuellement un courant. On ne va pas tout mettre à l'eau dès le début.

Le détail de chaque version est dans [Versions](/versions).

## Les agents

- **Le thon** : 3 règles (ne pas se cogner, nager comme ses voisins, rester près d'eux) et il évite les obstacles. Il n'a pas inventé l'eau chaude, mais il sait rester dans le banc.
- **Le prédateur** (V2) : fonce sur le thon le plus proche. Il n'est pas là pour thonner la main.
- **L'environnement** : l'aquarium, ses parois, les algues (puis les rochers). Le décor, quoi : il ne fait pas de vagues.

## Ce qu'on montre en soutenance

- La démo en direct, avec des curseurs pour changer les réglages. Effet garanti, même sur un jury qui a le thon sec.
- Un graphique : le temps que met le banc à se reformer selon la taille ou la vitesse de l'obstacle.

## Livrables

- La simulation Godot 3D jouable.
- Les mesures en CSV et les graphiques.
- Le rapport et la soutenance, à rendre en temps et en thon.

## À décider

- La date de rendu et qui fait quoi (pas de passager clandestin dans le banc).