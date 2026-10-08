---
name: tache
description: Déroule une tâche de code du début à la fin - branche feature, agent de code, relecture, vérification, puis livraison. À utiliser quand l'utilisateur tape /tache ou demande de démarrer une tâche de la version en cours.
argument-hint: "<ce qu'il faut faire>"
disable-model-invocation: true
---
# /tache

Suis `PRATIQUES-GIT.md` et `CLAUDE.md` à la lettre. Tâche demandée : `$ARGUMENTS`.

## 1. Cadrer
- Sans argument : **stop**, demander quelle tâche faire.
- Lire `doc/versions.md` : repérer la version en cours `vX.Y.Z` et son « Terminée quand ».
- La tâche appartient à une version future, ou à aucune → le dire et **stop**.
- Résumer en une phrase ce qui va être fait et choisir un nom court pour la branche.

## 2. Branche
- `git status` : s'il reste des modifications non committées → les montrer et **stop**.
- Rappeler de fermer l'éditeur Godot avant de changer de branche.
- `git switch vX.Y.Z && git pull`. Conflit → le montrer et demander.
- `git switch -c feature/<nom-court>`.

## 3. Code
- Confier la tâche à l'agent de la partie concernée :
  - `environnement` : aquarium, sol, lumière, ambiance, caméra ;
  - `thon` : déplacement, forces, vision des voisins ;
  - `obstacles` : rocher, requin, bateau de pêche, filet ;
  - `interface` : curseurs, bouton de relance, valeurs affichées.
- Lui donner la tâche, la version en cours et son « Terminée quand ».
- Plusieurs parties concernées → un agent à la fois, en commençant par ce dont les autres dépendent.
- Si l'agent s'arrête parce qu'il manque une formule ou une valeur : poser la question à Lou ou Simon, ne rien inventer.

## 4. Relecture
- Agent `relecteur` sur le diff.
- Si un design pattern a été utilisé : agent `patterns`.
- Problème bloquant → le faire corriger par l'agent de code, puis relire à nouveau.
- Remarques mineures → les lister et continuer.

## 5. Vérification
- Agent `verificateur` : le projet démarre-t-il, et quoi regarder à l'écran.
- Si `godot/` n'existe pas encore, le dire et passer à l'étape suivante.
- Donner la liste à cocher à Lou ou Simon. **Stop** : attendre qu'ils aient regardé à l'écran.

## 6. Explication
- Expliquer le code écrit, bloc par bloc : ce qu'il fait et pourquoi. Lou et Simon doivent pouvoir justifier chaque ligne à l'oral.
- Signaler ce qui reste à confirmer.

## 7. Livraison
- Pas de commit ici : dire de lancer `/ship`.
- Rappeler ensuite : pull request de `feature/<nom-court>` vers `vX.Y.Z`, puis agent `documentaliste` pour cocher la feuille de route.

## 8. Résumé
3-5 lignes : branche créée, agents passés, remarques de relecture, ce qui reste à regarder ou à confirmer.
