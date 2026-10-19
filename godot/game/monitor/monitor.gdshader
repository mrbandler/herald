// The slow-scan screen: a picture cut into lines of LINE's length, with each source row's
// state from row_states, blue-white with a yellow-green afterglow on the newest rows.
shader_type spatial;
render_mode unshaded;

uniform sampler2D image : source_color, filter_linear, repeat_disable;
uniform sampler2D row_states : filter_nearest;
uniform int mode = 0;
uniform int rows = 120;
uniform float k = 1.0;
uniform float phase = 0.0;
uniform float offset = 0.0;
uniform float contrast = 0.5;
uniform float noise = 0.6;
uniform int newest_row = -1;
uniform float afterglow_rows = 6.0;
uniform vec3 tint : source_color = vec3(0.78, 0.86, 1.0);
uniform vec3 glow : source_color = vec3(0.75, 1.0, 0.45);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float snow = hash(floor(UV * vec2(320.0, 240.0)) + vec2(floor(TIME * 30.0)));
	if (mode == 0) {
		ALBEDO = tint * snow * 0.25;
	} else {
		float screen_row = floor(UV.y * float(rows));
		float s = (screen_row + UV.x) * k + phase - offset;
		float row = floor(s);
		float shade = 0.0;
		if (row >= 0.0 && row < float(rows)) {
			float state = round(texelFetch(row_states, ivec2(int(row), 0), 0).r * 255.0);
			float v = (row + fract(UV.y * float(rows))) / float(rows);
			float lum = dot(textureLod(image, vec2(fract(s), v), 0.0).rgb, vec3(0.299, 0.587, 0.114));
			// Lost and unsent rows stay black at any CONTRAST.
			if (state < 1.5) {
				shade = state < 0.5 ? lum : mix(lum, snow, noise);
				float gain = exp2((contrast - 0.5) * 2.0);
				shade = clamp((shade - 0.5) * gain + 0.5 + (contrast - 0.5) * 0.3, 0.0, 1.0);
			}
		}
		vec3 colour = tint * shade;
		if (newest_row >= 0) {
			float age = float(newest_row) - screen_row;
			float fresh = clamp(1.0 - age / afterglow_rows, 0.0, 1.0) * step(0.0, age);
			colour = mix(colour, glow * shade, fresh);
		}
		ALBEDO = colour * (0.88 + 0.12 * step(0.5, fract(UV.y * float(rows))));
	}
}
