// La surface de la mer vue d'au-dessus : deux houles de sinus qui se croisent.
// Les sommets montent et descendent dans le shader ; la normale est calculée à partir
// de la pente des deux sinus, pour que la lumière du soleil couchant suive les vagues.
shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform vec3 couleur_eau : source_color;
// Couleur reflétée par l'eau quand on la regarde en rasant : celle du ciel couchant.
uniform vec3 couleur_reflet : source_color;
// Part du reflet au plus fort, de 0 (aucun) à 1 (que le ciel).
uniform float force_reflet = 0.5;
// Hauteur des vagues (du creux à la crête), distance entre deux crêtes, vitesse.
uniform float hauteur = 0.3;
uniform float longueur = 7.0;
uniform float vitesse = 1.2;

void vertex() {
	vec2 p = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	float k = TAU / longueur;
	// Deux houles : une dans la longueur, une plus lente en biais.
	float a = p.x * k + TIME * vitesse;
	float b = (p.x * 0.4 + p.y) * k * 0.7 + TIME * vitesse * 1.3;
	VERTEX.y += hauteur * 0.25 * (sin(a) + sin(b));
	// Pente de la surface selon x et z : la dérivée de chaque sinus est un cosinus.
	float pente_x = hauteur * 0.25 * k * (cos(a) + 0.4 * 0.7 * cos(b));
	float pente_z = hauteur * 0.25 * k * 0.7 * cos(b);
	NORMAL = normalize(vec3(-pente_x, 1.0, -pente_z));
}

void fragment() {
	// Plus on regarde l'eau en rasant, plus elle reflète le ciel (effet de Fresnel, simplifié).
	// `force_reflet` garde l'eau bleue : le reflet ne fait que la teinter.
	float rasant = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 5.0);
	ALBEDO = mix(couleur_eau, couleur_reflet, rasant * force_reflet);
	ROUGHNESS = 0.3;
}
