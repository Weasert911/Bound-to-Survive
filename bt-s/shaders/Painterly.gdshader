shader_type canvas_item;

// Explicit screen texture declaration (Godot 4.5)
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Controls
uniform float color_levels : hint_range(2, 16) = 4.0; // fewer = flatter poster look
uniform float edge_strength : hint_range(0.0, 1.0) = 0.5; // outlines

// Simple luminance function
float luminance(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(SCREEN_TEXTURE, uv);

    // Posterize colors
    col.rgb = floor(col.rgb * color_levels) / color_levels;

    // Edge detection (Sobel-like)
    vec2 offset = vec2(1.0) / vec2(800.0, 600.0); // adjust to viewport size
    float center = luminance(texture(SCREEN_TEXTURE, uv).rgb);
    float right  = luminance(texture(SCREEN_TEXTURE, uv + vec2(offset.x, 0.0)).rgb);
    float up     = luminance(texture(SCREEN_TEXTURE, uv + vec2(0.0, offset.y)).rgb);

    float edge = abs(center - right) + abs(center - up);

    // Mix edge into color for bold outlines
    col.rgb -= edge_strength * edge;

    COLOR = col;
}
