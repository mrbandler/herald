class_name PaperSheet
extends Node3D

## The look of a paper, facing +Z: its Markdown text is drawn onto a paper-coloured page off
## screen, and that page is shown on a quad, so papers get headings, bold and lists.

## Paper colour.
const PAPER := Color(0.86, 0.82, 0.7)

## Ink colour.
const INK := Color(0.12, 0.1, 0.08)

## Page pixels per metre of paper. With `FONT_SIZE`, about 20 lines fit on a letter.
const PIXELS_PER_METRE := 2400.0

## Page pixels from the edge to the text.
const MARGIN := 18.0

## Body font size in page pixels, where every page starts.
const FONT_SIZE := 18

## The smallest font size a page shrinks to, so a long text still fits its paper.
const MIN_FONT_SIZE := 11

## The paper.
var quad := MeshInstance3D.new()

## The text, rendered from Markdown.
var page := MarkdownLabel.new()

## Draws the page off screen.
var _viewport := SubViewport.new()

## The paper's material, showing the page and lit by the room unless the sheet is unlit.
var _material := StandardMaterial3D.new()

## The page's current font size; it shrinks until the text fits.
var font_size := FONT_SIZE

## Frames to wait after new text before measuring, while the page converts and lays it out.
var _settling := 0

## Builds the page, its viewport and the quad, so a sheet can be filled before it enters the
## tree.
func _init() -> void:
	var background := ColorRect.new()
	background.color = PAPER
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_viewport.add_child(background)

	page.position = Vector2(MARGIN, MARGIN)
	page.scroll_active = false
	page.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_theme_color_override("default_color", INK)
	_apply_font_size(FONT_SIZE)

	_viewport.add_child(page)
	_viewport.disable_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)

	_material.albedo_color = Color.WHITE
	quad.mesh = QuadMesh.new()
	quad.material_override = _material
	add_child(quad)

## Shows the page on the quad once the viewport can hand out its texture.
func _ready() -> void:
	_material.albedo_texture = _viewport.get_texture()

## Shrinks the font a step each frame while the laid-out text runs past the page.
func _process(_delta: float) -> void:
	fit()

## Shrinks the font one step if the text is taller than the page, down to `MIN_FONT_SIZE`.
## The page lays out over a frame, so this runs every frame and waits a little after new text.
func fit() -> void:
	if _settling > 0:
		_settling -= 1
		return

	if page.get_content_height() > page.size.y and font_size > MIN_FONT_SIZE:
		_apply_font_size(font_size - 1)

## Sizes the paper to `size` in metres and lays `text`, Markdown, onto its page.
func show_paper(size: Vector2, text: String) -> void:
	(quad.mesh as QuadMesh).size = size
	var pixels := Vector2i(roundi(size.x * PIXELS_PER_METRE), roundi(size.y * PIXELS_PER_METRE))
	_viewport.size = pixels
	page.size = Vector2(pixels) - Vector2.ONE * 2.0 * MARGIN
	_apply_font_size(FONT_SIZE)
	page.markdown_text = text
	_settling = 2

## Turns the room's lighting off for this sheet, so a paper held up to the eye stays readable
## from any side of the lamp.
func unlit() -> void:
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

## Sets every text style on the page to `size` pixels.
func _apply_font_size(size: int) -> void:
	font_size = size
	for style: String in ["normal", "bold", "italics", "bold_italics", "mono"]:
		page.add_theme_font_size_override(style + "_font_size", size)

## The page size in pixels, for tests.
func page_pixels() -> Vector2i:
	return _viewport.size
