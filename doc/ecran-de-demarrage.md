# Écran de démarrage

*Brainstorm de Lou et Simon avec Claude (8 octobre 2026). Les choix sont ceux de Lou et Simon ; ce qui reste ouvert est marqué « à décider ».*

C'est la première image que le jury verra. Les règles générales de l'interface sont dans [Interface et ergonomie](/interface).

## L'idée

On ouvre l'application **au-dessus de l'eau** : un ciel, l'horizon, la surface qui ondule. Le titre flotte au-dessus. On clique sur **Plonger** : la caméra descend, traverse la surface, et découvre le fond marin où nage le banc. La simulation commence.

Tout est en **style cartoon**, dans l'esprit du logo : aplats de couleur, bleu nuit, nageoires jaunes, titre au pinceau.

## Décisions

| Question | Choix |
| --- | --- |
| Style visuel | Cartoon, comme le logo |
| Point de départ | Au-dessus de l'eau : ciel, horizon, surface |
| Titre | Grand titre recréé au centre, animé finement ; le logo en petit |
| Boutons | **Plonger** et **Quitter** |
| Crédits | Bandeau discret en bas de l'écran |
| Contenu des crédits | Lou et Simon, M2 ILIADE ; Godot Engine |
| Son | Pas de son pour l'instant |
| Plongée | Longue et cinématique (environ 8 à 10 secondes), qu'on peut passer |
| Aquarium | Océan ouvert : plus d'arêtes visibles, les limites restent invisibles |
| Décor | Rayons de lumière, reflets au sol, bulles et particules, plantes et coraux |
| Calendrier | Nouvelles versions insérées dans la V1 (voir [plus bas](#decoupage)) |

## Maquette

```
┌──────────────────────────────────────────────────────┐
│ [logo]                                               │
│                       ciel                           │
│                                                      │
│               T H O N - S U R - T H O N              │
│                  (titre animé)                       │
│                                                      │
│                    ▸  Plonger                        │
│                       Quitter                        │
│ ~~~~~~~~~~~~~~~~~~ surface de l'eau ~~~~~~~~~~~~~~~~ │
│                                                      │
│  Lou et Simon · M2 ILIADE · Fait avec Godot Engine   │
└──────────────────────────────────────────────────────┘
```

La place exacte du logo, du titre et des boutons est à régler à l'écran.

## La plongée, pas à pas

Durées indicatives, à régler en la voyant.

| Étape | Caméra | À l'écran |
| --- | --- | --- |
| 1. Accueil | Fixe, légère houle | Titre, boutons, crédits |
| 2. Clic sur Plonger | Commence à descendre | Le titre, les boutons et les crédits s'effacent |
| 3. Passage de la surface | Traverse l'eau | La couleur bascule du ciel au bleu de l'eau |
| 4. Descente | Descend vers le fond | Rayons de lumière, bulles, le décor se découvre |
| 5. Arrivée | Rejoint la position de départ de la simulation | La main passe à l'utilisateur |

Un clic ou `Entrée` pendant la plongée la passe : on arrive directement à l'étape 5.

## L'aquarium embelli

Aujourd'hui, l'aquarium se résume à 12 arêtes blanches dans un bleu uni. Il devient un **océan ouvert** :

- **Plus d'arêtes visibles** : les parois restent des limites que les thons évitent, mais on ne les voit pas. Le brouillard efface les bords.
- **Rendu cartoon** : lumière en aplats, couleurs du logo.
- **Rayons de lumière** qui descendent de la surface.
- **Reflets au sol** : les motifs de lumière qui ondulent sur le sable.
- **Bulles et particules** : bulles qui montent, plancton en suspension.
- **Plantes et coraux** : créés par nous, par du code.

Tout le décor est fait dans le projet : aucun modèle 3D, aucune texture ni aucune police récupérés sans en connaître la licence.

## Textes affichés

Proposition, à valider mot pour mot.

| Élément | Texte |
| --- | --- |
| Titre | THON-SUR-THON |
| Bouton | Plonger |
| Bouton | Quitter |
| Crédits | Lou et Simon · M2 ILIADE · Fait avec Godot Engine |

## À décider

- **Police du titre** : une police pinceau sous licence libre, ou un titre dessiné par nous.
- **Sous-titre** : aucun, ou la phrase du site, « Ici, c'est le banc qui donne le thon. »
- **Crédits** : ajouter l'université et l'année ?
- **Logo** : le logo complet contient le logo Godot, qui est sous licence CC BY 4.0. Il faut le citer dans les crédits, ou utiliser une version du logo sans lui.
- **Ciel** : jour, coucher de soleil, nuit ?
- **Fin de la plongée avant la V2** : il n'y a pas encore de banc à découvrir. La caméra arrive sur un thon seul, ou sur le décor ?
- **Plantes et coraux** : simple décor que les thons traversent, ou obstacles à éviter ? (La V2 prévoit des algues comme obstacles seulement « plus tard ».)
- **Retour à l'accueil** : `Échap` dans la simulation ramène-t-il à l'accueil ? Avec une remontée, ou une coupure nette ?
- **Machine de soutenance** : vérifier que le décor reste fluide sur l'ordinateur et le vidéoprojecteur du jour.

## Découpage en versions {#decoupage}

Proposition, à valider puis à reporter dans [Versions](/versions). Ces versions viennent après la [v1.3.0](/versions#v1-3-0), qui apporte le `Theme`, et décalent la suite.

| Version | Contenu | Terminée quand |
| --- | --- | --- |
| Embellir l'aquarium | Océan ouvert, rendu cartoon, rayons de lumière, reflets au sol | L'aquarium ressemble à l'univers du logo. |
| Décor vivant | Bulles, particules, plantes et coraux | L'eau paraît vivante même sans thon. |
| Écran d'accueil | Ciel, surface, titre animé, logo, boutons, crédits | L'application s'ouvre sur l'accueil, et Quitter ferme l'application. |
| La plongée | Descente cinématique de l'accueil vers la simulation | Plonger mène au fond marin en une descente fluide, qu'on peut passer d'un clic. |
