class_name PaperDesk
extends Node

## Lays out the papers: every paper from earlier windows where the Listener left it, a new
## centred one in front of the keyboard, the other new ones from the start on the stacks left and
## right, and the tube's in its tray once their time has come, each with a capsule's thunk.
## Remembers where every paper lies.

## Metres between stacked papers, on the desk and in the tray.
const STACK := 0.003

## Metres from a stack's spot within which a remembered paper counts as lying on that stack.
const LYING_RADIUS := 0.05

## Read. Supplies the papers.
@export var current_pass: ResourceValue

## Read. Seconds into the pass, compared with each tube paper's arrival.
@export var pass_time: FloatValue

## Handed to every paper: the paper in hand.
@export var reading: ResourceValue

## Handed to every paper: where the paper in hand goes.
@export var put_down: Event

## Raised once per paper the tube delivers.
@export var capsule_arrived: Event

## Written. 1 while a delivered paper waits in the tray unread, 0 once one is picked up. The
## tube's lamp blinks on it.
@export var capsule_waiting: FloatValue

## Papers on the desk in every window, before the window's own, e.g. the handover letter.
@export var kept: Array[Paper] = []

## Read. False when HERALD never heard last window's ACK.
@export var ack_heard: BoolValue

## Comes with the window's papers when HERALD never heard last window's ACK: the insider spells
## the heartbeat out.
@export var missed_ack: Paper

## Read and written. Where every paper lies: PlacedPaper entries. Kept across windows, so papers
## stay where the Listener left them, except another window's prayer card, which goes.
@export var placed: ResourceListValue

## Where a centred paper lies, in front of the keyboard.
@export var centre: Node3D

## The stacks the other papers from the start take turns on, left first.
@export var stacks: Array[Node3D] = []

## Where tube papers land, stacked.
@export var tray: Node3D

## The window's tube papers, in arrival order.
var _waiting: Array[Paper] = []

## How many tube papers have arrived.
var _arrived := 0

## Papers already lying in the tray from earlier windows, so new ones land on top.
var _tray_base := 0

## Lays every paper where it was left, the new start papers on the centre and the stacks, and
## lines up the tube papers.
func _ready() -> void:
	var window := current_pass.value as PassWindow
	if window == null:
		return

	var lying: Array[Paper] = []
	for entry: PlacedPaper in placed.value:
		# An old prayer card would send the Listener to last night's coordinates.
		if entry.paper.centred and not window.papers.has(entry.paper):
			placed.remove(entry)
			continue

		_place(entry.paper, entry.at)
		lying.append(entry.paper)

	_tray_base = _lying_at(tray)

	var papers := kept + window.papers
	if not ack_heard.value:
		papers.append(missed_ack)

	var heights: Dictionary[Node3D, int] = { }
	var turn := 0
	for paper: Paper in papers:
		if lying.has(paper):
			continue

		if paper.arrives_at > 0.0:
			_waiting.append(paper)
			continue

		var anchor := centre if paper.centred else stacks[turn % stacks.size()]
		turn += 0 if paper.centred else 1
		var height: int = heights.get(anchor, _lying_at(anchor))
		_place(paper, anchor.global_transform.translated(Vector3.UP * STACK * height))
		heights[anchor] = height + 1

	_waiting.sort_custom(_earlier)
	reading.updated.connect(_on_reading)
	put_down.raised.connect(_on_put_down)

## Delivers papers as their time comes.
func _process(_delta: float) -> void:
	tick()

## Puts every tube paper whose time has come into the tray, so a skip over several arrives them
## all, and raises `capsule_arrived` once per paper.
func tick() -> void:
	while _arrived < _waiting.size() and pass_time.value >= _waiting[_arrived].arrives_at:
		var spot := tray.global_transform.translated(Vector3.UP * STACK * (_tray_base + _arrived))
		_place(_waiting[_arrived], spot)
		_arrived += 1
		capsule_waiting.value = 1.0
		capsule_arrived.raise()

## A new DeskPaper for `paper` at `at`, remembered there.
func _place(paper: Paper, at: Transform3D) -> void:
	_remember(paper, at)

	var sheet := DeskPaper.new()
	sheet.paper = paper
	sheet.current_pass = current_pass
	sheet.reading = reading
	sheet.put_down = put_down
	add_child(sheet)
	sheet.global_transform = at

## Stops the tube's lamp once a delivered paper is picked up.
func _on_reading(_previous: Variant, _current: Variant) -> void:
	var paper := reading.value as Paper
	if paper != null and _waiting.has(paper):
		capsule_waiting.value = 0.0

## Remembers where the paper in hand goes down.
func _on_put_down(at: Variant) -> void:
	var spot: Transform3D = at
	var paper := reading.value as Paper
	if paper != null:
		_remember(paper, spot)

## Records `paper` as lying at `at`, in place of where it lay before.
func _remember(paper: Paper, at: Transform3D) -> void:
	var entry := PlacedPaper.new()
	entry.paper = paper
	entry.at = at

	for old: PlacedPaper in placed.value:
		if old.paper == paper:
			placed.replace(old, entry)
			return

	placed.add(entry)

## How many remembered papers lie on `anchor`'s spot, so new ones stack on top.
func _lying_at(anchor: Node3D) -> int:
	var count := 0
	for entry: PlacedPaper in placed.value:
		if entry.at.origin.distance_to(anchor.global_position) < LYING_RADIUS:
			count += 1

	return count

## True when `first` arrives before `second`.
func _earlier(first: Paper, second: Paper) -> bool:
	return first.arrives_at < second.arrives_at
