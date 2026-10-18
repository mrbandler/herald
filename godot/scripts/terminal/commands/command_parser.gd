class_name CommandParser
extends RefCounted

## Splits a command line into upper-case words. Commas separate like spaces: "GET 21, 23".


## The upper-case words of a line, split on spaces and commas. Empty for a blank line.
static func parse(line: String) -> PackedStringArray:
	return line.to_upper().replace(",", " ").split(" ", false)
