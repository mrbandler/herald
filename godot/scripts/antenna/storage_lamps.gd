class_name StorageLamps
extends Node3D

## A row of lamps showing how full local storage is: one lit lamp per used unit. Its children
## are the lamps, in order.

## Lit and dark emission energies.
@export var model: LampModel

## Counts the used units.
@export var downlink_model: DownlinkModel

## Read. Local storage: StoredItem resources. Kept across windows.
@export var storage: ResourceListValue

## Lit colour. Unlit, the lamps show it darkened.
@export var color := Color(0.3, 0.8, 1.0)

## One material per child lamp.
var _materials: Array[StandardMaterial3D] = []

## Builds the lamp materials and draws the current fill; kept storage emits nothing on load.
func _ready() -> void:
	for child: Node in get_children():
		var lamp := child as MeshInstance3D
		var material := StandardMaterial3D.new()
		material.albedo_color = color.darkened(0.7)
		material.emission_enabled = true
		material.emission = color
		lamp.material_override = material
		_materials.append(material)

	storage.updated.connect(_on_storage)
	_refresh()

## Lamps lit for the current storage, capped at the number of lamps.
func lit() -> int:
	return mini(downlink_model.units(storage.value), _materials.size())

## Lights the first `lit()` lamps and darkens the rest.
func _refresh() -> void:
	var count := lit()
	for i: int in range(_materials.size()):
		var on := i < count
		_materials[i].emission_energy_multiplier = model.on_energy if on else model.off_energy

## Redraws when storage changes.
func _on_storage(_previous: Variant, _current: Variant) -> void:
	_refresh()
