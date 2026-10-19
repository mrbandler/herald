extends GdUnitTestSuite

const ROOTS: PackedStringArray = ["res://game/data/volumes", "res://game/data/papers"]

func _files(dir: String, extension: String) -> PackedStringArray:
	var found := PackedStringArray()
	for sub: String in DirAccess.get_directories_at(dir):
		found.append_array(_files(dir.path_join(sub), extension))
	for file: String in DirAccess.get_files_at(dir):
		if file.ends_with(extension):
			found.append(dir.path_join(file))
	return found

func test_every_text_resource_has_its_markdown() -> void:
	var checked := 0
	for root: String in ROOTS:
		for path: String in _files(root, ".tres"):
			var resource: Resource = load(path)
			var inline: String = resource.get("text")
			if not inline.is_empty():
				continue
			var markdown := path.get_basename() + ".md"
			var body := FileAccess.get_file_as_string(markdown)
			assert_str(body.strip_edges()).override_failure_message(markdown).is_not_empty()
			checked += 1
	assert_int(checked).is_greater(0)

func test_every_markdown_file_has_its_resource() -> void:
	for root: String in ROOTS:
		for path: String in _files(root, ".md"):
			var resource := path.get_basename() + ".tres"
			assert_bool(FileAccess.file_exists(resource)).override_failure_message(path).is_true()

func test_every_export_preset_ships_the_markdown() -> void:
	var presets := ConfigFile.new()
	assert_int(presets.load("res://export_presets.cfg")).is_equal(OK)
	var count := 0
	for section: String in presets.get_sections():
		if not section.begins_with("preset.") or section.ends_with(".options"):
			continue
		var filter: String = presets.get_value(section, "include_filter", "")
		assert_str(filter).override_failure_message(section).contains("*.md")
		count += 1
	assert_int(count).is_greater(0)
