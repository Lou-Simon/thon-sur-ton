---
name: ui
description: Audit de l'interface et de l'ergonomie (scène Godot, curseurs, caméra, écran de démarrage, site de doc), puis propositions d'amélioration. À utiliser quand l'utilisateur tape /ui ou demande de travailler l'interface, l'ergonomie ou l'aspect visuel.
argument-hint: "[scène | fichier | demarrage | doc]"
disable-model-invocation: true
---
# /ui

La référence est `doc/interface.md` : principes, contrôles, couleurs, règles Godot et grille de vérification. La lire en entier avant tout. Argument : `$ARGUMENTS`.

## 1. Cadrer
- Lire la version en cours dans `doc/versions.md` : ne rien proposer qui appartienne à une version future.
- Cible selon l'argument :
  - vide → tout ce qui s'affiche dans la version en cours ;
  - scène ou fichier → cette cible ;
  - `demarrage` → l'écran de démarrage ; s'il n'existe pas, brainstorm à partir des questions de `doc/interface.md` (plusieurs pistes contrastées, avec leurs avantages et inconvénients), sans coder ;
  - `doc` → le site VitePress (`doc/`, hors `doc/memoire/`).
- Si `godot/` n'existe pas encore et que la cible est dans Godot, le dire et proposer `/ui doc` ou `/ui demarrage`.

## 2. Audit
- Lire les scènes (`.tscn`), le `Theme`, les scripts d'interface et `project.godot` (fenêtre, mise à l'échelle, `InputMap`) concernés.
- Pour `doc` : lire les pages, `config.mts` et le thème, et lancer `cd doc && npm run build`.
- Passer chaque ligne de la grille de `doc/interface.md`. Ne pas inventer ce qu'on ne peut pas voir : ce qui demande de lancer l'application est noté « à vérifier à l'écran ».

## 3. Rapport
- Problèmes classés **Bloquant / Gênant / Finition**, chacun avec `fichier:ligne`, ce qui gêne et pour qui (jury, démo, développement).
- Puis les améliorations proposées, de la plus utile à la moins utile, chacune en une phrase avec son coût (petit / moyen / gros).
- Tout texte affiché à l'écran est proposé mot pour mot, pour validation.
- **Stop** : attendre le choix de Lou ou Simon.

## 4. Mise en œuvre (seulement après accord)
- Sur une branche `feature/*`, jamais sur `main`.
- Le code des curseurs et de l'interface de réglage est confié à l'agent `interface`, avec la proposition validée.
- Suivre les règles « Côté Godot » de `doc/interface.md` : `Theme` unique, conteneurs et ancres, actions de l'`InputMap`.
- Code court et simple, que Lou et Simon pourront expliquer à l'oral. Pour chaque choix non évident, l'expliquer dans la réponse.
- Si une décision change la charte (contrôle, couleur d'un objet, choix de l'écran de démarrage), mettre à jour `doc/interface.md` dans la même tâche.
- Pas de commit : c'est `/ship`.

## 5. Vérification
- Dire précisément quoi lancer et quoi regarder à l'écran (fenêtre, plein écran, de loin).
- Pour la doc : `npm run build` sans erreur.
