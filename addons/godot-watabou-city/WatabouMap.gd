@tool
class_name WatabouMap
extends Resource

var GeometryCollection = preload("res://addons/godot-watabou-city/GeometryCollection.gd")

@export_file("*.json") var file_name: String = "": set = _set_filename

@export var load_json_defaults := false: set = _reset_to_json

@export var widths: Dictionary = {
	"roads": 0,
	"towers": 0,
	"walls": 0,
	"rivers": 0,
}: set = _set_widths

@export var z_indexes: Dictionary = {
	"buildings": 1,
	"fields": 0,
	"greens": 1,
	"planks": 3,
	"rivers": 0,
	"roads": 2,
	"trees": 2,
	"walls": 3,
	"water": 0,
	"squares": 1,

	# Base
	"earth": -1,

	# Misc
	"prisms": 0,
	"districts": 0,
}: set = _set_z_indexes

@export var colors: Dictionary = {
	"buildings": Color("A5A095"),
	"earth": Color.WHITE,
	"fields": Color("A5A095"),
	"greens": Color("999388"),
	"planks": Color("1A1917"),
	"roads": Color("CCC5B8"),
	"trees": Color("7F7A71"),
	"walls": Color("1A1917"),
	"squares": Color("CCC5B8"),

	"rivers": Color("7F7A71"),
	"water": Color("7F7A71"),

	# Misc
	"districts": Color(0, 0, 0.5, 0.2),
	"prisms": Color(0, 1, 0, 0.2),
}: set = _set_colors

var geometries: Dictionary = {
	"buildings": CanvasGroup.new(),
	"districts": CanvasGroup.new(),
	"earth": CanvasGroup.new(),
	"fields": CanvasGroup.new(),
	"greens": CanvasGroup.new(),
	"planks": CanvasGroup.new(),
	"prisms": CanvasGroup.new(),
	"rivers": CanvasGroup.new(),
	"roads": CanvasGroup.new(),
	"squares": CanvasGroup.new(),
	"trees": CanvasGroup.new(),
	"walls": CanvasGroup.new(),
	"water": CanvasGroup.new()
}

func _reset_to_json(new_reset: bool) -> void:
	if not new_reset:
		return

	for key in widths:
		widths[key] = 0

	print("Reloading map data from %s" % self.file_name)
	self.load()
	self.configure()


func _set_filename(new_file_name: String) -> void:
	if file_name == new_file_name:
		return

	if len(new_file_name) < 1:
		return
	
	file_name = new_file_name
	self.load()
	self.configure()


func _set_widths(new_widths: Dictionary) -> void:
	widths = new_widths
	self.configure()


func _set_colors(new_colors: Dictionary) -> void:
	colors = new_colors
	self.configure()


func _set_z_indexes(new_indexes: Dictionary) -> void:
	z_indexes = new_indexes
	self.configure()


func set_width(name: String, new_value: float) -> void:
	if widths[name] == 0:
		widths[name] = new_value


func build_feature(item: Dictionary) -> void:
	match item.type:
		"Feature":
			self.set_width("towers", item.towerRadius)
			self.set_width("rivers", item.riverWidth)
			self.set_width("roads", item.roadWidth)
			self.set_width("walls", item.wallThickness)

		"GeometryCollection", "MultiPolygon", "MultiPoint", "Polygon":
			if not item.id in self.geometries:
				push_error("Map has no variable to store <%s>" % item.id)
				return

			var container = self.geometries[item.id]

			# Remove old data if we have some
			for child in container.get_children():
				container.remove_child(child)
				child.queue_free()

			# Create a new GeometryCollection which extracts
			# and generates geometry nodes.
			# Then map them to be added to the new_parent
			GeometryCollection\
				.new(item)\
				.geometry\
				.map(container.add_child)

		_:
			push_error("No feature converter defined for type <%s>" % item.type)


func configure() -> void:
	for key in self.geometries:
		
		var child = self.geometries[key]
		if not child:
			continue
		
		child.set_z_index(self.z_indexes[key])
		child.set_modulate(self.colors[key])
		
		if not key in self.widths:
			continue
		
		for subitem in child.get_children():
			subitem.set_width(self.widths[key])


func draw(parent: Node) -> void:
	var geometry

	for key in self.geometries:
		geometry = geometries[key]
		geometry.set_name(key)

		if parent.is_ancestor_of(geometry):
			continue

		parent.add_child(geometry)


# Load and parse JSON data from a map file https://watabou.github.io/city-generator
func load_json(json_file: String) -> Variant:
	var file = FileAccess.open(json_file, FileAccess.READ)

	if not file or not file.is_open():
		push_error("Could not open file for reading map data %s" % json_file)
		return null

	var content = file.get_as_text()
	return JSON.parse_string(content)


# Load a watabou map into this resource item from a json file
func load(json_file: String = self.file_name) -> Resource:
	# Save the file name incase we want to reset later
	file_name = json_file

	# Load the json data
	var json = self.load_json(json_file)

	for feature in json["features"]:
		self.build_feature(feature)

	# Now setup options such as road width etc
	self.configure()

	return self
