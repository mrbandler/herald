class_name AtomSpy
extends RefCounted

## Records every `updated` emission of an atom, for tests. Task 5 adds events.

var calls: Array = []


static func values(atom: Value) -> AtomSpy:
	var spy := AtomSpy.new()
	atom.updated.connect(spy.record_update)
	return spy


func record_update(previous: Variant, current: Variant) -> void:
	calls.append([previous, current])
