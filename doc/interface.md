# Interface et ergonomie

*Proposition de Claude (8 octobre 2026), à valider par Lou et Simon.*

Cette page est la référence pour tout ce qui s'affiche à l'écran : la scène 3D, les contrôles, les curseurs, l'écran de démarrage, et le site de documentation. La commande [`/ui`](#la-commande-ui) s'appuie sur elle.

## Pour qui on conçoit

- **Le jury, en soutenance** : il découvre l'application sur un vidéoprojecteur, de loin, en quelques minutes. Il doit comprendre ce qu'il voit sans explication.
- **Lou et Simon, en démo** : ils manipulent en direct, sous stress. Chaque action doit être simple, prévisible et réversible.
- **Lou et Simon, en développement** : ils lancent la simulation des dizaines de fois. Pas de clic inutile pour arriver à ce qu'on veut tester.

## Principes

1. **La simulation d'abord.** Le banc est le sujet. L'interface ne le masque jamais et se replie d'une touche.
2. **Chaque action a un effet visible tout de suite.** Un curseur affiche sa valeur et change le comportement en direct, sans redémarrer.
3. **On peut toujours revenir en arrière.** Valeurs par défaut, relancer la simulation, recentrer la caméra : à portée d'une touche ou d'un bouton.
4. **Lisible de loin.** Textes assez grands pour un vidéoprojecteur, bon contraste sur le fond bleu, valeurs arrondies qui ne clignotent pas.
5. **Cohérent.** Un même objet a toujours la même couleur, un même contrôle fait toujours la même chose, d'une scène à l'autre.
6. **Simple à expliquer.** Une interface que Lou et Simon peuvent justifier ligne par ligne à l'oral, plutôt qu'un effet spectaculaire qu'ils ne maîtrisent pas.
7. **En français.** Tous les textes affichés, avec les mêmes mots que la doc (« banc », « rocher », « requin », « filet »).

## Ce qui s'affiche, version par version

Le contenu de chaque version est dans [Versions](/versions) : on ne construit l'interface que de la version en cours.

