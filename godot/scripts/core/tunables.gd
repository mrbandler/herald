class_name Tunables
extends Resource

## Staging area for loose tunable numbers while a feature is being built.
## Once a feature has two or three values here, or when it is done, move them into its model.

## Seconds the screen takes to fade to black at the morning bell.
@export var shift_fade_seconds := 3.0
## Seconds before the morning bell that the desk lamp starts to flicker.
@export var sleep_warning_seconds := 15.0
