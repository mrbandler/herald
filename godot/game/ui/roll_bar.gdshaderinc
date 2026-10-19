// The roll bar of a CRT on film: a thin dark stripe of faded phosphor rolling up the picture,
// with a faint bright line at its leading edge.

// Distance of `y` from the bar's centre, wrapped, negative above it.
float roll_offset(float y, float time, float seconds) {
	float centre = 1.0 - fract(time / seconds);
	return fract(y - centre + 0.5) - 0.5;
}

// 0..1: how much of the stripe's darkness lies over `y`.
float roll_dark(float y, float time, float seconds, float width) {
	return smoothstep(width, 0.0, abs(roll_offset(y, time, seconds)));
}

// 0..1: how much of the bright leading edge, just above the stripe, lies over `y`.
float roll_edge(float y, float time, float seconds, float width) {
	float offset = roll_offset(y, time, seconds) + width;
	return smoothstep(width * 0.35, 0.0, abs(offset));
}
