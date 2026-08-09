shader_type canvas_item;

uniform float distress : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_speed = 6.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	col.rgb = mix(col.rgb, col.rgb * vec3(1.2, 0.9, 0.9), distress * pulse * 0.3);

	COLOR = col;
}
