"""Bande-son du trailer, calculée de zéro : des ondes et du bruit, sans aucun enregistrement.

Chaque son est une fonction qui rend un tableau d'échantillons (mono, entre -1 et 1).
`bande_son` les pose aux temps des plans du montage, que lui donne montage.py.
Les instruments, les accords et les volumes sont des propositions de Claude, à régler à l'écoute.
"""
import numpy as np
from scipy.signal import butter, sosfilt, sosfilt_zi

TAUX = 48000  # échantillons par seconde
# Tempo de la musique : 96 temps par minute, une mesure de 4 temps dure 2,5 s.
TEMPS = 60 / 96
MESURE = 4 * TEMPS

# Accords du calme (ré mineur : Rém, Si♭, Fa, Do) et de la fin (ré majeur : Ré, La, Sim, Sol).
# Numéros MIDI : 60 = do du milieu du piano. Chaque accord : trois notes, puis la basse.
ACCORDS_CALME = [([50, 53, 57], 38), ([50, 53, 58], 34), ([48, 53, 57], 41), ([48, 52, 55], 36)]
ACCORDS_FIN = [([50, 54, 57], 38), ([49, 52, 57], 33), ([50, 54, 59], 35), ([50, 55, 59], 31)]

hasard = np.random.default_rng(1)


# --- Outils ---------------------------------------------------------------------------------------

def temps(duree):
    """Les instants de chaque échantillon, en secondes, sur `duree` secondes."""
    return np.arange(int(duree * TAUX)) / TAUX


def hz(midi):
    """Fréquence d'une note MIDI : le la 69 vaut 440 Hz, chaque demi-ton multiplie par 2^(1/12)."""
    return 440.0 * 2 ** ((np.asarray(midi) - 69) / 12)


def filtre(x, coupure, genre="low", ordre=2):
    """Filtre de Butterworth : `low` garde les graves, `high` les aigus, `band` une bande [bas, haut]."""
    return sosfilt(butter(ordre, coupure, genre, fs=TAUX, output="sos"), x)


def passe_bas_variable(x, coupures, bloc=256):
    """Passe-bas dont la coupure change avec le temps (`coupures` : une valeur par échantillon).
    On filtre par petits blocs de coupure fixe, en gardant la mémoire du filtre d'un bloc à l'autre."""
    sortie = np.empty_like(x)
    memoire = None
    for debut in range(0, len(x), bloc):
        sos = butter(2, float(coupures[debut]), "low", fs=TAUX, output="sos")
        if memoire is None:
            memoire = sosfilt_zi(sos) * 0.0
        sortie[debut:debut + bloc], memoire = sosfilt(sos, x[debut:debut + bloc], zi=memoire)
    return sortie


def bruit(duree):
    """Bruit blanc : toutes les fréquences au même niveau (un « chhh »)."""
    return hasard.standard_normal(int(duree * TAUX))


def scie(t, freq):
    """Onde en dents de scie, riche en harmoniques : la base des sons de cuivre et des nappes.
    La phase de départ est tirée au hasard, pour que les notes empilées ne s'additionnent pas en pointe."""
    return 2.0 * ((t * freq + hasard.random()) % 1.0) - 1.0


def sinus_glissant(t, freq):
    """Sinus dont la fréquence (un tableau, une valeur par échantillon) change : on cumule la phase."""
    return np.sin(2 * np.pi * np.cumsum(freq) / TAUX)


def enveloppe(n, attaque, relache):
    """Monte en `attaque` secondes, tient, puis redescend en `relache` secondes."""
    env = np.ones(n)
    a, r = min(int(attaque * TAUX), n), min(int(relache * TAUX), n)
    env[:a] = np.linspace(0, 1, a)
    env[n - r:] *= np.linspace(1, 0, r)
    return env


def ajouter(son, morceau, i):
    """Ajoute `morceau` à `son` à partir de l'échantillon `i`, en coupant ce qui dépasse la fin."""
    fin = min(len(son), i + len(morceau))
    if fin > i:
        son[i:fin] += morceau[: fin - i]


