"""Montage du trailer : coupe les plans dans les rushes, ajoute le carton de fin, calcule la
bande-son (sons.py) et assemble le tout dans rushes/trailer.mp4.

À lancer depuis la racine du dépôt, après le tournage (godot/tournage/tourner.sh) :
    .venv/bin/python trailer/montage.py
Il faut ffmpeg, et numpy, scipy et Pillow (trailer/requirements.txt).

Les temps des plans sont ceux de la prise `graine=1` : une autre prise demande de les revoir.
Le choix des plans et leurs durées sont des propositions de Claude, à régler en regardant le trailer.
"""
import subprocess
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy.io import wavfile

import sons

RUSHES = Path("rushes/rushes.avi")
DOSSIER = Path("rushes/montage")
SORTIE = Path("rushes/trailer.mp4")
IMAGES = 60  # images par seconde, comme le tournage
LARGEUR, HAUTEUR = 1920, 1080

# Les plans, dans l'ordre : nom, début dans les rushes (None : pas pris dans les rushes), durée.
# Les durées sont des multiples de 1/60 s : chaque plan fait un nombre entier d'images.
PLANS = [
    ("noir", None, 1.0),
    ("plongee", 10.65, 8.3),  # de l'accueil sans titre ni boutons jusqu'à l'arrivée (19,0 s), avant le panneau
    ("banc", 21.0, 6.0),
    ("embarquee", 33.5, 5.0),
    ("large", 46.5, 5.0),
    ("rocher", 67.0, 7.0),
    ("ombre", 81.0, 6.0),
    ("approche", 111.5, 5.0),  # le requin arrive sur le banc
    ("charge1", 117.6, 1.8),
    ("charge2", 119.4, 1.6),
    ("charge3", 125.3, 2.0),
    ("ralenti", 129.6, 9.0),
    ("reforme", 143.0, 9.0),
    ("fin", None, 7.0),
]
# Moment des rushes où la caméra de la plongée passe sous la surface (trouvé image par image).
SURFACE = 13.617

# Textes du carton de fin : ceux de l'écran d'accueil, validés par Simon le 8 octobre 2026.
TITRE = "THON-SUR-THON"
SOUS_TITRE = "le projet qui vous fait thon-ber par terre"
CREDITS = "Lou et Simon · M2 ILIADE · Fait avec Godot Engine"
LICENCES = "Logo Godot : godotengine.org, CC BY 4.0 · Police Rubik Dirt : SIL Open Font License"

# Couleurs du thème de l'interface (godot/interface/theme.tres) : crème, bleu nuit, bleu.
CREME = (243, 234, 216)
NUIT = (13, 23, 41)
BLEU = (31, 111, 209)
POLICE_TITRE = "godot/interface/polices/RubikDirt-Regular.ttf"
POLICE_TEXTE = "/System/Library/Fonts/Helvetica.ttc"


def ffmpeg(*arguments):
    subprocess.run(["ffmpeg", "-v", "error", "-y", *map(str, arguments)], check=True)


def encoder(sortie, *entree, filtres="null"):
    """Encode une entrée en H.264, 60 images par seconde, sans son : tous les plans ont les mêmes
    réglages, on peut donc les mettre bout à bout sans réencoder."""
    ffmpeg(*entree, "-an", "-filter_complex", f"{filtres},fps={IMAGES},format=yuv420p",
           "-c:v", "libx264", "-preset", "medium", "-crf", "18", sortie)


