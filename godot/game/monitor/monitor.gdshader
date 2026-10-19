// The slow-scan screen: a picture cut into lines of LINE's length, with each source row's
// state from row_states, blue-white with a yellow-green afterglow on the newest rows, seen
// through a slightly bowed CRT face with darker corners.
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

// How far the picture bows away from the corners. Small, so tuning still reads straight.
uniform float curvature = 0.02;

// How strongly the corners darken.
uniform float vignette = 0.1;

// The hum bar: a soft brighter band rolling up the picture, as on old sets.
uniform float hum_strength = 0.15;


// Seconds the hum bar takes to roll once over the picture.
uniform float hum_seconds = 7.0;

// Height of the hum bar as a share of the picture.
uniform float hum_width = 0.035;

// Overall brightness of the phosphor, above 1 so bright pictures bloom.
uniform float brightness = 1.2;

// Noise per pixel cell and frame. The frame is its own input, so each frame is fresh noise
// rather than the last one shifted.
float hash(vec3 p) {
	p = fract(p * vec3(0.1031, 0.1030, 0.0973));
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}

// 0..1 where the rolling hum bar lies over `y`, softly faded at its edges.
float hum_bar(float y, float time, float seconds, float width) {
	float centre = 1.0 - fract(time / seconds);
	float distance = abs(fract(y - centre + 0.5) - 0.5);
	return smoothstep(width, 0.0, distance);
}

void fragment() {
	vec2 centred = UV * 2.0 - 1.0;
	centred *= 1.0 + curvature * dot(centred, centred);
	vec2 uv = centred * 0.5 + 0.5;
	vec2 edge = clamp(uv * (1.0 - uv), 0.0, 1.0);
	float shade_corners = pow(clamp(edge.x * edge.y * 16.0, 0.0, 1.0), vignette);
	bool outside = any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)));

	float snow = hash(vec3(floor(uv * vec2(320.0, 240.0)), floor(TIME * 30.0)));
	float band = hum_bar(uv.y, TIME, hum_seconds, hum_width);
	if (outside) {
		ALBEDO = vec3(0.0);
	} else if (mode == 0) {
		ALBEDO = tint * snow * 0.25 * (1.0 + hum_strength * band) * shade_corners;
	} else {
		float screen_row = floor(uv.y * float(rows));
		float s = (screen_row + uv.x) * k + phase - offset;
		float row = floor(s);
		float shade = 0.0;
		if (row >= 0.0 && row < float(rows)) {
			float state = round(texelFetch(row_states, ivec2(int(row), 0), 0).r * 255.0);
			float v = (row + fract(uv.y * float(rows))) / float(rows);
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
		float scan = 0.88 + 0.12 * step(0.5, fract(uv.y * float(rows)));
		colour = colour * (1.0 + hum_strength * band);
		ALBEDO = colour * scan * shade_corners * brightness;
	}
}