def poser(piste, son, debut, gain=1.0, pan=0.0):
    """Ajoute un son mono à la piste stéréo, à partir de `debut` secondes.
    `pan` : -1 à gauche, 0 au milieu, 1 à droite (à puissance constante)."""
    i = int(debut * TAUX)
    son = son[: max(0, piste.shape[1] - i)]
    angle = (pan + 1) * np.pi / 4
    piste[0, i:i + len(son)] += son * gain * np.cos(angle)
    piste[1, i:i + len(son)] += son * gain * np.sin(angle)


# --- Bruitages ------------------------------------------------------------------------------------

def vagues(duree):
    """La houle : un bruit sourd dont le volume monte et descend lentement, comme des vagues."""
    t = temps(duree)
    houle = (0.5 + 0.5 * np.sin(2 * np.pi * 0.13 * t + hasard.random() * 6)) ** 3
    return filtre(bruit(duree), 900) * (0.3 + 0.7 * houle)


def bulle():
    """Une bulle : un sifflement très court dont la note monte."""
    duree = hasard.uniform(0.04, 0.08)
    t = temps(duree)
    depart = hasard.uniform(500, 1400)
    return sinus_glissant(t, depart * (1 + 1.5 * t / duree)) * np.exp(-t / 0.015)


def tambour(haut=110, bas=45, duree=0.6, tenue=0.18):
    """Un coup de tambour grave : un sinus qui descend très vite de `haut` à `bas` Hz, plus un claquement."""
    t = temps(duree)
    corps = sinus_glissant(t, bas + (haut - bas) * np.exp(-t / 0.04)) * np.exp(-t / tenue)
    claque = bruit(duree) * np.exp(-t / 0.008) * 0.3
    return corps + claque


def plouf():
    """La caméra traverse la surface : une gerbe d'eau, un coup sourd, puis des bulles."""
    t = temps(1.2)
    gerbe = filtre(bruit(1.2), [400, 2500], "band") * np.exp(-t / 0.3) * 1.5
    son = gerbe + tambour(90, 40, 1.2) * 0.8
    for _ in range(14):
        ajouter(son, bulle() * hasard.uniform(0.1, 0.3), int(hasard.uniform(0.1, 1.0) * TAUX))
    return son


def fond_marin(duree):
    """Le fond sous l'eau : un grondement très grave (un bruit dont on ne garde que les graves)."""
    return filtre(bruit(duree), 200, ordre=4)


def coeur(duree, rythme_debut, rythme_fin):
    """Des battements de cœur (« boum-boum ») dont le rythme passe de `rythme_debut` à `rythme_fin`
    battements par minute. Rend un tableau de `duree` secondes."""
    son = np.zeros(int(duree * TAUX))
    instant = 0.0
    while instant < duree - 0.5:
        rythme = rythme_debut + (rythme_fin - rythme_debut) * instant / duree
        for decalage, force in ((0.0, 1.0), (0.2, 0.6)):
            ajouter(son, tambour(70, 38, 0.4, 0.09) * force, int((instant + decalage) * TAUX))
        instant += 60 / rythme
    return son


def souffle(duree=0.5):
    """Un « whoosh » : un bruit dont la couleur passe du grave à l'aigu, qui gonfle puis retombe."""
    t = temps(duree)
    coupures = 300 * (6000 / 300) ** (t / duree)
    return passe_bas_variable(bruit(duree), coupures) * np.sin(np.pi * t / duree) ** 2


def montee(duree):
    """La montée avant l'attaque : un bruit de plus en plus aigu et fort, avec une note qui grimpe."""
    t = temps(duree)
    part = t / duree
    souffle_ = passe_bas_variable(bruit(duree), 150 * (8000 / 150) ** part) * part ** 2
    sirene = sinus_glissant(t, 80 * (900 / 80) ** part) * part ** 3 * 0.3
    return souffle_ + sirene


def boum(duree=4.0):
    """Le grand boum du ralenti : un sinus très grave qui descend et s'éteint lentement, plus un souffle."""
    t = temps(duree)
    grave = sinus_glissant(t, 28 + 30 * np.exp(-t / 0.3)) * np.exp(-t / 1.5)
    souffle_ = filtre(bruit(duree), 400) * np.exp(-t / 0.5) * 2
    return np.tanh(1.5 * (grave + souffle_))


