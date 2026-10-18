class_name ModuleModel
extends Resource

## HERALD's decoder modules: their names and unlock banners, whether an AUTH key is valid, and
## how a stored item's rows show through its decoded text.

## The modules, in the order MOD lists them.
@export var modules := PackedStringArray(["TLM", "IMG", "SPC"])

## Lines printed under the unlock line, per module. A module without an entry prints none.
@export var banners: Dictionary[String, PackedStringArray] = { }

## Characters a noisy row scatters into its line.
@export var noise_characters := "#%&*?!@"

## Characters replaced per noisy row in a line.
@export var noise_per_row := 2

## True for an AUTH item whose every row arrived. Noisy rows count; lost or unsent ones don't.
func is_valid_key(stored: StoredItem) -> bool:
	return stored.item.type == "AUTH" and stored.missing() == 0

## The module that decodes `type`, or empty when there is none.
func decoder_for(type: String) -> String:
	return type if modules.has(type) else ""

## The banner lines for `module`, or none.
func banner(module: String) -> PackedStringArray:
	var lines: PackedStringArray = banners.get(module, PackedStringArray())
	return lines

## The item's content lines with its row damage: a line with a lost or unsent row is blacked
## out, a noisy line gets characters scattered into it. The item id seeds the noise.
func decode_lines(stored: StoredItem) -> PackedStringArray:
	var content := stored.item.content.rstrip("\n")
	if content.is_empty():
		return PackedStringArray()

	var lines := content.split("\n")
	var rng := RandomNumberGenerator.new()
	rng.seed = stored.item.id

	var decoded := PackedStringArray()
	for i: int in range(lines.size()):
		var span := _span(i, lines.size(), stored.item.rows)
		decoded.append(_damage(lines[i], stored, span, rng))

	return decoded

## The rows [x, y) that line `index` of `count` covers out of `rows`. Every line gets a row.
func _span(index: int, count: int, rows: int) -> Vector2i:
	var start := floori(float(index * rows) / count)
	var end := floori(float((index + 1) * rows) / count)
	return Vector2i(start, clampi(maxi(end, start + 1), 0, rows))

## `line` blacked out when a row in `span` is lost or unsent, noised for its noisy rows, or as is.
func _damage(
	line: String,
	stored: StoredItem,
	span: Vector2i,
	rng: RandomNumberGenerator,
) -> String:
	var noisy := 0
	for row: int in range(span.x, span.y):
		if row >= stored.grades.size() or stored.grades[row] == DownlinkModel.Grade.LOST:
			return "▒".repeat(line.length())

		if stored.grades[row] == DownlinkModel.Grade.NOISY:
			noisy += 1

	if noisy == 0:
		return line

	return _scatter(line, noisy * noise_per_row, rng)

## `line` with up to `count` distinct non-space characters replaced by noise characters.
func _scatter(line: String, count: int, rng: RandomNumberGenerator) -> String:
	var characters := PackedStringArray()
	var spots := PackedInt32Array()
	for i: int in range(line.length()):
		characters.append(line[i])
		if line[i] != " ":
			spots.append(i)

	for k: int in range(mini(count, spots.size())):
		# Partial Fisher-Yates: move a random remaining spot to place k, so spots never repeat.
		var pick := rng.randi_range(k, spots.size() - 1)
		var spot := spots[pick]
		spots[pick] = spots[k]
		spots[k] = spot
		characters[spot] = noise_characters[rng.randi_range(0, noise_characters.length() - 1)]

	return "".join(characters)
