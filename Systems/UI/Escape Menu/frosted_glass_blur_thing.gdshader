shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform vec3 color_tint : source_color;
uniform float color_alpha : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 blur = textureLod(screen_texture, SCREEN_UV, blur_amount);
	COLOR = mix(blur, vec4(color_tint, 1.0), color_alpha);
}
