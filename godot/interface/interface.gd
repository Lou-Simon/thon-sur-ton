extends CanvasLayer
class_name Interface
## L'interface : un calque 2D dessiné par-dessus la scène 3D.
## Pour l'instant, un panneau de réglage vide, qu'une touche affiche ou masque.
##
## La souris : `Racine` couvre tout l'écran mais ignore la souris (`mouse_filter`),
## les clics la traversent donc jusqu'à la caméra. `Panneau`, lui, arrête la souris :
## au-dessus de lui, ni le clic-glisser ni la molette n'atteignent la caméra.

@onready var _panneau: PanelContainer = $Racine/Panneau


func _unhandled_input(evenement: InputEvent) -> void:
	if evenement.is_action_pressed("interface_basculer"):
		# Un panneau masqué ne reçoit plus la souris : tout l'écran revient à la caméra.
		_panneau.visible = not _panneau.visible
