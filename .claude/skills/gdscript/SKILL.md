---
name: gdscript
description: Conventions GDScript du projet - nommage, typage, ordre dans un script, organisation des scènes et des scripts dans godot/. À lire avant d'écrire ou de relire du code Godot.
---
# Conventions GDScript

Proposition de Claude, à valider par Lou et Simon, puis à compléter au premier script.
Base : le guide de style GDScript officiel de Godot (à vérifier sur
<https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html>).
Ce qui est marqué **(choix du projet)** n'en vient pas.

## Nommage
- Fichiers et dossiers : `snake_case` (`thon.gd`, `thon.tscn`).
- Classes et nœuds : `PascalCase` (`Thon`, `Aquarium`).
- Fonctions et variables : `snake_case` (`vitesse_max`, `calculer_separation()`).
- Constantes : `MAJUSCULES_AVEC_TIRETS_BAS` (`RAYON_VISION`).
- Fonctions et variables internes à un script : préfixe `_` (`_voisins`).
- Signaux : au passé (`thon_capture`).
- Noms en français, sans accent **(choix du projet)** : on les explique en français à l'oral.

## Typage
- Typage statique partout **(choix du projet)** : `var vitesse: Vector3`,
  `func avancer(delta: float) -> void`. L'éditeur signale les erreurs plus tôt, et le type
  dit ce que la variable contient.

## Réglages et valeurs
- Pas de nombre en dur au milieu du code : une constante nommée, ou une variable `@export`.
- Ce qu'un curseur doit régler (poids des forces, vitesses, rayon de vision) est une
  variable `@export` : une seule définition, que l'interface modifie.
- Aucune valeur inventée : une valeur vient de Lou et Simon, ou elle est signalée « à fixer ».

## Ordre dans un script
1. `extends`, `class_name`
2. signaux
3. constantes
4. variables `@export`
5. autres variables
6. variables `@onready`
7. `_ready()`, puis `_process()` ou `_physics_process()`
8. les autres fonctions, la plus générale en premier

## Écriture
- Indentation par tabulations (réglage par défaut de l'éditeur Godot).
- Une fonction fait une seule chose et tient à l'écran.
- Tout déplacement est multiplié par `delta` : la vitesse ne dépend pas du nombre d'images par seconde.
- Un commentaire dit pourquoi, pas ce que la ligne fait déjà.
- Un design pattern est documenté au-dessus du code : nom, rôle ici, raison du choix.

## Organisation de `godot/`
Un dossier par partie, avec la scène et son script côte à côte **(choix du projet, à valider)** :

```
godot/
  aquarium/     parois, sol, lumière, ambiance, caméra
  thon/         thon.tscn, thon.gd
  obstacles/    rocher, requin, bateau, filet
  interface/    curseurs, thème
```

Ces dossiers suivent le découpage des agents `environnement`, `thon`, `obstacles` et `interface`.

## À compléter au premier script
- Confirmer ou corriger l'organisation de `godot/`.
- Noter ici toute convention décidée en cours de route.
