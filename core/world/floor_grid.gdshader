// Textura placeholder del suelo, pintada en COORDENADAS DE MUNDO.
// Como el patrón depende de la posición global (no de la malla), el piso
// treadmill puede seguir al jugador sin que la textura se deslice.
// La línea dorada marca la frontera de cada "mundo" (período del torus):
// al cruzarla, estás entrando en la copia siguiente del mapa.
shader_type spatial;

uniform vec3 color_a: source_color = vec3(0.36, 0.44, 0.29);
uniform vec3 color_b: source_color = vec3(0.30, 0.37, 0.24);
uniform vec3 line_color: source_color = vec3(0.22, 0.27, 0.17);
uniform vec3 major_color: source_color = vec3(0.85, 0.72, 0.25);
uniform float cell_size = 5.0;
uniform float line_width = 0.04; // fracción de la celda
uniform float world_size = 150.0; // debe coincidir con WorldWrap.world_size
uniform float major_width = 0.4; // ancho en unidades de mundo

varying vec3 world_pos;


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}


void fragment() {
	vec2 uv = world_pos.xz / cell_size;
	vec2 cell = floor(uv);

	// Damero
	float checker = mod(cell.x + cell.y, 2.0);
	vec3 col = mix(color_a, color_b, checker);

	// Líneas de cuadrícula
	vec2 f = abs(fract(uv) - 0.5);
	float line = step(0.5 - line_width, max(f.x, f.y));
	col = mix(col, line_color, line);

	// Línea mayor en cada múltiplo de world_size (pasa por el origen):
	// visualiza el período del torus.
	vec2 w = abs(fract(world_pos.xz / world_size + 0.5) - 0.5) * world_size;
	float major = step(min(w.x, w.y), major_width);
	col = mix(col, major_color, major);

	ALBEDO = col;
	ROUGHNESS = 1.0;
	SPECULAR = 0.1;
}
