# Idée générale

*Projet SMA – M2 ILIADE.*

Un banc de thons nage dans un grand aquarium en 3D. Un obstacle le traverse, le banc éclate, puis il se reforme tout seul. Aucun thon ne connaît la forme du banc : chacun ne voit que ses voisins proches.

## Le paysage

- Un grand aquarium (un bocal) en 3D, avec des parois qui servent de murs.
- **V1** : un sol de sable, et un seul thon qui nage sans se cogner aux parois.
- **V2** : un rocher posé sur la route du banc. Il doit se séparer pour le contourner, puis se ressouder derrière.
- **V3** : des obstacles qui bougent. Un requin qui chasse, puis un bateau de pêche qui traîne un filet.
- **Plus tard** : plusieurs rochers, des algues, éventuellement un courant.

Le détail de chaque version est dans [Versions](/versions).

## Les agents

- **Le thon** : 3 règles (ne pas se cogner, nager comme ses voisins, rester près d'eux) et il évite les obstacles.
- **Le requin** (V3) : fonce sur le thon le plus proche.
- **Le bateau de pêche** (V3) : traverse l'aquarium en traînant un filet qui attrape les thons trop lents.
- **L'environnement** : l'aquarium, ses parois, le sol de sable, le rocher.

## Ce qu'on montre en soutenance

- La démo en direct, avec des curseurs pour changer les réglages.

## Livrables

- La simulation Godot 3D jouable.
- Le rapport et la soutenance.

## À décider

- La date de rendu et qui fait quoi.