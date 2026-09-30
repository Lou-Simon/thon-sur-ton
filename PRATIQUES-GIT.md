# Pratiques git

## Branches
- `main` : version stable, celle qu'on rend et qu'on présente. On n'y travaille jamais directement.
- `vX.Y.Z` : branche de travail de la version en cours. Tout y est intégré avant d'aller sur `main`.
- `tache/<nom-court>` : une branche par tâche, créée depuis la branche `vX.Y.Z` à jour (ex. `tache/forces-thon`).

## Numéros de version
`vX.Y.Z` — on augmente un seul chiffre, ceux à sa droite repassent à 0 :
- **X** : grande version, la simulation change (V1 algues → V2 prédateur).
- **Y** : nouvelle fonctionnalité (curseurs, mesure, export CSV).
- **Z** : correction de bug ou petit réglage.

Version validée → fusion dans `main`, tag `vX.Y.Z`, suppression de la branche.

## Commits
- Petits et ciblés : un commit = un changement qu'on peut expliquer en une phrase.
- Message en français, au présent, court (< 72 caractères) : `Ajoute la force de cohésion`, `Corrige la vitesse max du thon`.
- Avant chaque commit : `git status` et `git diff` pour vérifier ce qui part.
- Ajouter les fichiers par nom, jamais `git add -A` ou `git add .` à l'aveugle.
- Ne jamais committer de fichiers générés : `godot/.godot/`, `data/`, `node_modules/`, `doc/.vitepress/cache|dist`.

## Intégration
- Une tâche finie → pull request de `tache/<nom>` vers `vX.Y.Z`, relue avant fusion.
- `vX.Y.Z` → `main` seulement quand la version est testée et validée par l'équipe.
- Supprimer la branche `tache/*` après fusion.

## Règles pour Claude
- Ne jamais committer, pousser ou fusionner sans demande explicite.
- Jamais de `git push --force`, de `reset --hard` ou de réécriture d'historique déjà poussé.
- Ne jamais travailler directement sur `main`.
- En cas de conflit, montrer le conflit et demander plutôt que trancher seul.
