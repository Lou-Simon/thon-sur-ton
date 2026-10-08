extends Node3D
class_name Accueil
## L'écran d'accueil : au-dessus de la mer, au coucher du soleil.
## Le ciel et la surface sont deux petits shaders ; ce script leur donne leurs couleurs,
## fait houler la caméra, joue l'entrée en scène et branche les boutons.
## Le titre, les sauts de thons et le ciel vivant s'animent chacun dans leur propre script.

## Couleurs du ciel, du haut vers l'horizon, et du soleil.
@export var couleur_haut: Color = Color("#2a1b4a")
@export var couleur_milieu: Color = Color("#c4553b")
@export var couleur_horizon: Color = Color("#f2a541")
@export var couleur_soleil: Color = Color("#ffe08a")
## Couleur de la mer, et couleur qu'elle reflète quand on la regarde en rasant.
@export var couleur_eau: Color = Color(0.05, 0.25, 0.55)
## Direction dans laquelle on voit le soleil.
@export var direction_soleil: Vector3 = Vector3(0.35, 0.07, -1.0)
## Houle de la caméra : hauteur du balancement, en unités Godot, et durée d'un balancement.
@export var houle: float = 0.15
@export var periode_houle: float = 5.0
## Entrée en scène : durée d'apparition du sous-titre, puis des boutons, en secondes.
@export var duree_sous_titre: float = 0.6
@export var duree_boutons: float = 0.5

# Côté de la mer, en unités Godot, et nombre de carrés sur chaque côté.
const TAILLE_MER: float = 600.0
const DETAIL_MER: int = 300
# Le brouillard fond le large de la mer dans l'horizon.
const DENSITE_BROUILLARD: float = 0.003
# Part de la lumière ambiante qui vient du ciel.
const PART_CIEL_AMBIANTE: float = 0.4
const SHADER_CIEL: Shader = preload("res://accueil/ciel.gdshader")
const SHADER_SURFACE: Shader = preload("res://accueil/surface.gdshader")

var _temps: float = 0.0
var _hauteur_camera: float
var _entree: Tween

@onready var _ciel: WorldEnvironment = $Ciel
@onready var _mer: MeshInstance3D = $Mer
@onready var _soleil: DirectionalLight3D = $Soleil
@onready var _camera: Camera3D = $Camera
@onready var _titre: TitreAnime = %Titre
@onready var _sous_titre: Label = %SousTitre
@onready var _boutons: VBoxContainer = %Boutons
@onready var _plonger: Button = %Plonger
@onready var _quitter: Button = %Quitter


func _ready() -> void:
	_construire_ciel()
	_construire_mer()
	# La lumière vient du soleil : elle part de sa direction et va dans l'autre sens.
	_soleil.look_at(-direction_soleil)
	_hauteur_camera = _camera.position.y
	_quitter.pressed.connect(_on_quitter)
	_entrer_en_scene()


func _process(delta: float) -> void:
	_temps += delta
	_camera.position.y = _hauteur_camera + houle * sin(_temps * TAU / periode_houle)


# Pendant l'entrée en scène, un clic ou une touche la passe : tout se met en place d'un coup.
func _unhandled_input(evenement: InputEvent) -> void:
	var appui: bool = evenement is InputEventMouseButton or evenement is InputEventKey
	if appui and evenement.is_pressed() and _entree.is_running():
		# On avance l'animation bien au-delà de sa durée : elle se termine aussitôt.
		_entree.custom_step(60.0)
		get_viewport().set_input_as_handled()


# L'entrée en scène, en trois temps : les lettres du titre tombent, puis le sous-titre
# apparaît, puis les boutons. Le focus va à « Plonger » à la fin : `Entrée` le déclenche.
func _entrer_en_scene() -> void:
	_sous_titre.modulate.a = 0.0
	_boutons.modulate.a = 0.0
	_entree = create_tween()
	_titre.entrer(_entree)
	_entree.chain().tween_property(_sous_titre, "modulate:a", 1.0, duree_sous_titre)
	_entree.chain().tween_property(_boutons, "modulate:a", 1.0, duree_boutons)
	_entree.finished.connect(_plonger.grab_focus)


func _construire_ciel() -> void:
	var peinture: ShaderMaterial = ShaderMaterial.new()
	peinture.shader = SHADER_CIEL
	peinture.set_shader_parameter("couleur_haut", couleur_haut)
	peinture.set_shader_parameter("couleur_milieu", couleur_milieu)
	peinture.set_shader_parameter("couleur_horizon", couleur_horizon)
	peinture.set_shader_parameter("couleur_soleil", couleur_soleil)
	peinture.set_shader_parameter("direction_soleil", direction_soleil)
	var ciel: Sky = Sky.new()
	ciel.sky_material = peinture
	var milieu: Environment = Environment.new()
	milieu.background_mode = Environment.BG_SKY
	milieu.sky = ciel
	milieu.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	# Le ciel éclaire un peu la scène, sans que son orange recouvre le bleu de la mer.
	milieu.ambient_light_sky_contribution = PART_CIEL_AMBIANTE
	milieu.fog_enabled = true
	milieu.fog_light_color = couleur_horizon
	milieu.fog_density = DENSITE_BROUILLARD
	# Le brouillard ne touche que la mer : le ciel garde ses couleurs.
	milieu.fog_sky_affect = 0.0
	_ciel.environment = milieu


func _construire_mer() -> void:
	var plan: PlaneMesh = PlaneMesh.new()
	plan.size = Vector2(TAILLE_MER, TAILLE_MER)
	# Des sommets à l'intérieur du plan, pour que le shader puisse les faire onduler.
	plan.subdivide_width = DETAIL_MER
	plan.subdivide_depth = DETAIL_MER
	var eau: ShaderMaterial = ShaderMaterial.new()
	eau.shader = SHADER_SURFACE
	eau.set_shader_parameter("couleur_eau", couleur_eau)
	eau.set_shader_parameter("couleur_reflet", couleur_milieu)
	_mer.mesh = plan
	_mer.material_override = eau


func _on_quitter() -> void:
	get_tree().quit()
