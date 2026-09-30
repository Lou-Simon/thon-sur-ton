# Technique Claude (agents)

On code avec Claude Code en donnant chaque partie du projet à un agent spécialisé. Un coordinateur répartit le travail, un relecteur vérifie tout, et c'est vous qui validez. Un vrai banc d'agents, en somme.

| Agent | Son rôle |
| --- | --- |
| Coordinateur | Découpe le travail en petites tâches, lance les autres agents, assemble. C'est le chef de banc. |
| Thon | Les 4 forces du thon et la recherche des voisins. Il connaît son sujet sur le bout des nageoires. |
| Environnement | L'aquarium 3D, ses parois, la caméra, l'affichage (puis les rochers). |
| Obstacles | Les algues (V1), l'obstacle mobile puis le prédateur (V2). Le méchant de l'histoire. |
| Mesures | Alignement, sous-groupes, temps de regroupement, export CSV. Il prend la température de l'eau. |
| Relecteur | Relit chaque changement, cherche les bugs, lance les tests. N'écrit pas de code : il ne laisse rien passer entre les mailles du filet. |

## Comment on s'organise

- Un fichier **CLAUDE.md** qui résume le projet (pages 1 et 2) : tous les agents le lisent, pour que personne ne soit à l'ouest (ni noyé).
- Un fichier d'instructions par agent dans **.claude/agents/** : son rôle et les fichiers qu'il a le droit de toucher. Chacun son bocal.
- Une branche git par tâche : l'agent code, le relecteur vérifie, vous fusionnez.

## Ordre de travail

1. L'aquarium et un banc qui nage sans obstacle.
2. Les algues (V1) et la mesure du temps de regroupement.
3. L'obstacle mobile, puis le prédateur (V2).
4. Les curseurs, les graphiques, puis les rochers.

## Règles d'équipe

- Chacun doit pouvoir expliquer tout le code en soutenance. Pas question de noyer le poisson devant le jury.
- Une tâche = un petit changement qu'on peut vérifier, jamais « fais tout le projet ». On ne met pas la charrue avant les thons.
