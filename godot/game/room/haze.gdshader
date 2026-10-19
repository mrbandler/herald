// The Listener's tired eyes: with `amount` the view blurs, and darkness creeps in from the edges
// towards the middle.
shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture, filter_linear_mipmap;

// 0 clear, 1 asleep.
uniform float amount : hint_range(0.0, 1.0) = 0.0;

// Mip level of the blur at full amount.
uniform float max_blur = 3.5;

// Share of the light gone everywhere at full amount.
uniform float max_dark = 0.25;

// Share of the light gone where the creeping darkness has reached.
uniform float edge_dark = 0.95;

// How soft the creeping darkness' front is, as a share of the way from the middle to a corner.
uniform float softness = 0.35;

void fragment() {
	vec3 colour = textureLod(screen, SCREEN_UV, amount * max_blur).rgb;

	// 0 in the middle, 1 in the corners, with the screen's width counted wider than its height.
	float from_middle = length((SCREEN_UV - 0.5) * vec2(1.6, 1.0)) / 0.943;
	float reach = mix(1.05, 0.1, amount);
	float creep = smoothstep(reach, reach + softness, from_middle);

	COLOR = vec4(colour * (1.0 - amount * max_dark) * (1.0 - creep * edge_dark), 1.0);
}
