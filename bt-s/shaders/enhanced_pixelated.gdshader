shader_type canvas_item;
render_mode unshaded;

// Enhanced Pixelated Horror Shader
// Creates a retro, pixelated aesthetic with horror elements

uniform float global_strength : hint_range(0.0, 1.0) = 0.0;
uniform float pixel_size : hint_range(50.0, 1000.0) = 320.0;
uniform float color_steps : hint_range(2.0, 256.0) = 32.0;
uniform float chromatic_aberration : hint_range(0.0, 0.05) = 0.015;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.3;
uniform float scanline_speed : hint_range(0.0, 10.0) = 2.0;
uniform float vignette_strength : hint_range(0.0, 2.0) = 1.2;
uniform float film_grain : hint_range(0.0, 1.0) = 0.25;
uniform float flicker_strength : hint_range(0.0, 1.0) = 0.15;
uniform float blood_tint : hint_range(0.0, 1.0) = 0.1;
uniform float ghost_distortion : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 res = SCREEN_PIXEL_SIZE;
	
	// Apply global strength to modulate all horror effects
	float strength = global_strength;
	
	// 1. Pixelation (increases with strength)
	float pixel_scale = mix(pixel_size, pixel_size * 0.5, strength);
	vec2 pixel_uv = floor(uv * pixel_scale) / pixel_scale;
	vec4 color = textureLod(SCREEN_TEXTURE, pixel_uv, 0.0);
	
	// 2. Color Quantization (reduces colors with strength)
	float color_step_scale = mix(color_steps, color_steps * 0.3, strength);
	color.rgb = floor(color.rgb * color_step_scale) / color_step_scale;
	
	// 3. Chromatic Aberration (increases with strength)
	float chroma_offset = mix(0.0, chromatic_aberration, strength) * sin(uv.y * 20.0 + TIME * 5.0);
	vec3 r = textureLod(SCREEN_TEXTURE, pixel_uv + vec2(chroma_offset, 0.0), 0.0).rgb;
	vec3 b = textureLod(SCREEN_TEXTURE, pixel_uv - vec2(chroma_offset, 0.0), 0.0).rgb;
	color.rgb = vec3(r.r, color.g, b.b);
	
	// 4. Scanlines (increases with strength)
	float scanline = sin(uv.y * pixel_scale * 2.0 + TIME * scanline_speed);
	scanline = (scanline * 0.5 + 0.5);
	float scanline_mod = mix(0.0, scanline_strength, strength);
	color.rgb *= mix(1.0, 1.0 - scanline * scanline_mod, scanline);
	
	// 5. Vignette (increases with strength)
	float dist = distance(uv, vec2(0.5));
	float vignette = smoothstep(0.3, 1.0, dist);
	float vignette_mod = mix(0.0, vignette_strength, strength);
	color.rgb *= mix(1.0, 1.0 - vignette * vignette_mod, vignette);
	
	// 6. Film Grain (increases with strength)
	float noise = fract(sin(dot(uv * pixel_scale, vec2(12.9898, 78.233))) * 43758.5453);
	float grain_mod = mix(0.0, film_grain, strength);
	noise = (noise - 0.5) * grain_mod;
	color.rgb += noise * 0.1;
	
	// 7. Flicker Effect (increases with strength)
	float flicker_mod = mix(0.0, flicker_strength, strength);
	float flicker = sin(TIME * 10.0) * flicker_mod;
	color.rgb += flicker * 0.1;
	
	// 8. Blood Tint (increases with strength)
	float blood_mod = mix(0.0, blood_tint, strength);
	color.rgb += vec3(blood_mod * 0.2, 0.0, blood_mod * 0.1);
	
	// 9. Ghost Distortion (increases with strength)
	float ghost_mod = mix(0.0, ghost_distortion, strength);
	if (ghost_mod > 0.0) {
		vec2 warp = vec2(
			sin(uv.y * 10.0 + TIME) * 0.01,
			cos(uv.x * 10.0 + TIME) * 0.01
		) * ghost_mod;
		color.rgb = textureLod(SCREEN_TEXTURE, pixel_uv + warp, 0.0).rgb;
		color.rgb = floor(color.rgb * color_step_scale) / color_step_scale;
	}
	
	// 10. CRT Curvature (optional, subtle)
	vec2 curve_uv = (uv - 0.5) * 1.1;
	curve_uv = curve_uv * (1.0 + dot(curve_uv, curve_uv) * 0.2);
	curve_uv += 0.5;
	
	// Final output
	COLOR = vec4(color.rgb, 1.0);
}
