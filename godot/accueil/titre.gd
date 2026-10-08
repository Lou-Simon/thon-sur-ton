extends HBoxContainer
class_name TitreAnime
## Le titre de l'accueil, lettre par lettre : chaque lettre est un Label à part.
## À l'entrée, les lettres tombent l'une après l'autre avec un rebond ; ensuite,
## elles flottent comme une bouée, en vague, et le titre tangue doucement.
##
## Les distances sont en part de la hauteur de l'écran : l'animation garde la même
## allure en fenêtre comme en plein écran.

## Le texte du titre.
@export var texte: String = "THON-SUR-THON"
## Hauteur d'où tombent les lettres, en part de la hauteur de l'écran.
@export var hauteur_chute: float = 0.5
## Durée de la chute d'une lettre, et retard entre deux lettres, en secondes.
@export var duree_chute: float = 0.9
@export var retard_lettres: float = 0.07
## Flottement : montée et descente d'une lettre (en part de la hauteur de l'écran),
## durée d'une vague, et décalage d'une lettre à la suivante dans la vague (radians).
@export var flottement: float = 0.008
@export var periode: float = 3.0
@export var decalage: float = 0.5
## Tangage du titre entier, en degrés.
@export var tangage: float = 1.5

# Le tangage va un peu moins vite que la vague, pour que les deux mouvements ne se calent pas.
const RYTHME_TANGAGE: float = 0.7

var _lettres: Array[Label] = []
# Pour chaque lettre, où elle en est de sa chute : -hauteur_chute en haut, 0 à sa place.
var _chutes: Array[float] = []
var _temps: float = 0.0


func _ready() -> void:
	# Les lettres se touchent, comme dans un seul texte.
	add_theme_constant_override("separation", 0)
	for caractere: String in texte:
		var lettre: Label = Label.new()
		lettre.text = caractere
		lettre.theme_type_variation = &"TitreAccueil"
		add_child(lettre)
		_lettres.append(lettre)
		_chutes.append(0.0)


# Le conteneur range les lettres sur une ligne, à la hauteur 0. À chaque image,
# on les décale verticalement de leur chute et de leur flottement.
func _process(delta: float) -> void:
	_temps += delta
	var hauteur_ecran: float = get_viewport_rect().size.y
	for i: int in _lettres.size():
		var vague: float = flottement * sin(_temps * TAU / periode + i * decalage)
		_lettres[i].position.y = (_chutes[i] + vague) * hauteur_ecran
	pivot_offset = size / 2.0
	rotation = deg_to_rad(tangage) * sin(_temps * TAU / periode * RYTHME_TANGAGE)


## Ajoute la chute des lettres à l'animation d'entrée : toutes les chutes tournent
## en même temps, chaque lettre partant un peu après la précédente.
func entrer(animation: Tween) -> void:
	for i: int in _lettres.size():
		_chutes[i] = -hauteur_chute
		_lettres[i].modulate.a = 0.0
		var depart: float = i * retard_lettres
		animation.parallel().tween_property(_lettres[i], "modulate:a", 1.0, duree_chute / 4.0).set_delay(depart)
		animation.parallel().tween_method(_poser_chute.bind(i), -hauteur_chute, 0.0, duree_chute) \
				.set_delay(depart).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _poser_chute(valeur: float, i: int) -> void:
	_chutes[i] = valeur
