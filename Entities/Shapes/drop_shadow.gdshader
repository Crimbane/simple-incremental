shader_type canvas_item;

// Controls the sharpness/smoothness of the blur distribution
uniform float blur_strength : hint_range(0.0, 5.0) = 1.2;
uniform float blur_alpha : hint_range(1.0, 50.0) = 9.0;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * blur_strength;
    
    // Accumulate surrounding pixels manually to bypass textureLod limitations
    vec4 col = texture(TEXTURE, UV);
    col += texture(TEXTURE, UV + vec2(size.x, 0.0));
    col += texture(TEXTURE, UV + vec2(-size.x, 0.0));
    col += texture(TEXTURE, UV + vec2(0.0, size.y));
    col += texture(TEXTURE, UV + vec2(0.0, -size.y));
    
    col += texture(TEXTURE, UV + vec2(size.x, size.y) * 0.707);
    col += texture(TEXTURE, UV + vec2(-size.x, size.y) * 0.707);
    col += texture(TEXTURE, UV + vec2(size.x, -size.y) * 0.707);
    col += texture(TEXTURE, UV + vec2(-size.x, -size.y) * 0.707);
	col *= vec4(0.0, 0.0, 0.0, 1.0);

    COLOR = col / blur_alpha;
}