| Élément | Version | Ce qu'on attend |
| --- | --- | --- |
| Aquarium et ambiance | [v1.0.0](/versions#v1-0-0), [v1.1.0](/versions#v1-1-0) | On distingue le fond, les parois et l'eau, sans que le brouillard noie les thons. |
| Caméra | [v1.2.0](/versions#v1-2-0) | Mouvements doux, zoom borné (ni dans le sol, ni à perte de vue), retour à la vue de départ. |
| Base de l'interface | [v1.3.0](/versions#v1-3-0) | Un seul thème, un panneau qui se replie d'une touche et ne bloque pas la caméra, les contrôles rappelés à l'écran. |
| Thons et banc | [v1.4.0](/versions#v1-4-0) à [v2.2.0](/versions#v2-2-0) | Le sens de nage de chaque thon se lit d'un coup d'œil, et le banc se détache du décor. |
| Curseurs de réglage | [v2.3.0](/versions#v2-3-0) | Nom clair, valeur affichée, bornes sensées, bouton « valeurs par défaut », bouton « relancer ». |
| Requin, bateau, filet | [v3.0.0](/versions#v3-0-0) à [v3.4.0](/versions#v3-4-0) | Le danger se repère immédiatement, le compteur de captures est lisible. |
| Écran de démarrage | à placer | Voir [Écran de démarrage](/ecran-de-demarrage). |

## Contrôles

Les contrôles sont décidés au fil des versions et notés ici, pour rester les mêmes partout et pouvoir les afficher à l'écran.

| Action | Contrôle | Décidé en |
| --- | --- | --- |
| Tourner autour de l'aquarium | clic gauche maintenu + glisser | v1.2.0 |
| Zoomer | molette | v1.2.0 |
| Déplacer le point regardé | touches physiques `W` `S` `A` `D` (`Z` `Q` `S` `D` sur un clavier AZERTY), `Espace` pour monter, `Maj` pour descendre | v1.2.0 |
| Recentrer la caméra | touche physique `Origine` (Home) | v1.2.0 |
| Afficher / masquer l'interface | à définir | v1.3.0 |
| Relancer la simulation | à définir | v2.3.0 |
| Quitter l'application | bouton « Quitter » de l'accueil | écran de démarrage |
| Passer la plongée | clic ou `Entrée` (proposition) | écran de démarrage |
| Revenir à l'accueil | `Échap` (proposition) | écran de démarrage |

## Couleurs et lisibilité

- **Couleurs de l'interface** : celles du logo et du site, le bleu `#1f6fd1` et le jaune `#f2c230`, pour que l'application et la doc se ressemblent.
- **Panneaux** : fond sombre semi-transparent, pour rester lisibles sur l'eau sans cacher la scène.
- **Objets de la scène** : une couleur fixe par objet (thon, requin, filet, rocher), à décider quand l'objet arrive, puis notée ici.
- **Nombres** : arrondis à un nombre fixe de décimales, pour qu'ils ne sautent pas d'une largeur à l'autre.
- **Vérification** : un test réel sur un vidéoprojecteur (ou un écran vu de loin) avant la soutenance.

## Côté Godot

- **Un seul `Theme`** pour toute l'interface (polices, tailles, couleurs) : on change un réglage à un endroit, il change partout.
- **Mise en page par conteneurs** (`VBoxContainer`, `MarginContainer`…) et ancres, jamais de positions en pixels en dur : l'interface tient en fenêtre comme en plein écran.
- **Mise à l'échelle** réglée dans les paramètres du projet pour que l'interface garde sa taille relative quelle que soit la résolution.
- **Touches déclarées dans l'`InputMap`** (actions nommées), pas codées en dur dans les scripts.
- **Les panneaux ne volent pas la souris** : seuls les éléments cliquables captent les clics, le reste laisse passer vers la caméra.
- **Textes regroupés** dans les scènes d'interface, pas éparpillés dans les scripts de simulation.

## Écran de démarrage {#ecran-de-demarrage}

L'application s'ouvre au-dessus de l'eau, puis la caméra plonge vers le banc. Tout est détaillé dans [Écran de démarrage](/ecran-de-demarrage).

## Le site de documentation

Le site est aussi une interface : le jury ou un enseignant peut le parcourir sans nous.

- Une page répond à une question, et son titre le dit.
- Tableaux pour comparer, listes pour énumérer, paragraphes courts.
- Liens entre les pages plutôt que de répéter le même contenu.
- Captures d'écran de la simulation à chaque version terminée.
- Le site doit se construire sans erreur (`cd doc && npm run build`, qui signale aussi les liens cassés) et rester lisible sur mobile et en mode sombre.

## La commande `/ui` {#la-commande-ui}

Dans Claude Code, `/ui` fait un **audit** de l'interface, puis **propose des améliorations**. Rien n'est modifié sans votre accord.

| Commande | Ce qu'elle regarde |
| --- | --- |
| `/ui` | Ce qui s'affiche dans la version en cours |
| `/ui <scène ou fichier>` | Une scène ou un fichier précis |
| `/ui demarrage` | L'écran de démarrage (brainstorm s'il n'existe pas encore) |
| `/ui doc` | Le site de documentation |

Elle passe la grille ci-dessous, classe ce qu'elle trouve, propose des corrections avec les textes à valider, et explique comment vérifier le résultat à l'écran.

## Grille de vérification {#grille}

| Thème | Questions |
| --- | --- |
| Lisibilité | Lisible de loin ? Contraste suffisant sur le fond ? Valeurs arrondies et stables ? |
| Retour | Chaque action a-t-elle un effet visible immédiat ? Chaque curseur affiche-t-il sa valeur ? |
| Récupération | Peut-on revenir aux valeurs par défaut, relancer, recentrer la caméra ? |
| Hiérarchie | La simulation reste-t-elle au premier plan ? L'interface se replie-t-elle ? |
| Cohérence | Mêmes couleurs, mêmes mots, mêmes contrôles qu'ailleurs et que dans cette page ? |
| Robustesse | Tient en fenêtre, en plein écran, à une autre résolution ? Aucun chevauchement ? |
| Démo | Utilisable sous stress, sans manipulation compliquée ? Contrôles rappelés à l'écran ? |
| Simplicité | Le code de l'interface s'explique-t-il facilement à l'oral ? |
| Périmètre | Rien qui appartienne à une version future ? |

Gravité :

- **Bloquant** : gêne la démo ou la compréhension du jury.
- **Gênant** : ralentit ou trompe l'utilisateur, sans bloquer.
- **Finition** : détail visuel.
