class_name HeraldCommand
extends Resource

## A command HERALD accepts in an uplinked sequence: how it is typed, what it does, and what
## unlocks it.

## What the player types after SEQ ADD.
@export var name := ""

## How it is typed with its arguments, e.g. `IMG <N> [L/H]`.
@export var usage := ""

## What it does, shown by HELP SEQ.
@export var description := ""

## The module, or an authorization a later window grants, that makes it available. Empty for
## always.
@export var unlocked_by := ""

## Blacks out the whole line while locked, name included, so it gives nothing away.
@export var hidden := false
