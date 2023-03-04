@tool
extends Node

@export var Map = preload("Map.tres")

# Load and parse JSON data from a map file https://watabou.github.io/city-generator
func load_json(json_file: String) -> Variant:
	var file = FileAccess.open(json_file, FileAccess.READ)
	if not file.is_open():
		push_error("Could not open file for reading map data %s" % json_file)
		return null

	var content = file.get_as_text()
	return JSON.parse_string(content)


func load(json_file: String) -> Resource:
	var to_return = Map.duplicate(true)
	var json = load_json(json_file)

	for feature in json["features"]:
		to_return.build_feature(feature)

	# Now setup options such as road width etc
	to_return.configure()

	return to_return
