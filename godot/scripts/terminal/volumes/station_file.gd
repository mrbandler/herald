class_name StationFile
extends Resource

## A file on one of the station's volumes: where it lives, what it says, and what unlocks it.

## The full path with its volume, e.g. `USR:OKONJO/WAKE.TXT`.
@export var path := ""

## The file's text when written inline, for tests and short files. Empty reads the Markdown
## file next to this resource instead. Authored at 60 columns or less.
@export_multiline var text := ""

## The module that makes the file exist, e.g. `TLM`. Empty for always.
@export var unlocked_by := ""

## The file's text: `text`, or the sibling `.md` of a saved resource, e.g. `wake.txt.md` next to
## `wake.txt.tres`. shortcut: the pair breaks if only one of them moves; the content test
## catches it, an import plugin would fix it for good.
func body() -> String:
	if not text.is_empty() or resource_path.is_empty():
		return text

	return FileAccess.get_file_as_string(resource_path.get_basename() + ".md")

## The volume part of the path, before the colon, e.g. `USR`.
func volume() -> String:
	return path.get_slice(":", 0)
