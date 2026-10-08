# Thon sur thon

<img src="doc/public/logo.png" alt="Logo Thon sur thon" width="250">

Projet SMA – M2 ILIADE : un banc de thons en 3D (Godot) qui se disperse autour d'obstacles puis se reforme.

pas trop verbeux pour le code par IA

## Où trouver quoi

| Fichier | Contenu |
| --- | --- |
| [doc/idee-generale.md](doc/idee-generale.md) | Le projet en bref |
| [doc/versions.md](doc/versions.md) | Contenu et critères de fin de chaque version |
| [doc/feuille-de-route.md](doc/feuille-de-route.md) | Étapes et tâches à cocher |
| [doc/interface.md](doc/interface.md) | Charte d'interface et d'ergonomie (commande `/ui`) |
| [doc/ecran-de-demarrage.md](doc/ecran-de-demarrage.md) | Décor, écran d'accueil et plongée : décisions, avancement, captures |
| [PRATIQUES-GIT.md](PRATIQUES-GIT.md) | Branches, versions, commits |

## Lancer l'application

Ouvrir `godot/` dans Godot 4.7, puis `F5`. L'application s'ouvre sur l'accueil :

- **Plonger** (ou `Entrée`) : la caméra plonge jusqu'à l'aquarium ; un clic passe la plongée.
- Dans l'aquarium : clic gauche + glisser pour tourner, molette pour zoomer, `Z Q S D` (`W A S D` en QWERTY) pour se déplacer, `Origine` pour recentrer, `Tab` pour le panneau.
- `Échap` : remonter à l'accueil. **Quitter** ferme l'application.

Chaque scène se lance aussi seule avec `F6` : `aquarium/aquarium.tscn`, `accueil/accueil.tscn`.

## Voir la doc

```bash
cd doc
npm install
npm run dev
```
