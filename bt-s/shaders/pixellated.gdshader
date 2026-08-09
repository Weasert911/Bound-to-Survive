shader_type canvas_item;

uniform float pixel_size : hint_range(1, 1024) = 4.0;

// Godot 4.5 requires explicit screen texture declaration
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Snap UVs to a grid of pixel_size blocks (float-correct)
    uv = floor(uv * vec2(pixel_size)) / vec2(pixel_size);

    // Sample with nearest filter for hard edges
    COLOR = texture(SCREEN_TEXTURE, uv);
}
