extends WorldEnvironment
class_name Ambiance
## L'ambiance sous-marine : un fond bleu et un brouillard de la même couleur,
## pour que ce qui est loin se fonde dans l'eau.

## Couleur de l'eau : sert au fond de l'image et au brouillard.
@export var couleur_eau: Color = Color(0.05, 0.3, 0.5)
## Densité du brouillard : plus elle est grande, plus les objets lointains s'effacent.
@export var densite_brouillard: float = 0.01


func _ready() -> void:
	var milieu: Environment = Environment.new()
	# Fond uni à la place du ciel par défaut.
	milieu.background_mode = Environment.BG_COLOR
	milieu.background_color = couleur_eau
	# Brouillard de Godot : il s'épaissit tout seul avec la distance à la caméra.
	# Même couleur que le fond, sinon les objets lointains se découperaient dessus.
	milieu.fog_enabled = true
	milieu.fog_light_color = couleur_eau
	milieu.fog_density = densite_brouillard
	environment = milieu
