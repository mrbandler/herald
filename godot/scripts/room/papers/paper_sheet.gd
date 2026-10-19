class_name PaperSheet
extends Node3D

## The look of a paper, facing +Z: a paper-coloured quad with its text in ink on top.

## Paper colour.
const PAPER := Color(0.86, 0.82, 0.7)

## Ink colour.
const INK := Color(0.12, 0.1, 0.08)

## Metres from the paper's edge to its text.
const MARGIN := 0.01

## Metres per font pixel.
const PIXEL_SIZE := 0.0004

## Font size in pixels. With `PIXEL_SIZE`, about 20 lines fit on a letter.
const FONT_SIZE := 18

## The paper.
var quad := MeshInstance3D.new()

## The text on it.
var label := Label3D.new()

## The paper's material, lit by the room's lights unless the sheet is unlit.
var _material := StandardMaterial3D.new()

## Builds the quad and the label, so a sheet can be filled before it enters the tree.
func _init() -> void:
	_material.albedo_color = PAPER
	quad.mesh = QuadMesh.new()
	quad.material_override = _material
	add_child(quad)

	label.modulate = INK
	label.outline_size = 0
	label.shaded = true
	label.pixel_size = PIXEL_SIZE
	label.font_size = FONT_SIZE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	add_child(label)

## Sizes the paper to `size` in metres and writes `text` on it from its top-left margin. A
## left-aligned label starts its text at its own origin, so the origin sits on that margin.
func show_paper(size: Vector2, text: String) -> void:
	(quad.mesh as QuadMesh).size = size
	label.width = (size.x - 2.0 * MARGIN) / PIXEL_SIZE
	label.position = Vector3(MARGIN - size.x / 2.0, size.y / 2.0 - MARGIN, 0.0005)
	label.text = text

## Turns the room's lighting off for this sheet, so a paper held up to the eye stays readable
## from any side of the lamp.
func unlit() -> void:
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	label.shaded = false
