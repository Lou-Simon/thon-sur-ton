# Trailer

*Brainstorm de Simon avec Claude (12 octobre 2026). Simon a choisi le ton et laissé Claude trancher le reste, puis lui a demandé de faire aussi le son et le montage ; Lou doit encore valider. Ce qui reste ouvert est marqué « à décider ».*

Une courte vidéo qui présente le projet : pour ouvrir la soutenance, et comme vidéo de secours si la démo en direct plante (voir la [feuille de route](/feuille-de-route)).

## L'idée

Un **trailer de film catastrophe** : on commence dans le calme, on finit dans la panique, puis le calme revient. C'est l'histoire du projet : un banc paisible, une menace, le banc éclate, puis il se reforme tout seul.

Le montage accélère à mesure que le requin approche, et chaque coupe de l'attaque tombe sur un coup de son grave. Des cartons de texte entre les images restent possibles (voir [Textes affichés](#textes-affiches)).

## Décisions

| Question | Choix |
| --- | --- |
| Ton | Film catastrophe |
| Durée | 73,7 secondes |
| Usage | Ouverture de la soutenance, vidéo de secours, site de doc |
| Images | Filmées dans le jeu, par une scène de tournage qui enchaîne des plans écrits à l'avance (voir [plus bas](#tournage)) |
| Enregistrement | Mode Movie Maker de Godot, en 1920 × 1080 à 60 images par seconde |
| Ralenti | Dans le jeu (le temps tourne au tiers de sa vitesse), pas au montage : l'image reste nette |
| Son | Calculé par un script (ondes et bruit), sans enregistrement ni musique générée par une IA (voir [plus bas](#son)) |
| Montage | Un script qui coupe les plans dans les rushes et les assemble avec ffmpeg (voir [plus bas](#montage)) ; DaVinci Resolve reste possible pour retoucher |
| Bateau de pêche | Absent pour l'instant ; à ajouter quand la [v3.4.0](/versions#v3-4-0) sera finie (à décider : nouveau plan, ou teaser après le générique) |

## Déroulé

Le montage tel qu'il est fait (prise `graine=1`).

| Temps | Image | Son |
| --- | --- | --- |
| 0 – 1 s | Noir | Les vagues montent |
| 1 – 9,3 s | La plongée, du coucher de soleil au fond ; passage sous l'eau à 4 s | Vagues, puis un *plouf* ; la musique s'étouffe d'un coup sous la surface |
| 9,3 – 32,3 s | Le banc, la caméra embarquée, un plan large, le banc au-dessus du rocher | Nappe et arpèges en ré mineur, qui s'ouvrent peu à peu ; bulles |
| 32,3 – 43,3 s | Le requin vu du sable, puis qui arrive sur le banc | La musique s'éteint ; bourdon grave, cœur qui accélère, montée |
| 43,3 – 48,7 s | La charge, en trois coupes rapides | Un cuivre grave, un tambour et un souffle à chaque coupe, des tambours entre les deux |
| 48,7 – 57,7 s | Le banc éclate, au ralenti | Un grand boum, puis tout devient sourd ; le cœur bat lentement |
| 57,7 – 66,7 s | Le banc se reforme | La musique revient, en ré majeur |
| 66,7 – 73,7 s | Carton de fin : logo, titre, sous-titre, puis les crédits | Un dernier cuivre et un dernier boum |

## Tournage {#tournage}

Une scène hors du jeu, `godot/tournage/tournage.tscn`, lance le jeu sans personne aux commandes et enchaîne les plans, puis quitte. On ne touche ni à la souris ni au clavier pendant l'enregistrement.

```bash
# Depuis la racine du dépôt ; le dernier nombre est la graine (1 par défaut)
GODOT=/Applications/Godot.app/Contents/MacOS/Godot sh godot/tournage/tourner.sh 1
```

**Movie Maker** calcule chaque image comme si le jeu tournait à 60 images par seconde, même quand la machine n'y arrive pas : la fenêtre peut ramer, mais la vidéo reste fluide. Il faut compter environ 6 minutes pour 2 minutes de vidéo sur un MacBook Air M2. Changer la `graine`, c'est refaire une prise : les thons partent d'ailleurs et le requin attaque à un autre moment.

Deux pièges :

- Movie Maker filme à la taille de base du projet (1152 × 648) et ignore `--resolution`. Le script crée un fichier `godot/override.cfg`, que Godot lit au lancement, pour passer cette taille à 1920 × 1080 le temps du tournage, puis il l'efface.
- Une fenêtre que macOS ne montre plus (cachée, sur un autre bureau, ou derrière VS Code en plein écran) n'est plus dessinée, et Movie Maker répète alors la dernière image. La fenêtre du tournage reste au premier plan, mais il faut **la laisser visible jusqu'à la fin**. À la fin, le script liste les passages figés (avec ffmpeg) : s'il en trouve, on refait la prise.

Les rushes vont dans `rushes/`, que git ignore (les fichiers pèsent plusieurs gigaoctets). Au début de chaque plan, une ligne donne son temps dans la vidéo : ce sont les repères du montage.

| Plan | Caméra | Commence |
| --- | --- | --- |
| Accueil | Celle de l'accueil | Tout de suite (10 s) |
| Plongée | Celle de la plongée | Comme un clic sur « Plonger » (9,5 s) |
| Le banc | Tourne lentement autour du centre du banc | À la fin de la plongée (12 s) |
| Caméra embarquée | Derrière un thon, elle le suit | Tout de suite (10 s) |
| Le rocher | Fixe, face au rocher | Quand le banc arrive au rocher (15 s) |
| L'ombre | Posée sur le sable devant le requin, elle le regarde passer au-dessus | Tout de suite (8 s) |
| La charge | Derrière le requin | Quand le requin se met à chasser (12 s) |
| Le banc éclate | Sur le côté, entre le requin et le banc, **au ralenti** | Quand le requin en chasse arrive près du banc (12 s) |
| Le banc se reforme | Tourne autour du banc | Tout de suite (15 s) |

Quand un plan attend son moment (40 s au plus), la caméra tourne autour du banc : ce plan large peut toujours servir au montage. Les distances et les durées de la scène de tournage sont des propositions de Claude, à régler en regardant les rushes.

## Le son {#son}

Toute la bande-son est **calculée** par `trailer/sons.py`, à partir d'ondes et de bruit : aucun enregistrement, aucun son récupéré, aucune musique générée par une IA. Pas de licence à citer, et chaque son s'explique en quelques lignes, comme un shader.

| Son | Comment il est fait |
| --- | --- |
| Vagues | Un bruit (« chhh ») dont on ne garde que les graves, et dont le volume monte et descend lentement |
| *Plouf* | Une bouffée de bruit qui s'éteint vite, un coup grave et quelques bulles |
| Bulle | Un sifflement très court dont la note monte |
| Fond marin | Un bruit dont on ne garde que les très graves |
| Nappe | Chaque note jouée par trois ondes en dents de scie un peu désaccordées, adoucies par un filtre |
| Arpège | Des notes pincées (un sinus et son octave, qui s'éteignent vite) sur chaque demi-temps |
| Tambour, cœur | Un sinus qui descend très vite du médium au grave, plus un petit claquement |
| Cuivre grave (« braam ») | Quatre notes graves en dents de scie, saturées, avec un filtre qui se referme |
| Montée, souffle | Un bruit qui passe du grave à l'aigu en gonflant |
| Boum du ralenti | Un sinus très grave qui descend et s'éteint lentement |

La musique est à 96 temps par minute : ré mineur pour le calme (Rém, Si♭, Fa, Do), ré majeur pour la fin (Ré, La, Sim, Sol).

Le passage sous la surface : la musique passe par un filtre passe-bas qui ne laisse d'un coup plus passer que les graves, au moment où l'image traverse l'eau, puis qui s'ouvre peu à peu jusqu'au rocher.

Les instruments, les accords et les volumes sont des propositions de Claude. Comme Claude ne peut pas écouter, ils ont été vérifiés seulement sur le volume de chaque seconde : **à écouter et à régler**.

## Montage {#montage}

`trailer/montage.py` coupe les plans dans les rushes, crée le carton de fin, calcule la bande-son et assemble le tout dans `rushes/trailer.mp4` (environ 3 minutes de calcul).

```bash
# Une seule fois : un environnement Python avec numpy, scipy et Pillow
python3 -m venv .venv && .venv/bin/pip install -r trailer/requirements.txt
# Après le tournage, depuis la racine du dépôt
.venv/bin/python trailer/montage.py
```

La liste des plans (nom, début dans les rushes, durée) est en haut du script : c'est là qu'on change le montage. Les temps sont ceux de la prise `graine=1` ; une autre prise demande de les revoir. La bande-son suit d'elle-même, puisqu'elle se cale sur les plans.

## Textes affichés {#textes-affiches}

Le carton de fin reprend les textes de l'écran d'accueil, déjà validés (voir [Écran de démarrage](/ecran-de-demarrage#textes-affiches)) : titre, sous-titre, crédits et licences.

Des cartons entre les images (pendant la menace, par exemple) sont **à écrire par Lou et Simon**, puis à noter ici une fois validés.

| Moment | Texte |
| --- | --- |
| *à écrire* | |

## Usage de l'IA {#usage-de-l-ia}

Claude a servi au brainstorm (ton, déroulé, choix des outils). À la demande de Simon, il a aussi écrit la scène de tournage, le script de la bande-son et le script de montage, comme le reste du code. Les textes affichés sont ceux de Lou et Simon. À déclarer dans le rapport : l'outil, la date (12 octobre 2026) et ce rôle.

## À décider

- **Le bateau** : nouveau plan, ou teaser après le générique, une fois la [v3.4.0](/versions#v3-4-0) finie.
- **Plan des voisins** : quelques secondes où l'on voit le rayon de vision d'un thon et les liens vers ses voisins. Ce serait l'image la plus parlante pour un SMA, mais il faut du code de dessin en plus.
- **Version courte** : un extrait de 30 secondes pour le site ou un réseau social.