# --- Instruments ----------------------------------------------------------------------------------

def nappe(notes, duree, coupure=1200):
    """Une nappe : chaque note jouée par trois dents de scie un peu désaccordées, adoucies par un
    passe-bas. Le léger désaccord fait onduler le son, comme un ensemble de cordes."""
    t = temps(duree)
    son = np.zeros(len(t))
    for note in notes:
        for desaccord in (-0.08, 0.0, 0.08):
            son += scie(t, hz(note + desaccord))
    son = filtre(son, coupure) / (3 * len(notes))
    return son * enveloppe(len(t), 0.8, 1.2)


def pincee(note, duree=0.7):
    """Une note pincée (comme une harpe) : un sinus et son octave, qui s'éteignent vite."""
    t = temps(duree)
    f = hz(note)
    son = np.sin(2 * np.pi * f * t) + 0.3 * np.sin(4 * np.pi * f * t)
    return son * np.exp(-t / 0.25) * enveloppe(len(t), 0.005, 0.05)


def braam(duree=2.5, coupure=2500):
    """Le gros cuivre des bandes-annonces : ré grave, ré, la et fa empilés en dents de scie, saturés,
    avec un filtre qui se referme pendant que le son s'éteint."""
    t = temps(duree)
    son = sum(scie(t, hz(n + d)) for n in (26, 38, 45, 53) for d in (-0.1, 0.1))
    son = np.tanh(0.8 * son)
    son = passe_bas_variable(son, coupure * (250 / coupure) ** (t / duree))
    return son * np.exp(-t / (duree / 3)) * enveloppe(len(t), 0.02, 0.3)


def musique(debut, fin, accords, arpege=True):
    """La musique d'un passage : un accord par mesure, en nappe, avec sa basse et, si `arpege`,
    des notes pincées sur chaque demi-temps (les trois notes de l'accord, une octave plus haut)."""
    duree = fin - debut
    son = np.zeros(int(duree * TAUX) + TAUX)
    for k in range(int(np.ceil(duree / MESURE))):
        notes, basse = accords[k % len(accords)]
        instant = k * MESURE
        morceau = nappe(notes, MESURE + 1.0) * 0.6 + nappe([basse], MESURE + 1.0, 400) * 0.5
        ajouter(son, morceau, int(instant * TAUX))
        if arpege:
            for pas, rang in enumerate([0, 1, 2, 1, 0, 1, 2, 1]):
                ajouter(son, pincee(notes[rang] + 12) * 0.25, int((instant + pas * TEMPS / 2) * TAUX))
    return son[: int(duree * TAUX)]


# --- La bande-son ---------------------------------------------------------------------------------