def carton(avec_credits):
    """Le carton de fin, en image : le logo, le titre, le sous-titre et, si demandé, les crédits,
    sur un dégradé du bleu de l'eau vers le bleu nuit."""
    fond = np.linspace(0, 1, HAUTEUR)[:, None, None] * (np.array(NUIT) - np.array(BLEU) * 0.5) + np.array(BLEU) * 0.5
    image = Image.fromarray(np.repeat(fond, LARGEUR, axis=1).astype(np.uint8))
    logo = Image.open("godot/accueil/logo.png").resize((230, 230), Image.LANCZOS)
    image.paste(logo, ((LARGEUR - 230) // 2, 150), logo)
    dessin = ImageDraw.Draw(image)
    lignes = [(TITRE, POLICE_TITRE, 150, 520), (SOUS_TITRE, POLICE_TITRE, 54, 650)]
    if avec_credits:
        lignes += [(CREDITS, POLICE_TEXTE, 36, 860), (LICENCES, POLICE_TEXTE, 26, 915)]
    for texte, police, taille, y in lignes:
        fonte = ImageFont.truetype(police, taille)
        # Une ombre bleu nuit décalée, puis le texte crème par-dessus, centré.
        dessin.text((LARGEUR / 2 + 5, y + 5), texte, font=fonte, fill=NUIT, anchor="mm")
        dessin.text((LARGEUR / 2, y), texte, font=fonte, fill=CREME, anchor="mm")
    return image


def plan_video(numero, nom, debut, duree):
    """Le fichier vidéo d'un plan, avec ses fondus."""
    sortie = DOSSIER / f"{numero:02d}_{nom}.mp4"
    if nom == "noir":
        encoder(sortie, "-f", "lavfi", "-i", f"color=black:s={LARGEUR}x{HAUTEUR}:r={IMAGES}", "-t", duree)
    elif nom == "fin":
        # Le titre seul, puis les crédits qui apparaissent en fondu ; fondu au noir à la fin.
        carton(False).save(DOSSIER / "carton_titre.png")
        carton(True).save(DOSSIER / "carton_credits.png")
        encoder(sortie, "-loop", "1", "-t", 3.0, "-i", DOSSIER / "carton_titre.png",
                "-loop", "1", "-t", duree - 2.4, "-i", DOSSIER / "carton_credits.png",
                filtres=f"[0]fps={IMAGES}[titre];[1]fps={IMAGES}[credits];"
                        f"[titre][credits]xfade=transition=fade:duration=0.6:offset=2.4,"
                        f"fade=in:st=0:d=0.5,fade=out:st={duree - 1.5}:d=1.5")
    else:
        fondus = {"plongee": "fade=in:st=0:d=1.0", "reforme": f"fade=out:st={duree - 1.0}:d=1.0"}
        # `-ss` avant `-i` avec un réencodage : la coupe tombe sur la bonne image.
        encoder(sortie, "-ss", debut, "-i", RUSHES, "-t", duree, filtres=fondus.get(nom, "null"))
    return sortie


def main():
    DOSSIER.mkdir(parents=True, exist_ok=True)
    # Début et durée de chaque plan dans le montage.
    places, instant = {}, 0.0
    for nom, _, duree in PLANS:
        places[nom] = (instant, duree)
        instant += duree
    duree_totale = instant
    debut_plongee = next(debut for nom, debut, _ in PLANS if nom == "plongee")
    traversee = places["plongee"][0] + SURFACE - debut_plongee

    print(f"Bande-son ({duree_totale:.1f} s)…")
    piste = sons.bande_son(places, duree_totale, traversee)
    wavfile.write(DOSSIER / "bande_son.wav", sons.TAUX, (piste.T * 32767).astype(np.int16))

    fichiers = []
    for numero, (nom, debut, duree) in enumerate(PLANS):
        print(f"Plan {numero + 1}/{len(PLANS)} : {nom}")
        fichiers.append(plan_video(numero, nom, debut, duree))
    liste = DOSSIER / "plans.txt"
    liste.write_text("".join(f"file '{f.name}'\n" for f in fichiers))
    ffmpeg("-f", "concat", "-i", liste, "-c", "copy", DOSSIER / "video.mp4")
    ffmpeg("-i", DOSSIER / "video.mp4", "-i", DOSSIER / "bande_son.wav",
           "-c:v", "copy", "-c:a", "aac", "-b:a", "256k", "-shortest", SORTIE)
    print(f"Trailer : {SORTIE}")


if __name__ == "__main__":
    main()
