# Pratiques git

## Branches
- `main` : version stable, celle qu'on rend. On n'y travaille jamais directement.
- `v1.0.0` : branche de travail de la version en cours. Tout y est intégré avant d'aller sur `main`.
- `tache/<nom-court>` : une branche par tâche, créée depuis `v1.0.0` à jour (ex. `tache/forces-thon`).

## Commits
- Petits et ciblés : un commit = un changement qu'on peut expliquer en une phrase.
- Message en français, au présent, court (< 72 caractères) : `Ajoute la force de cohésion`, `Corrige la vitesse max du thon`.
- Avant chaque commit : `git status` et `git diff` pour vérifier ce qui part.
- Ajouter les fichiers par nom, jamais `git add -A` ou `git add .` à l'aveugle.
- Ne jamais committer de fichiers générés : `godot/.godot/`, `data/`, `node_modules/`, `doc/.vitepress/cache|dist`.

## Intégration
- Une tâche finie → pull request de `tache/<nom>` vers `v1.0.0`, relue avant fusion.
- `v1.0.0` → `main` seulement quand la version est testée et validée par l'équipe.
- Supprimer la branche `tache/*` après fusion.

## Règles pour Claude
- Ne jamais committer, pousser ou fusionner sans demande explicite.
- Jamais de `git push --force`, de `reset --hard` ou de réécriture d'historique déjà poussé.
- Ne jamais travailler directement sur `main`.
- En cas de conflit, montrer le conflit et demander plutôt que trancher seul.
