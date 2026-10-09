extends CanvasLayer
class_name Interface
## L'interface : un calque 2D dessiné par-dessus la scène 3D.
## Un panneau de réglage, qu'une touche affiche ou masque, avec un curseur par réglage du banc
## et deux boutons : « Relancer » et « Valeurs par défaut ».
##
## La souris : `Racine` couvre tout l'écran mais ignore la souris (`mouse_filter`),
## les clics la traversent donc jusqu'à la caméra. `Panneau`, lui, arrête la souris :
## au-dessus de lui, ni le clic-glisser ni la molette n'atteignent la caméra.
##
## Le clavier : ni les curseurs ni les boutons ne prennent le focus. Sans ça, `Tab` passerait
## d'un curseur à l'autre au lieu de masquer le panneau, et les touches de la caméra seraient prises.

# Les curseurs, dans l'ordre du panneau. `reglage` est le nom d'une variable `@export` du thon,
# sauf `nombre_thons`, qui est celle de l'aquarium et ne compte qu'au prochain « Relancer ».
# Un pas de 1 ou plus s'affiche sans décimale, un pas plus petit avec une.
const CURSEURS: Array[Dictionary] = [
	{groupe = "Banc", libelle = "Nombre de thons", reglage = &"nombre_thons", min = 1.0, max = 100.0, pas = 1.0},
	{groupe = "Banc", libelle = "Vision", reglage = &"rayon_vision", min = 2.0, max = 20.0, pas = 0.5},
	{groupe = "Vitesse", libelle = "Vitesse min", reglage = &"vitesse_min", min = 0.5, max = 10.0, pas = 0.5},
	{groupe = "Vitesse", libelle = "Vitesse max", reglage = &"vitesse_max", min = 0.5, max = 15.0, pas = 0.5},
	{groupe = "Forces", libelle = "Séparation", reglage = &"poids_separation", min = 0.0, max = 150.0, pas = 5.0},
	{groupe = "Forces", libelle = "Alignement", reglage = &"poids_alignement", min = 0.0, max = 20.0, pas = 0.5},
	{groupe = "Forces", libelle = "Cohésion", reglage = &"poids_cohesion", min = 0.0, max = 10.0, pas = 0.5},
	{groupe = "Forces", libelle = "Errance", reglage = &"poids_errance", min = 0.0, max = 5.0, pas = 0.1},
	{groupe = "Forces", libelle = "Parois et sol", reglage = &"poids_evitement", min = 0.0, max = 100.0, pas = 5.0},
	{groupe = "Forces", libelle = "Plantes et rocher", reglage = &"poids_obstacles", min = 0.0, max = 100.0, pas = 5.0},
]

var _aquarium: Aquarium
# Pour chaque réglage : son curseur, l'étiquette de sa valeur, et sa valeur au lancement.
var _curseurs: Dictionary[StringName, HSlider] = {}
var _valeurs: Dictionary[StringName, Label] = {}
var _defauts: Dictionary[StringName, float] = {}

@onready var _panneau: PanelContainer = $Racine/Panneau
@onready var _liste: VBoxContainer = $Racine/Panneau/Contenu/Defilement/Curseurs


func _unhandled_input(evenement: InputEvent) -> void:
	if evenement.is_action_pressed("interface_basculer"):
		# Un panneau masqué ne reçoit plus la souris : tout l'écran revient à la caméra.
		_panneau.visible = not _panneau.visible
	elif evenement.is_action_pressed("simulation_relancer"):
		_aquarium.relancer()


# C'est l'aquarium qui appelle cette fonction, une fois ses thons créés : les curseurs partent
# des valeurs du code, qui deviennent les valeurs par défaut.
func installer(aquarium: Aquarium) -> void:
	_aquarium = aquarium
	var groupe: String = ""
	for curseur: Dictionary in CURSEURS:
		if curseur.groupe != groupe:
			groupe = curseur.groupe
			var titre: Label = Label.new()
			titre.theme_type_variation = &"Groupe"
			titre.text = groupe
			_liste.add_child(titre)
		_ajouter_curseur(curseur)


func _ajouter_curseur(curseur: Dictionary) -> void:
	var reglage: StringName = curseur.reglage
	var ligne: HBoxContainer = HBoxContainer.new()
	var libelle: Label = Label.new()
	libelle.text = curseur.libelle
	libelle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var valeur: Label = Label.new()
	ligne.add_child(libelle)
	ligne.add_child(valeur)
	var glissiere: HSlider = HSlider.new()
	glissiere.min_value = curseur.min
	glissiere.max_value = curseur.max
	glissiere.step = curseur.pas
	glissiere.focus_mode = Control.FOCUS_NONE
	_liste.add_child(ligne)
	_liste.add_child(glissiere)
	_curseurs[reglage] = glissiere
	_valeurs[reglage] = valeur
	_defauts[reglage] = _valeur_actuelle(reglage)
	glissiere.value = _defauts[reglage]
	_afficher(reglage, glissiere.value)
	# Branché après avoir posé la valeur de départ : la poser ne renvoie rien aux thons.
	glissiere.value_changed.connect(_au_changement.bind(reglage))


func _valeur_actuelle(reglage: StringName) -> float:
	if reglage == &"nombre_thons":
		return _aquarium.nombre_thons
	return _aquarium.reglage(reglage)


func _au_changement(valeur: float, reglage: StringName) -> void:
	_afficher(reglage, valeur)
	if reglage == &"nombre_thons":
		_aquarium.nombre_thons = int(valeur)
		return
	_aquarium.regler(reglage, valeur)
	# La vitesse min ne dépasse jamais la max : l'autre curseur suit, et prévient les thons à son tour.
	if reglage == &"vitesse_min" and valeur > _curseurs[&"vitesse_max"].value:
		_curseurs[&"vitesse_max"].value = valeur
	elif reglage == &"vitesse_max" and valeur < _curseurs[&"vitesse_min"].value:
		_curseurs[&"vitesse_min"].value = valeur


# Nombre fixe de décimales par curseur : la valeur ne change pas de largeur en glissant.
func _afficher(reglage: StringName, valeur: float) -> void:
	var pas: float = _curseurs[reglage].step
	_valeurs[reglage].text = ("%.0f" if pas >= 1.0 else "%.1f") % valeur


func _sur_relancer() -> void:
	_aquarium.relancer()


# Remet chaque curseur à sa valeur de départ ; le curseur prévient les thons comme à la main.
func _sur_valeurs_par_defaut() -> void:
	for reglage: StringName in _defauts:
		_curseurs[reglage].value = _defauts[reglage]
