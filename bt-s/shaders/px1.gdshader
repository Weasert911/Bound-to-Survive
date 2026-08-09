shader_type canvas_item;

// FIXED: Simplified hints to avoid parser errors
uniform sampler2D screen_texture : hint_screen_texture;

// Horror Intensity Controls
uniform float distortion_power : hint_range(0.0, 1.0) = 0.05;
uniform float chromatic_aberration : hint_range(0.0, 0.5) = 0.02;
uniform float shake_speed : hint_range(0.0, 10.0) = 2.0;

// Colors
uniform vec4 hell_tint : source_color = vec4(0.3, 0.05, 0.0, 1.0); // Deep blood red
uniform float vignette_size : hint_range(0.0, 1.0) = 0.4;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // 1. TIMING: 0 to 1 over 90 seconds
    float p = clamp(TIME / 90.0, 0.0, 1.0);
    
    // 2. SCREEN SHAKE (Silent Hill/RE4 Stress)
    // Subtly vibrates the screen coordinates
    vec2 shake = vec2(
        rand(vec2(TIME * shake_speed, 0.0)),
        rand(vec2(0.0, TIME * shake_speed))
    ) * 0.005 * p;
    
    vec2 uv = SCREEN_UV + shake;
    
    // 3. BARREL DISTORTION (Outlast Lens)
    // Curves the screen like a security camera or a panicked eye
    vec2 centered_uv = uv - 0.5;
    float dist_sq = dot(centered_uv, centered_uv);
    vec2 distorted_uv = uv + centered_uv * dist_sq * (distortion_power * p);
    
    // 4. CHROMATIC ABERRATION (Found Footage Failure)
    // Red and Blue channels bleed out towards the edges
    float ca_offset = chromatic_aberration * p * dist_sq;
    float r = texture(screen_texture, distorted_uv + vec2(ca_offset, 0.0)).r;
    float g = texture(screen_texture, distorted_uv).g;
    float b = texture(screen_texture, distorted_uv - vec2(ca_offset, 0.0)).b;
    
    vec3 color = vec3(r, g, b);
    
    // 5. STATIC & NOISE (Silent Hill Radio)
    float noise = (rand(distorted_uv + TIME) - 0.5) * 0.15 * p;
    color += noise;
    
    // 6. DYNAMIC COLOR DECAY (RE4/TLOU Grime)
    // Desaturates the world and adds a sickly red/yellow "Hell" tint
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 grayscale = vec3(luminance);
    color = mix(color, grayscale * hell_tint.rgb * 2.5, p * 0.7);
    
    // 7. THE ABYSS VIGNETTE (Hollow Knight Depth)
    // Darkens the edges of the screen until it feels like a tunnel
    float v_dist = distance(uv, vec2(0.5));
    float vignette = smoothstep(vignette_size + (0.3 * (1.0 - p)), 0.1, v_dist);
    color *= mix(1.0, vignette, p);
    
    // 8. SCANLINES (Retro Horror)
    float scanline = sin(distorted_uv.y * 500.0) * 0.03 * p;
    color -= scanline;

    COLOR = vec4(color, 1.0);
}