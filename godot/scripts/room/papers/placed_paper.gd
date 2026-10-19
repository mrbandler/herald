class_name PlacedPaper
extends Resource

## A paper and where it lies, on the desk, the pin wall or in the tray, so it stays there in later
## windows.

## The paper.
@export var paper: Paper

## Where it lies, in world space.
@export var at: Transform3D
