shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

///////////////////////
// CONTROLS
///////////////////////
uniform float artifact_strength : hint_range(0.0, 2.0) = 1.0;
uniform float time_desync       : hint_range(0.0, 1.0) = 0.35;
uniform float fracture_density  : hint_range(1.0, 50.0) = 22.0;

uniform float red_error_power   : hint_range(0.0, 3.0) = 1.8;
uniform float opacity           : hint_range(0.0, 1.0) = 0.55;

uniform vec3 base_color : source_color = vec3(0, 0, 0);
uniform vec3 error_color : source_color = vec3(0.9, 0.05, 0.05);

///////////////////////
// LOW-LEVEL HASH
///////////////////////
float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

float hash3(vec3 p) {
	return hash(dot(p, vec3(17.1, 113.5, 27.9)));
}

///////////////////////
// VERTEX: HARD ERRORS
///////////////////////
void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Hard vertical snapping (non-organic)
	float snap = floor(world.y * fracture_density) / fracture_density;

	// Time slicing (frame corruption)
	float t = floor(TIME * 12.0 * (1.0 - time_desync));

	// Directional tear
	float tear = hash(snap + t) * artifact_strength;

	// Binary axis jumps (feels WRONG)
	VERTEX.x += step(0.6, hash3(world + t)) * tear * 0.08;
	VERTEX.z -= step(0.7, hash3(world - t)) * tear * 0.06;

	// Micro collapse inward
	VERTEX += NORMAL * tear * -0.03;
}

///////////////////////
// FRAGMENT: SIGNAL FAILURE
///////////////////////
void fragment() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Base tone
	vec3 col = base_color;

	// Bit-depth crush (8-bit-ish)
	col = floor(col * 12.0) / 12.0;

	// Temporal desync flicker
	float flicker = step(0.5, hash(floor(TIME * 20.0)));
	col *= mix(0.7, 1.3, flicker);

	// Fracture bands (digital seams)
	float band = abs(fract(world.y * fracture_density) - 0.5) * 2.0;
	float fracture = smoothstep(0.2, 0.0, band);

	// Error injection
	col = mix(col, error_color, fracture * red_error_power);

	// UV corruption without textures
	float uv_err = hash3(world * 3.0 + TIME);
	col.rgb += (uv_err - 0.5) * 0.15 * artifact_strength;

	// Alpha instability (signal loss)
	float alpha_jitter = step(0.3, hash3(world + TIME));
	float alpha = opacity * mix(0.4, 1.0, alpha_jitter);

	ALBEDO = col;
	ALPHA  = alpha;
}
