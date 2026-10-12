#!/bin/sh
# Tourne les rushes du trailer dans rushes/rushes.avi (voir doc/trailer.md).
# À lancer depuis la racine du dépôt : sh godot/tournage/tourner.sh [graine]
# Changer de graine, c'est refaire une prise. GODOT : chemin du binaire Godot 4 (godot par défaut).
#
# Movie Maker filme à la taille de base du projet (1152 × 648 par défaut) et ignore --resolution.
# Le temps du tournage, un fichier override.cfg, que Godot lit au lancement, la passe à 1920 × 1080.
# Il est effacé à la fin : le jeu, lui, ne change pas.
#
# Une fenêtre que macOS ne montre plus (autre bureau, VS Code en plein écran) n'est plus dessinée :
# Movie Maker répète alors la dernière image. Laisser la fenêtre visible jusqu'à la fin.
# À la fin, ffmpeg (s'il est installé) liste les passages figés de plus d'une seconde.

GODOT="${GODOT:-godot}"
GRAINE="${1:-1}"

mkdir -p rushes
printf '[display]\nwindow/size/viewport_width=1920\nwindow/size/viewport_height=1080\n' > godot/override.cfg
"$GODOT" --path godot/ --write-movie "$PWD/rushes/rushes.avi" tournage/tournage.tscn -- graine="$GRAINE"
rm godot/override.cfg

if command -v ffmpeg >/dev/null; then
	echo "Passages figés, en secondes (aucune ligne : tout est bon) :"
	ffmpeg -nostats -v info -i rushes/rushes.avi -vf freezedetect=d=1 -map 0:v -f null - 2>&1 \
		| grep -o "freeze_[a-z]*: [0-9.]*"
fi
