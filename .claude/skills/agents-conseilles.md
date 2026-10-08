# Agents conseillés

Proposition de Claude (2 octobre 2026), à valider par Lou et Simon.

## Trois agents, en second regard

| Agent | Rôle | Droits |
| --- | --- | --- |
| Relecteur | Relit le diff d'une tâche : bugs, code trop compliqué, conventions, et rien au-delà de la version en cours. | Lecture seule |
| Vérificateur | Lance le projet Godot sans fenêtre pour voir s'il démarre sans erreur, puis liste ce qu'il faut regarder à l'œil d'après le « Terminée quand » de la version. | Lance Godot, n'écrit pas de code |
| Explicateur | Explique le code d'une tâche à Lou et Simon, puis pose des questions comme le ferait le jury. | Lecture seule |

## Pas d'agent par partie du code

Thon, Environnement et Obstacles deviennent des skills (formules des forces, conventions GDScript, arborescence de `godot/`) :

- les parties ne sont pas indépendantes : le thon doit connaître les parois, le rocher, le requin et le filet ;
- chaque agent repart de zéro et relit le projet, pour un code qui tient en une dizaine de petits scripts ;
- un code écrit par plusieurs agents est plus dur à expliquer ligne par ligne à l'oral.

Le coordinateur, c'est la session principale.

## À faire si c'est validé

- Écrire les trois agents dans `.claude/agents/`.
- Confirmer la commande Godot du Vérificateur quand `godot/` existera.
- Mettre à jour la ligne des agents de `doc/feuille-de-route.md`.
