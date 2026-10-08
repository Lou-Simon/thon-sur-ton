// Le ciel de l'accueil : un coucher de soleil en dégradé, peint en aplats comme le logo,
// avec un soleil rond posé près de l'horizon.
shader_type sky;

uniform vec3 couleur_haut : source_color;
uniform vec3 couleur_milieu : source_color;
uniform vec3 couleur_horizon : source_color;
uniform vec3 couleur_soleil : source_color;
// Direction dans laquelle on voit le soleil, depuis la caméra.
uniform vec3 direction_soleil = vec3(0.35, 0.07, -1.0);
// Rayon apparent du soleil, en radians.
uniform float taille_soleil = 0.07;

void sky() {
	// EYEDIR : direction regardée. Sa hauteur va de 0 (horizon) à 1 (droit au-dessus).
	float hauteur = clamp(EYEDIR.y, 0.0, 1.0);
	vec3 couleur = mix(couleur_horizon, couleur_milieu, smoothstep(0.0, 0.15, hauteur));
	couleur = mix(couleur, couleur_haut, smoothstep(0.15, 0.6, hauteur));
	// Le soleil : tout ce qui est à moins de `taille_soleil` de sa direction, sans dégradé.
	float ecart = acos(dot(EYEDIR, normalize(direction_soleil)));
	COLOR = mix(couleur, couleur_soleil, step(ecart, taille_soleil));
}
