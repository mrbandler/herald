class_name Monitor
extends Node

## Feeds the monitor's screen shader from the atoms: the item on show, the mode, and the knobs.

## Supplies the settings per mode, the row states and the look.
@export var model: MonitorModel

## The screen; its material override is the monitor shader.
@export var screen: GeometryInstance3D

## Read. The StoredItem on the monitor, null for snow.
@export var shown_item: ResourceValue

## Read. A `MonitorModel.Mode`.
@export var monitor_mode: IntValue

## Read. The LINE knob.
@export var knob_line: FloatValue

## Read. The OFFSET knob.
@export var knob_offset: FloatValue

## Read. The CONTRAST knob.
@export var knob_contrast: FloatValue

## The screen's shader material.
var _material: ShaderMaterial

## The row-state texture, rebuilt when the item or its rows change.
var _states: ImageTexture

## The item and row count the row states were built for.
var _built_for: StoredItem

## Rows sent when the row states were built.
var _built_rows := -1

## Finds the screen's material and sets the look.
func _ready() -> void:
	_material = screen.material_override as ShaderMaterial
	_material.set_shader_parameter("noise", model.noise)
	_material.set_shader_parameter("afterglow_rows", model.afterglow_rows)

## Feeds the shader every frame.
func _process(_delta: float) -> void:
	tick()

## Sets the shader's uniforms for the item on show in the current mode, or snow without one.
func tick() -> void:
	var stored := shown_item.value as StoredItem
	var mode := monitor_mode.value if stored != null else MonitorModel.Mode.SNOW
	_material.set_shader_parameter("mode", mode)
	if stored == null:
		return

	var knobs := Vector3(knob_line.value, knob_offset.value, knob_contrast.value)
	var tuned := model.settings(mode as MonitorModel.Mode, stored, knobs)
	var streaming := mode == MonitorModel.Mode.STREAM

	_material.set_shader_parameter("image", stored.item.image)
	_material.set_shader_parameter("rows", stored.item.rows)
	_material.set_shader_parameter("k", tuned.x / stored.item.line_length)
	_material.set_shader_parameter("phase", stored.item.phase)
	_material.set_shader_parameter("offset", tuned.y)
	_material.set_shader_parameter("contrast", tuned.z)
	_material.set_shader_parameter("newest_row", stored.sent() - 1 if streaming else -1)
	_material.set_shader_parameter("row_states", _row_states(stored))

## The row-state texture for `stored`, rebuilt only when it changed.
func _row_states(stored: StoredItem) -> ImageTexture:
	if stored != _built_for or stored.sent() != _built_rows:
		_states = ImageTexture.create_from_image(model.row_states(stored))
		_built_for = stored
		_built_rows = stored.sent()

	return _states
