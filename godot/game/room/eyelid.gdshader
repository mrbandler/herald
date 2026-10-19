// An eyelid with a soft edge: black inside the lid, fading out across `feather` around its edge.
shader_type canvas_item;

// Where the lid's edge lies, as a share of the screen's height from the top.
uniform float edge = 0.0;

// Half the height of the soft edge, as a share of the screen's height. 0 is a hard edge.
uniform float feather = 0.0;

// True for the upper lid, which covers the screen above its edge.
uniform bool from_top = true;

void fragment() {
	float inside = from_top ? edge - SCREEN_UV.y : SCREEN_UV.y - edge;
	float alpha = feather > 0.0 ? smoothstep(-feather, feather, inside) : step(0.0, inside);
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
