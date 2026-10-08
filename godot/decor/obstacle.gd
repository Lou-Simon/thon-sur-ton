extends RefCounted
class_name Obstacle
## Un obstacle que les thons contournent : un segment entouré d'une épaisseur.
## Une algue est un segment vertical, du pied au sommet ; un corail, un segment réduit à un point.
## Le même modèle servira au rocher de la v2.2.0.

## Extrémités du segment, dans le repère de l'aquarium.
var bas: Vector3
var haut: Vector3
## Épaisseur autour du segment, en unités Godot : c'est là que commence la surface de l'obstacle.
var rayon: float


func _init(p_bas: Vector3, p_haut: Vector3, p_rayon: float) -> void:
	bas = p_bas
	haut = p_haut
	rayon = p_rayon


# Vecteur qui va du point du segment le plus proche jusqu'au point donné.
# Sa direction dit où pousser, sa longueur moins le rayon donne la distance à la surface.
func ecart(point: Vector3) -> Vector3:
	return point - Geometry3D.get_closest_point_to_segment(point, bas, haut)
