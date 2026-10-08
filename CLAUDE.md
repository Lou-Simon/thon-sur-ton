# Thon sur thon

Projet SMA - M2 ILIADE (Lou et Simon). Simulation 3D sous Godot 4 d'un banc de thons dans un aquarium : chaque thon ne voit que ses voisins, le banc contourne un rocher, fuit un requin et un bateau de pêche, puis se reforme.

Le contenu et le critère de fin de chaque version sont dans `doc/versions.md` : ne coder que ce que demande la version en cours.

## Arborescence

```
doc/                   site VitePress (en français)
  .vitepress/          config.mts, thème (custom.css)
  public/              logo
  idee-generale.md     le projet en bref
  versions.md          contenu de chaque version vX.Y.Z
  feuille-de-route.md  tâches à cocher
  interface.md         charte d'interface et d'ergonomie
  pratiques-git.md     inclut PRATIQUES-GIT.md (ne pas l'éditer)
  memoire/             consignes à lire et à suivre, jamais publiées sur le site
.claude/skills/        commandes Claude (/ship, /ui)
.claude/agents/        agents Claude Code
PRATIQUES-GIT.md       conventions git (source unique)
setup-doc.sh           script qui a créé le site VitePress
```

Fichiers générés, jamais committés : `godot/.godot/`, `node_modules/`, `doc/.vitepress/cache|dist`.

## Commandes

```bash
# Doc en local
cd doc && npm install && npm run dev

# Vérifier que le site se construit (liens cassés compris)
cd doc && npm run build
```

## Conventions

- Doc et messages de commit en français.
- Code généré pas trop verbeux.
- Toute modification de la doc passe par les fichiers de `doc/` (sauf les pratiques git : `PRATIQUES-GIT.md`).

## Interface et ergonomie

Tout ce qui s'affiche (scène 3D, caméra, curseurs, écran de démarrage, site de doc) suit `doc/interface.md`. À relire avant de toucher à l'interface ; `/ui` pour un audit.

- On conçoit pour la soutenance : un jury qui découvre l'application sur un vidéoprojecteur, et une démo faite en direct.
- La simulation d'abord : l'interface ne masque jamais le banc et se replie d'une touche.
- Chaque action a un effet visible immédiat, et on peut toujours revenir en arrière (valeurs par défaut, relancer, recentrer la caméra).
- Un seul `Theme` Godot, des conteneurs et des ancres (jamais de pixels en dur), des touches déclarées dans l'`InputMap`.
- Textes affichés en français, proposés mot pour mot et validés avant d'être écrits.
- Une décision d'interface (contrôle, couleur d'un objet…) se note dans `doc/interface.md`.
- Avant de dire qu'un changement d'interface est fini, dire quoi lancer et quoi regarder à l'écran.

## Usage de l'IA

Projet noté : suivre `doc/memoire/Bon usage des IA.pdf` (à relire en début de session, avec le reste de `doc/memoire/`).

- Code : simple, et expliqué à Lou et Simon, qui doivent pouvoir justifier chaque ligne à l'oral.
- Rapport et textes rendus : aider au plan, à la relecture et à la correction, sans rédiger à leur place.
- Ne jamais inventer une référence, une formule ou un chiffre ; signaler ce qui est à vérifier.
- Modèles 3D : ne jamais aller chercher sur internet un modèle tout fait (thon, requin, bateau, rocher, décor) ; les créer dans le projet.
- Rien de `doc/memoire/` dans la nav, la sidebar ou les liens du site.

@PRATIQUES-GIT.md
