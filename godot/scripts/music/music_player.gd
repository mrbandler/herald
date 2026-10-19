class_name MusicPlayer
extends AudioStreamPlayer

## Plays the background music. The main thread reads the antenna knob and the pass into a
## snapshot; a worker thread renders from it, so a slow frame never starves the audio.

## Supplies the levels, the stress and the synth's numbers.
@export var model: MusicModel

## Read. The antenna knob 0..1: the lower, the more music.
@export var volume: FloatValue

## Read. Seconds since pass start, for the stress.
@export var pass_time: FloatValue

## Read. Supplies the pass marks.
@export var current_pass: ResourceValue

## Target bed level 0..1. Written by `tick()`, read by the worker, both under `_mutex`.
var bed := 0.0

## Target melody level 0..1. Written by `tick()`, read by the worker, both under `_mutex`.
var melody := 0.0

## Target stress 0..1. Written by `tick()`, read by the worker, both under `_mutex`.
var stress := 0.0

## Guards the snapshot and `_stop` between the main thread and the worker.
var _mutex := Mutex.new()

## Set under `_mutex` to end the worker loop.
var _stop := false

## The worker that renders and pushes. Null until `_ready`.
var _thread: Thread

## Where the worker pushes frames. Only the worker touches it after `_ready`.
var _playback: AudioStreamGeneratorPlayback

## Renders the samples. Only the worker touches it after `_ready`.
var _synth: MusicSynth

## Builds the generator, starts it, and only then starts the worker.
func _ready() -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = model.mix_rate
	generator.buffer_length = 0.2
	stream = generator

	play()

	_playback = get_stream_playback() as AudioStreamGeneratorPlayback
	_synth = MusicSynth.new(model, randi())
	_thread = Thread.new()
	_thread.start(_run)

## Refreshes the snapshot every frame.
func _process(_delta: float) -> void:
	tick()

## Writes the bed, melody and stress targets for the current knob and pass time.
func tick() -> void:
	var knob := volume.value
	var window := current_pass.value as PassWindow
	var next_bed := model.bed_level(knob)
	var next_melody := model.melody_level(knob)
	var next_stress := model.stress_at(window, pass_time.value)

	_mutex.lock()
	bed = next_bed
	melody = next_melody
	stress = next_stress
	_mutex.unlock()

## Renders `frames` frames from the snapshot and pushes them. Worker thread only.
func fill(frames: int) -> void:
	if frames <= 0:
		return

	_mutex.lock()
	var target_bed := bed
	var target_melody := melody
	var target_stress := stress
	_mutex.unlock()

	_playback.push_buffer(_synth.render(frames, target_bed, target_melody, target_stress))

## Stops the worker before the node leaves, so it never pushes into a freed scene.
func _exit_tree() -> void:
	if _thread == null:
		return

	_mutex.lock()
	_stop = true
	_mutex.unlock()

	_thread.wait_to_finish()
	_thread = null

## Worker loop: keeps the generator's buffer full until stopped.
func _run() -> void:
	while not _stopping():
		fill(_playback.get_frames_available())
		OS.delay_msec(10)

## True once `_exit_tree` asked the worker to stop.
func _stopping() -> bool:
	_mutex.lock()
	var stopping := _stop
	_mutex.unlock()

	return stopping
