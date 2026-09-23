shader_type canvas_item;

uniform vec2 start_position = vec2(0.5, 0.5);
uniform vec3 trans_color : source_color = vec3(1.0, 1.0, 1.0);
uniform sampler2D noise_texture : repeat_enable;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float invert : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float invert_value = invert;
	
	float noise = texture(noise_texture, UV + vec2(TIME * 0.03, 0.0)).r * 3.0;
	float color_alpha = distance(UV, start_position) * progress * noise * 30.0;
	float grey_scale = dot(COLOR.rgb, vec3(0.35));
	
	if (invert == 0.0) {
		invert_value = color_alpha * 2.0;
	}
	
	COLOR = vec4(mix(vec3(grey_scale), trans_color, 0.8) * vec3(0.8, 0.7, 0.8), invert_value - color_alpha);
}
