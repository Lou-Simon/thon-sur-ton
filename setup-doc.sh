#!/usr/bin/env bash
# Crée un site VitePress dans ./doc avec la documentation de Thon sur thon.
# Usage : à lancer à la racine du dépôt :  bash setup-doc.sh
set -euo pipefail
command -v npm >/dev/null || { echo "Installe Node.js (>= 18) d abord."; exit 1; }
mkdir -p doc/.vitepress
cd doc
cat > index.md <<'__FIN__'
---
layout: home
hero:
  name: Thon sur thon
  text: Un banc de thons qui se disperse et se regroupe
  tagline: Projet SMA – M2 ILIADE. Un projet qui ne manque pas de thon.
  actions:
    - theme: brand
      text: Idée générale
      link: /idee-generale
    - theme: alt
      text: Technique mathématique
      link: /technique-mathematique
features:
  - title: Le banc
    details: Chaque thon ne voit que ses voisins. Le banc émerge tout seul.
  - title: Les obstacles
    details: Des algues fixes (V1), puis un obstacle mobile et un prédateur (V2).
  - title: Les agents Claude
    details: Un agent par partie du projet, un relecteur, et vous qui validez.
---
__FIN__
cat > idee-generale.md <<'__FIN__'
# 1. Idée générale

*Projet SMA – M2 ILIADE. Un projet qui ne manque pas de thon.*

Un banc de thons nage dans un grand aquarium en 3D. Un obstacle le traverse, le banc éclate, puis il se reforme tout seul. Aucun thon ne connaît la forme du banc : chacun ne voit que ses voisins proches. Bref, c'est chacun pour soi, mais tous ensemble.

## Le paysage

- Un grand aquarium (un bocal) en 3D, avec des parois qui servent de murs. Pas de fuite possible : ici, on ne met pas les voiles.
- **V1** : des tas d'algues fixes posés sur la route du banc. Il doit se séparer pour les contourner, puis se ressouder derrière. Les algues, elles, ne bougent pas : elles sont restées de marbre (enfin, de varech).
- **V2** : un obstacle qui bouge. D'abord un simple objet qui traverse en ligne droite, puis un vrai prédateur qui chasse. Là, ça va thonner.
- **Plus tard** : des rochers dans l'aquarium, puis éventuellement un courant. On ne va pas tout mettre à l'eau dès le début.

## Les agents

