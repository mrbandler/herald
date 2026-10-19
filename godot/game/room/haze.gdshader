// The Listener's tired eyes: the view behind blurs and darkens with `amount`.
shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture, filter_linear_mipmap;

// 0 clear, 1 asleep.
uniform float amount : hint_range(0.0, 1.0) = 0.0;

// Mip level of the blur at full amount.
uniform float max_blur = 3.5;

// Share of the light gone at full amount.
uniform float max_dark = 0.75;

void fragment() {
	vec3 colour = textureLod(screen, SCREEN_UV, amount * max_blur).rgb;
	COLOR = vec4(colour * (1.0 - amount * max_dark), 1.0);
}
