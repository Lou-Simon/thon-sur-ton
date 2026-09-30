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

- [ ] Installer Godot 4 chez tout le monde (même version), VS Code + extension godot-tools
- [ ] Créer le projet Godot vide dans `godot/` et vérifier qu'il se lance chez chacun
- [ ] Mettre en place un lanceur de tests headless (`godot/tests/`) avec un test bidon qui passe
- [ ] Compléter `CLAUDE.md` : description courte du projet, arborescence, commandes
- [ ] Écrire les agents (`.claude/agents/`) : thon, environnement, obstacles, mesures, relecteur
- [ ] Écrire les skills (`.claude/skills/`) : workflow d'une tâche, relecture, conventions GDScript, formules boids, mesures
- [ ] Tester le workflow sur une petite tâche (ex. scène vide + caméra) : branche → agent → relecture → PR

## Étape 3 - Développement

*Itérations, review de code, documentation via VitePress.*

Chaque itération : tâches sur branches `feature/*`, relecture, PR vers la branche de version, mise à jour de la doc. Le contenu détaillé de chaque version est dans [versions](/versions).

### Itération 1 — Un banc qui nage

- [ ] Aquarium 3D : parois, caméra, éclairage
- [ ] Thon : déplacement avec vitesse bornée, évitement des parois
- [ ] Les 3 forces (séparation, alignement, cohésion) + recherche des voisins
- [ ] Test visuel : le banc se forme à partir de positions aléatoires

### Itération 2 — Algues et mesures

- [ ] Algues fixes sur la trajectoire + force d'évitement
- [ ] Mesures : alignement, nombre de sous-groupes
- [ ] Détection « banc reformé » et temps de regroupement
- [ ] Export CSV

### Itération 3 — Obstacle mobile puis prédateur

- [ ] Obstacle qui traverse en ligne droite
- [ ] Prédateur qui chasse le thon le plus proche
- [ ] Campagne de mesures : temps de regroupement selon taille / vitesse de l'obstacle

### Itération 4 — Réglages et bonus

- [ ] Curseurs dans l'interface pour les poids et paramètres
- [ ] Graphiques à partir des CSV (script Python)
- [ ] Performance : grille spatiale si trop de thons
- [ ] Bonus : rochers, courant

### En continu

- [ ] Doc VitePress à jour après chaque itération (choix faits, captures d'écran)
- [ ] Chacun relit et comprend le code des autres parties

## Étape 4 — Rendu, démos et oral

*Review global, travail sur le rendu, les démos et l'oral.*

- [ ] Relecture globale du code, nettoyage, fusion de la dernière version dans `main`
- [ ] Préparer des scénarios de démo (réglages prêts, reproductibles)
- [ ] Enregistrer une vidéo de secours si la démo en direct plante
- [ ] Rapport : modèle, mesures, graphiques, résultats, usage des agents Claude
- [ ] Slides de soutenance + répétition, chacun capable d'expliquer tout le code