- **Le thon** : 3 règles (ne pas se cogner, nager comme ses voisins, rester près d'eux) et il évite les obstacles. Il n'a pas inventé l'eau chaude, mais il sait rester dans le banc.
- **Le prédateur** (V2) : fonce sur le thon le plus proche. Il n'est pas là pour thonner la main.
- **L'environnement** : l'aquarium, ses parois, les algues (puis les rochers). Le décor, quoi : il ne fait pas de vagues.

## Ce qu'on montre en soutenance

- La démo en direct, avec des curseurs pour changer les réglages. Effet garanti, même sur un jury qui a le thon sec.
- Un graphique : le temps que met le banc à se reformer selon la taille ou la vitesse de l'obstacle.

## Livrables

- La simulation Godot 3D jouable.
- Les mesures en CSV et les graphiques.
- Le rapport et la soutenance, à rendre en temps et en thon.

## À décider

- La date de rendu et qui fait quoi (pas de passager clandestin dans le banc).
__FIN__
cat > technique-mathematique.md <<'__FIN__'
# 2. Technique mathématique

*Promis, pas de quoi se noyer dans les équations.*

Chaque thon ne regarde que ses voisins proches (dans un rayon R, sauf juste derrière lui : il n'a pas d'yeux dans le dos, c'est un thon, pas un hibou). À chaque instant, il additionne 4 forces :

1. **Séparation** : s'écarter des voisins trop proches, pour ne pas se cogner. Chacun son espace vital, même en boîte.
2. **Alignement** : nager dans la même direction que ses voisins. Suivre le mouvement, c'est tout un art.
3. **Cohésion** : se rapprocher du centre de ses voisins. C'est elle qui reforme le banc après l'obstacle : l'union fait la force (et le banc).
4. **Évitement** : fuir un obstacle (algues, prédateur) quand il est proche. Plus il est près, plus la force est forte. Sauve qui peut !

Chaque force a un poids (réglable avec un curseur). La vitesse du thon reste entre un minimum et un maximum : pas de thon au point mort, pas de thon supersonique. Tous les thons bougent en même temps.

## Deux mesures

- **Alignement du banc** : entre 0 (chacun va dans son sens, c'est la foire aux thons) et 1 (tout le monde va dans la même direction).
- **Nombre de sous-groupes** : combien de petits bancs séparés il y a.

Le banc est « reformé » quand il ne reste qu'un seul groupe bien aligné (alignement au-dessus de 0,9). On mesure combien de temps ça prend après le passage de l'obstacle : le temps de se remettre de ses émotions.
__FIN__
cat > technique-claude.md <<'__FIN__'
# 3. Technique Claude (agents)

On code avec Claude Code en donnant chaque partie du projet à un agent spécialisé. Un coordinateur répartit le travail, un relecteur vérifie tout, et c'est vous qui validez. Un vrai banc d'agents, en somme.

| Agent | Son rôle |
| --- | --- |
| Coordinateur | Découpe le travail en petites tâches, lance les autres agents, assemble. C'est le chef de banc. |
| Thon | Les 4 forces du thon et la recherche des voisins. Il connaît son sujet sur le bout des nageoires. |
| Environnement | L'aquarium 3D, ses parois, la caméra, l'affichage (puis les rochers). |
| Obstacles | Les algues (V1), l'obstacle mobile puis le prédateur (V2). Le méchant de l'histoire. |
| Mesures | Alignement, sous-groupes, temps de regroupement, export CSV. Il prend la température de l'eau. |
| Relecteur | Relit chaque changement, cherche les bugs, lance les tests. N'écrit pas de code : il ne laisse rien passer entre les mailles du filet. |

## Comment on s'organise

- Un fichier **CLAUDE.md** qui résume le projet (pages 1 et 2) : tous les agents le lisent, pour que personne ne soit à l'ouest (ni noyé).
- Un fichier d'instructions par agent dans **.claude/agents/** : son rôle et les fichiers qu'il a le droit de toucher. Chacun son bocal.
- Une branche git par tâche : l'agent code, le relecteur vérifie, vous fusionnez.

## Ordre de travail

1. L'aquarium et un banc qui nage sans obstacle.
2. Les algues (V1) et la mesure du temps de regroupement.
3. L'obstacle mobile, puis le prédateur (V2).
4. Les curseurs, les graphiques, puis les rochers.

## Règles d'équipe

- Chacun doit pouvoir expliquer tout le code en soutenance. Pas question de noyer le poisson devant le jury.
- Une tâche = un petit changement qu'on peut vérifier, jamais « fais tout le projet ». On ne met pas la charrue avant les thons.
__FIN__
cat > .vitepress/config.mts <<'__FIN__'
import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'fr-FR',
  title: 'Thon sur thon',
  description: 'Projet SMA – M2 ILIADE : banc de thons, obstacles et émergence',
  themeConfig: {
    nav: [
      { text: 'Accueil', link: '/' },
      { text: 'Doc', link: '/idee-generale' },
    ],
    sidebar: [
      {
        text: 'Documentation',
        items: [
          { text: '1. Idée générale', link: '/idee-generale' },
          { text: '2. Technique mathématique', link: '/technique-mathematique' },
          { text: '3. Technique Claude (agents)', link: '/technique-claude' },
        ],
      },
    ],
    socialLinks: [{ icon: 'github', link: 'https://github.com/Lou-Simon/thon-sur-ton' }],
    outline: { label: 'Sur cette page' },
    docFooter: { prev: 'Page précédente', next: 'Page suivante' },
  },
})
__FIN__
cat > package.json <<'__FIN__'
{
  "name": "thon-sur-thon-doc",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vitepress dev",
    "build": "vitepress build",
    "preview": "vitepress preview"
  }
}
__FIN__
printf 'node_modules/\n.vitepress/cache/\n.vitepress/dist/\n' > .gitignore
npm install -D vitepress
echo
echo "Site prêt. Pour le voir :  cd doc && npm run dev"
