extends ModeleThon
class_name ModeleRequin
## L'apparence du requin, construite par code : le modèle du thon en plus grand et en gris,
## avec en plus un grand aileron sur le dos et deux grandes nageoires pectorales.
##
## Héritage : le corps, la queue qui bat, les yeux et les petites nageoires sont ceux de
## `ModeleThon`, rien n'est réécrit. Les tailles sont en « h » et les positions en « t »,
## comme dans modele_thon.gd.

# Aileron : (t début, t fin, hauteur en h, 1 = sur le dos), comme les nageoires du thon.
const AILERON: Vector4 = Vector4(0.24, 0.42, 1.2, 1.0)
# Grande pectorale droite (x > 0) : (x en h, y en h, t). La gauche en est le reflet.
const GRANDE_PECTORALE: Array[Vector3] = [Vector3(0.65, -0.3, 0.26), Vector3(0.65, -0.3, 0.38), Vector3(2.0, -0.8, 0.52)]


# Les réglages du modèle qui diffèrent de ceux du thon, donnés avant `_ready` qui construit le corps.
# Valeurs proposées par Claude, à confirmer par Lou et Simon.
func _init() -> void:
	# Deux fois la longueur d'un thon (2).
	longueur = 4.0
	couleur_dos = Color(0.35, 0.4, 0.45)
	# Pas de jaune : il est réservé aux thons.
	couleur_nageoires = couleur_dos


func _ready() -> void:
	# Le `_ready` du thon construit le corps, la queue et les yeux.
	super()
	var outil: SurfaceTool = SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	_ajouter_nageoire(outil, AILERON.x, AILERON.y, AILERON.z, AILERON.w)
	for cote: float in [1.0, -1.0]:
		var sommets: Array[Vector3] = []
		for s: Vector3 in GRANDE_PECTORALE:
			sommets.append(Vector3(cote * s.x * _h, s.y * _h, _z(s.z)))
		_ajouter_triangle(outil, sommets[0], sommets[1], sommets[2])
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = outil.commit()
	instance.material_override = _matiere_nageoires()
	add_child(instance)
