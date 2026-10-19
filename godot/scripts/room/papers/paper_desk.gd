class_name PaperDesk
extends Node

## Lays out the window's papers: the pinned ones on the wall where they hang, a centred one in
## front of the keyboard, the kept ones and the rest from the start on the stacks left and right,
## and the tube's in its tray once their time has come, each with a capsule's thunk. Remembers
## what the player hangs on the pin wall.

## Metres between stacked papers, on the desk and in the tray.
const STACK := 0.003

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

## Read and written. PinnedPaper entries on the pin wall. Kept across windows.
@export var pinned: ResourceListValue

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

## Lays the start papers on the centre and the stacks, and lines up the tube papers.
func _ready() -> void:
	var window := current_pass.value as PassWindow
	if window == null:
		return

	var on_wall: Array[Paper] = []
	for entry: PinnedPaper in pinned.value:
		_place(entry.paper, entry.at)
		on_wall.append(entry.paper)

	var papers := kept + window.papers
	if not ack_heard.value:
		papers.append(missed_ack)

	var heights: Dictionary[Node3D, int] = { }
	var turn := 0
	for paper: Paper in papers:
		if on_wall.has(paper):
			continue

		if paper.arrives_at > 0.0:
			_waiting.append(paper)
			continue

		var anchor := centre if paper.centred else stacks[turn % stacks.size()]
		turn += 0 if paper.centred else 1
		var height: int = heights.get(anchor, 0)
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
		var spot := tray.global_transform.translated(Vector3.UP * STACK * _arrived)
		_place(_waiting[_arrived], spot)
		_arrived += 1
		capsule_waiting.value = 1.0
		capsule_arrived.raise()

## A new DeskPaper for `paper` at `at`.
func _place(paper: Paper, at: Transform3D) -> void:
	var sheet := DeskPaper.new()
	sheet.paper = paper
	sheet.current_pass = current_pass
	sheet.reading = reading
	sheet.put_down = put_down
	add_child(sheet)
	sheet.global_transform = at

## Stops the tube's lamp once a delivered paper is picked up, and takes a paper picked off the
## pin wall off the pinned list.
func _on_reading(_previous: Variant, _current: Variant) -> void:
	var paper := reading.value as Paper
	if paper != null and _waiting.has(paper):
		capsule_waiting.value = 0.0

	for entry: PinnedPaper in pinned.value:
		if entry.paper == paper:
			pinned.remove(entry)

## Pins the paper in hand when it is hung upright, i.e. put down on the pin wall.
func _on_put_down(at: Variant) -> void:
	var placed: Transform3D = at
	var paper := reading.value as Paper
	if paper == null or placed.basis.y.dot(Vector3.UP) > 0.5:
		return

	var entry := PinnedPaper.new()
	entry.paper = paper
	entry.at = placed
	pinned.add(entry)

## True when `first` arrives before `second`.
func _earlier(first: Paper, second: Paper) -> bool:
	return first.arrives_at < second.arrives_at
