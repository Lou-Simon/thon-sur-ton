# Feuille de route

## Étape 1 - Cadrage du projet et git

*Choix et description exhaustive du projet, création du git, mise en place des conventions git.*

- [x] Choisir le sujet (banc de thons, obstacles, émergence)
- [x] Rédiger la doc : idée générale
- [x] Créer le dépôt GitHub et la doc VitePress
- [x] Écrire les conventions git ([pratiques git](/pratiques-git))
- [x] Réfléchir aux différentes versions du projet ([versions](/versions))

## Étape 2 - Environnement de développement

*VS Code, Claude Code, mise en place des agents Claude Code, ajout de skills pertinents.*

- [x] Installer Godot 4 chez tout le monde (même version), VS Code
- [X] Compléter `CLAUDE.md` : description courte du projet, arborescence, commandes
- [ ] Écrire les agents (`.claude/agents/`) : thon, environnement, obstacles, relecteur
- [ ] Écrire les skills (`.claude/skills/`) : workflow d'une tâche, relecture, conventions GDScript, formules boids
- [ ] Tester le workflow sur une petite tâche (ex. scène vide + caméra) : branche → agent → relecture → PR

## Étape 3 - Développement

*Itérations, review de code, documentation via VitePress.*

Une grande version par itération. Chaque petite version `vX.Y.Z` : tâches sur branches `feature/*`, relecture, PR vers la branche de version, validation à deux, fusion dans `main` avec son tag. Le contenu et le critère de fin de chaque version sont dans [versions](/versions).

### V1 — L'aquarium

- [ ] [v1.0.0](/versions#v1-0-0) : projet Godot et aquarium vide
- [ ] [v1.1.0](/versions#v1-1-0) : sol de sable avec du relief, ambiance sous-marine
- [ ] [v1.2.0](/versions#v1-2-0) : caméra qu'on peut déplacer
- [ ] [v1.3.0](/versions#v1-3-0) : un thon qui nage
- [ ] [v1.4.0](/versions#v1-4-0) : le thon évite les parois et le sol

### V2 — Le banc et le rocher

- [ ] [v2.0.0](/versions#v2-0-0) : plusieurs thons qui ne se cognent pas
- [ ] [v2.1.0](/versions#v2-1-0) : les thons forment un banc
- [ ] [v2.2.0](/versions#v2-2-0) : un rocher que le banc contourne
- [ ] [v2.3.0](/versions#v2-3-0) : curseurs de réglage

### V3 — Le requin et le bateau de pêche

- [ ] [v3.0.0](/versions#v3-0-0) : un requin qui nage
- [ ] [v3.1.0](/versions#v3-1-0) : le requin chasse
- [ ] [v3.2.0](/versions#v3-2-0) : les thons fuient le requin
- [ ] [v3.3.0](/versions#v3-3-0) : un bateau de pêche qui traîne un filet
- [ ] [v3.4.0](/versions#v3-4-0) : le filet attrape les thons, qui le fuient

### Si on a le temps

- [ ] Idées pour plus tard (voir [versions](/versions#idees-pour-plus-tard)) : plusieurs rochers et des algues, courant, grille spatiale

### En continu

- [ ] Doc VitePress à jour après chaque itération (choix faits, captures d'écran)
- [ ] Chacun relit et comprend le code des autres parties

## Étape 4 — Rendu, démos et oral

*Review global, travail sur le rendu, les démos et l'oral.*

- [ ] Relecture globale du code, nettoyage, fusion de la dernière version dans `main`
- [ ] Écran de démarrage : brainstorm puis réalisation (voir [interface](/interface#ecran-de-demarrage))
- [ ] Préparer des scénarios de démo (réglages prêts, reproductibles)
- [ ] Enregistrer une vidéo de secours si la démo en direct plante
- [ ] Rapport : modèle, résultats, usage des agents Claude
- [ ] Slides de soutenance + répétition, chacun capable d'expliquer tout le code
