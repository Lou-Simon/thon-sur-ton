// Le sable : éclairage toon (lumière en aplats) et reflets de lumière qui ondulent.
// Les reflets viennent d'un motif de cellules (bruit cellulaire de Godot) dont on garde les bords :
// un réseau de traits clairs. Deux réseaux glissent l'un sur l'autre, dans deux directions,
// comme la lumière que les vagues de la surface concentrent sur le fond.
shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform vec3 couleur_sable : source_color;
// Motif de cellules, créé dans sol.gd. Il se répète sans couture.
uniform sampler2D motif : repeat_enable, filter_linear_mipmap;
// Nombre de cellules par unité Godot : plus c'est petit, plus les reflets sont grands.
uniform float echelle = 0.025;
// Vitesse de glissement des motifs, en motifs par seconde.
uniform float vitesse = 0.02;
// Force des reflets : 0 les éteint.
uniform float intensite = 0.5;

// Position du point dans le monde : les reflets restent collés au sol, quel que soit le morceau de sable.
varying vec3 position_monde;

void vertex() {
	position_monde = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = position_monde.xz * echelle;
	float a = texture(motif, uv + TIME * vitesse * vec2(1.0, 0.6)).r;
	float b = texture(motif, uv * 1.3 - TIME * vitesse * vec2(0.6, 1.0)).r;
	// Le motif vaut 0 sur le bord des cellules : 1 - motif y est proche de 1. On garde
	// les bords des deux réseaux, en traits nets grâce à smoothstep.
	float reflet = smoothstep(0.8, 0.95, max(1.0 - a, 1.0 - b));
	ALBEDO = couleur_sable;
	// Les reflets s'ajoutent comme une lumière propre au sol : le toon ne les découpe pas.
	EMISSION = vec3(intensite * reflet);
}