def bande_son(plans, duree, traversee):
    """Toute la bande-son, en stéréo. `plans` : pour chaque nom de plan, son début et sa durée dans
    le montage, en secondes. `traversee` : le moment où la caméra passe sous la surface."""
    piste = np.zeros((2, int(duree * TAUX)))
    debut = {nom: p[0] for nom, p in plans.items()}
    fin = {nom: p[0] + p[1] for nom, p in plans.items()}

    # 1. Au-dessus de l'eau : les vagues, coupées net par le plouf.
    for pan in (-0.3, 0.3):  # deux houles différentes, à gauche et à droite : le son s'élargit
        poser(piste, vagues(traversee) * enveloppe(int(traversee * TAUX), 1.5, 0.05), 0.0, 0.35, pan)
    poser(piste, plouf(), traversee, 0.5)

    # 2. Sous l'eau, jusqu'à la fin : le grondement et des bulles au hasard.
    sous_eau = fin["reforme"] - traversee
    poser(piste, fond_marin(sous_eau) * enveloppe(int(sous_eau * TAUX), 0.3, 1.5), traversee, 0.5)
    instant = traversee + 1.0
    while instant < fin["reforme"] - 1.0:
        poser(piste, bulle(), instant, hasard.uniform(0.03, 0.1), hasard.uniform(-0.8, 0.8))
        instant += hasard.exponential(0.4)

    # 3. Le calme : la musique commence au-dessus de l'eau, s'étouffe d'un coup sous la surface
    # (on n'entend plus que les graves), puis s'ouvre peu à peu jusqu'au rocher.
    calme_debut, calme_fin = debut["plongee"], debut["ombre"] + 0.5
    calme = musique(calme_debut, calme_fin, ACCORDS_CALME)
    t = temps(calme_fin - calme_debut) + calme_debut
    coupures = np.where(t < traversee, 6000.0,
                        np.interp(t, [traversee, debut["banc"], fin["rocher"]], [350.0, 350.0, 5000.0]))
    calme = passe_bas_variable(calme, coupures)
    calme *= enveloppe(len(calme), 2.0, 1.0)
    poser(piste, calme, calme_debut, 0.5, -0.1)

    # 4. La menace : presque le silence, un bourdon grave qui gonfle, le cœur qui accélère, la montée.
    menace_debut, menace_fin = debut["ombre"] + 0.8, debut["charge1"]
    n = menace_fin - menace_debut
    bourdon = nappe([26, 33], n + 1.2, 300)[: int(n * TAUX)] * np.linspace(0.4, 1.0, int(n * TAUX))
    poser(piste, bourdon, menace_debut, 0.3)
    poser(piste, coeur(n - 0.3, 60, 120) * np.linspace(0.4, 1.0, int((n - 0.3) * TAUX)), menace_debut + 0.3, 0.35)
    poser(piste, montee(plans["approche"][1] - 0.25), debut["approche"], 0.35)

    # 5. L'attaque : un cuivre, un tambour et un whoosh à chaque coupe, des tambours entre les deux.
    for nom in ("charge1", "charge2", "charge3"):
        poser(piste, braam(2.2), debut[nom], 0.55)
        poser(piste, tambour(140, 40, 0.9, 0.3), debut[nom], 0.9)
        poser(piste, souffle(0.45), debut[nom] - 0.2, 0.25, hasard.uniform(-0.6, 0.6))
    double = TEMPS / 2 * 96 / 140  # une croche à 140 temps par minute
    instant, pas = debut["charge1"], 0
    while instant < debut["ralenti"] - 0.1:
        if pas % 4 != 0:  # les temps forts sont déjà joués par le tambour de la coupe
            poser(piste, tambour(120, 50, 0.4, 0.1), instant, 0.35 if pas % 2 else 0.5, 0.2 * (-1) ** pas)
        instant += double
        pas += 1

    # 6. Le ralenti : un grand boum, puis tout devient sourd ; le cœur bat lentement.
    poser(piste, boum(5.0), debut["ralenti"], 1.0)
    duree_ralenti = plans["ralenti"][1]
    sourd = nappe([38, 45, 50], duree_ralenti + 0.5, 450) * enveloppe(int((duree_ralenti + 0.5) * TAUX), 1.5, 2.5)
    poser(piste, sourd, debut["ralenti"] + 0.5, 0.7)
    poser(piste, coeur(duree_ralenti - 2.0, 45, 45), debut["ralenti"] + 1.5, 0.6)
    poser(piste, montee(2.0) * 0.5, fin["ralenti"] - 2.0, 0.4)

    # 7. Le banc se reforme : la musique revient, en majeur, et passe sur le carton de fin.
    lumiere = musique(debut["reforme"], duree, ACCORDS_FIN)
    lumiere *= enveloppe(len(lumiere), 0.5, 3.0)
    poser(piste, lumiere, debut["reforme"], 0.5, 0.1)

    # 8. Le carton de fin : un dernier cuivre et un dernier boum.
    poser(piste, braam(4.0, 1500), debut["fin"], 0.45)
    poser(piste, boum(4.0), debut["fin"], 0.6)

    # Mise au niveau : la crête la plus forte à 0,9, et un limiteur doux (tanh) au-dessus.
    piste /= np.abs(piste).max() / 0.9
    return np.tanh(1.2 * piste) / np.tanh(1.2)
