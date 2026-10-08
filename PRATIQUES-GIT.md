# Pratiques git

## Branches
- `main` : version stable, celle qu'on rend et qu'on présente. On n'y travaille jamais directement.
- `vX.Y.Z` : branche de travail de la version en cours. Tout y est intégré avant d'aller sur `main`.
- `feature/<nom-court>` : une branche par tâche, créée depuis la branche `vX.Y.Z` à jour (ex. `feature/forces-thon`).

## Numéros de version
`vX.Y.Z` — on augmente un seul chiffre, ceux à sa droite repassent à 0 :
- **X** : grande version, la simulation change (V1 algues → V2 prédateur).
- **Y** : nouvelle fonctionnalité (nouvelle nage de poisson, nouveau prédateur).
- **Z** : correction de bug ou petit réglage.

Version validée -> fusion dans `main`, tag `vX.Y.Z` (on garde la branche).

## Commits
- Petits et ciblés : un commit = un changement qu'on peut expliquer en une phrase.
- Format `type: message`, message en français, au présent, court (< 72 caractères) : `feat: ajoute la force de cohésion`, `fix: corrige la vitesse max du thon`.
- Types :
  - `feat` : nouvelle fonctionnalité
  - `fix` : correction de bug
  - `doc` : documentation (VitePress, README, feuille de route…)
  - `refactor` : réorganisation du code sans changer le comportement
  - `test` : ajout ou modification de tests
  - `perf` : amélioration des performances
  - `chore` : maintenance (config, dépendances, .gitignore…)
- Avant chaque commit : `git status` et `git diff` pour vérifier ce qui part.
- Ajouter les fichiers par nom, jamais `git add -A` ou `git add .` à l'aveugle.
- Ne jamais committer de fichiers générés : `godot/.godot/`, `node_modules/`, `doc/.vitepress/cache|dist` (voir `.gitignore`, à compléter au besoin).

## Intégration
- Une tâche finie -> pull request de `feature/<nom>` vers `vX.Y.Z`, relue avant fusion.
- `vX.Y.Z` -> `main` seulement quand la version est testée et validée par Simon et Lou.
- Supprimer la branche `feature/*` après fusion.

## Règles pour Claude
- Ne jamais committer, pousser ou fusionner sans demande explicite.
- Jamais de `git push --force`, de `reset --hard` ou de réécriture d'historique déjà poussé.
- Ne jamais travailler directement sur `main`.
- En cas de conflit, montrer le conflit et demander plutôt que trancher seul.

## Commande `/ship`
Pour livrer un travail, lancer `/ship` dans Claude Code (`/ship main` pour fusionner aussi dans `main`). Elle :
1. relit le code modifié et signale les problèmes ;
2. vérifie qu'aucun secret (clé, mot de passe, token, `.env`) ne part sur git ;
3. committe avec un message au bon format et pousse la branche ;
4. fusionne dans `main` et pose le tag, seulement si c'est demandé.

Elle respecte toutes les règles de ce document et s'arrête pour demander en cas de doute.
