---
name: ship
description: Livre le travail en cours - review du code, vérification des secrets, commit et push, pull request vers la branche de version, puis fusion dans main si demandé. À utiliser quand l'utilisateur tape /ship ou demande de livrer / pousser son travail.
argument-hint: "[main]"
disable-model-invocation: true
---
# /ship

Suis `PRATIQUES-GIT.md` à la lettre. Argument : `$ARGUMENTS` (`main` = fusionner aussi dans `main`).

## 1. État des lieux
- `git status`, `git branch --show-current`, `git fetch`.
- Si on est sur `main` : **stop**, demander sur quelle branche travailler.
- `git pull` de la branche courante. Conflit → le montrer et demander.

## 2. Review du code
- Lire `git diff` et les fichiers non suivis concernés.
- Chercher : bugs évidents, division par zéro, code mort, debug oublié (`print` de test), fichiers générés, code hors sujet.
- Problème bloquant → le lister (`fichier:ligne` + pourquoi) et **stop**. Remarques mineures → les lister et continuer.

## 3. Secrets
- Chercher dans le diff et les fichiers à ajouter : clés API, tokens, mots de passe, clés privées, URL avec identifiants, fichiers `.env`, `*.pem`, `*.key`.
  `git diff HEAD | grep -niE "api[_-]?key|secret|token|password|passwd|BEGIN .*PRIVATE KEY|sk-[a-z0-9]"`
- Le moindre doute → **stop** et demander. Ne jamais committer un secret.

## 4. Commit et push
- Ajouter les fichiers par nom (jamais `git add -A` / `git add .`), sans fichiers générés.
- Découper en plusieurs commits si le diff mélange des sujets différents.
- Message `type: message` en français, < 72 caractères (types dans `PRATIQUES-GIT.md`), avec la ligne `Co-Authored-By` habituelle.
- `git push origin <branche>`. Jamais de `--force`.

## 5. Pull request (seulement depuis une branche `feature/*`)
- Branche cible : la version en cours `vX.Y.Z` de `doc/versions.md`. Si `origin/vX.Y.Z` n'existe pas, ou en cas de doute sur la version → **stop** et demander.
- `gh pr view` : si une PR existe déjà pour la branche, donner son lien et passer à la suite.
- Sinon `gh pr create --base vX.Y.Z --head feature/<nom>`, titre au format d'un commit (`type: message`), description en français : ce qui change, quoi lancer et quoi regarder à l'écran, avec la ligne d'attribution habituelle.
- Ne jamais fusionner la PR (`gh pr merge`) : la relecture et la fusion restent à Lou et Simon.

## 6. Fusion dans `main` (seulement si `$ARGUMENTS` contient `main`)
- Vérifier qu'on est sur une branche `vX.Y.Z`. Sinon **stop**.
- Rappeler que la version doit être validée par Simon et Lou, et demander confirmation.
- `git switch main && git pull && git merge --no-ff vX.Y.Z`, tag `vX.Y.Z`, `git push origin main --tags`, puis revenir sur `vX.Y.Z`. On garde la branche.

## 7. Résumé
3-5 lignes : commits créés, branche poussée, lien de la PR, remarques de review, fusion faite ou non.
