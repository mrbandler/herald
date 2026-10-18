class_name AtomSpy
extends RefCounted

## Records every `updated` or `raised` emission of an atom, for tests.

var calls: Array = []

static func values(atom: Value) -> AtomSpy:
	var spy := AtomSpy.new()
	atom.updated.connect(spy.record_update)
	return spy

static func events(event: Event) -> AtomSpy:
	var spy := AtomSpy.new()
	event.raised.connect(spy.record_payload)
	return spy

func record_update(previous: Variant, current: Variant) -> void:
	calls.append([previous, current])

func record_payload(payload: Variant) -> void:
	calls.append(payload)
