shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float vein_intensity : hint_range(0.0, 1.0) = 0.7;
uniform float time : hint_range(0.0, 1000.0) = 0.0;

// Noise function for vein wobble
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(SCREEN_TEXTURE, uv);

    // Distance from center (for vignette-like frame)
    float dist = distance(uv, vec2(0.5));

    // Vein mask near edges
    float edge_mask = smoothstep(0.35, 0.7, dist);

    // Procedural vein pattern
    float vein_noise = hash(uv * 20.0 + time * 0.5);
    float vein_pattern = sin(uv.y * 40.0 + vein_noise * 10.0 + time) * 0.5 + 0.5;

    // Mix red/green/blue vein colors
    vec3 vein_color = vec3(
        vein_pattern * 0.8,              // red
        vein_pattern * 0.3 + vein_noise, // green
        vein_pattern * 0.2               // blue
    );

    // Blend veins into edges
    col.rgb = mix(col.rgb, vein_color, edge_mask * vein_intensity);

    COLOR = col;
}
