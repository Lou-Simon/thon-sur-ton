# Thon sur thon

Projet SMA – M2 ILIADE (Lou et Simon). Simulation 3D sous Godot 4 d'un banc de thons (boids) dans un aquarium : chaque thon ne voit que ses voisins, le banc contourne un rocher, fuit un requin et un bateau de pêche, puis se reforme. On mesure le temps de regroupement.

Le contenu et le critère de fin de chaque version sont dans `doc/versions.md` : ne coder que ce que demande la version en cours.

## Arborescence

```
godot/                 projet Godot 4.7 (GDScript)
  project.godot
  main.tscn            scène principale
doc/                   site VitePress (en français)
  .vitepress/          config.mts, thème (custom.css)
  public/              logo
  idee-generale.md     le projet en bref
  versions.md          contenu de chaque version vX.Y.Z
  feuille-de-route.md  tâches à cocher
  technique-mathematique.md   forces du thon et mesures
  technique-claude.md  organisation avec les agents
  pratiques-git.md     inclut PRATIQUES-GIT.md (ne pas l'éditer)
.claude/skills/        commandes Claude (/ship)
.claude/agents/        agents Claude Code
PRATIQUES-GIT.md       conventions git (source unique)
setup-doc.sh           script qui a créé le site VitePress
```

Fichiers générés, jamais committés : `godot/.godot/`, `data/`, `node_modules/`, `doc/.vitepress/cache|dist`.

## Commandes

```bash
# Ouvrir le projet dans l'éditeur Godot (godot = chemin de l'exécutable 4.7)
godot --path godot -e
# Lancer la simulation
godot --path godot
# Vérifier que le projet se charge, sans fenêtre
godot --headless --path godot --quit-after 60

# Doc en local
cd doc && npm install && npm run dev
```

## Conventions

- Doc et messages de commit en français.
- Code généré pas trop verbeux.
- Toute modification de la doc passe par les fichiers de `doc/` (sauf les pratiques git : `PRATIQUES-GIT.md`).

@PRATIQUES-GIT.md
