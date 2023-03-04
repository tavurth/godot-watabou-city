@tool
extends Resource

var PackedGeometry = preload("res://addons/godot-watabou-city/GeometryCollection.gd")

@export var widths: Dictionary = {
	"roads": 1,
	"towers": 1,
	"walls": 1,
	"rivers": 1,
}: set = _set_widths

@export var z_indexes: Dictionary = {
	"buildings": 1,
	"earth": -1,
	"fields": 1,
	"greens": 1,
	"planks": 1,
	"rivers": 1,
	"roads": 1,
	"trees": 1,
	"walls": 1,
	"water": 0,
	"squares": 1,

	# Misc
	"districts": 2,
	"prisms": 2,
}: set = _set_z_indexes

@export var colors: Dictionary = {
	"buildings": Color.BLACK,
	"earth": Color(0.5, 0.8, 0.2, 0.4),
	"fields": Color.DARK_GREEN,
	"greens": Color.DARK_GREEN,
	"planks": Color.BLACK,
	"roads": Color.DARK_GRAY,
	"trees": Color.DARK_GREEN,
	"walls": Color.BROWN,
	"squares": Color(1, 1, 0, 0.2),

	"rivers": Color.NAVY_BLUE,
	"water": Color.NAVY_BLUE,

	# Misc
	"districts": Color(0, 0, 0.5, 0.2),
	"prisms": Color(0, 1, 0, 0.2),
}: set = _set_colors

@export var geometries: Dictionary = {
	"buildings": null,
	"districts": null,
	"earth": null,
	"fields": null,
	"greens": null,
	"planks": null,
	"prisms": null,
	"rivers": null,
	"roads": null,
	"squares": null,
	"trees": null,
	"walls": null,
	"water": null
}


func _set_widths(new_widths: Dictionary) -> void:
	widths = new_widths
	self.configure()


func _set_colors(new_colors: Dictionary) -> void:
	colors = new_colors
	self.configure()


func _set_z_indexes(new_indexes: Dictionary) -> void:
	z_indexes = new_indexes
	self.configure()


func build_feature(item: Dictionary) -> void:
	match item.type:
		"Feature":
			self.widths.towers = item.towerRadius
			self.widths.rivers = item.riverWidth
			self.widths.roads = item.roadWidth
			self.widths.walls = item.wallThickness

		"GeometryCollection", "MultiPolygon", "MultiPoint", "Polygon":
			if not item.id in self.geometries:
				push_error("Map has no variable to store <%s>" % item.id)
				return

			var new_parent = Node2D.new()

			# Create a new PackedGeometry which extracts
			# and generates geometry nodes.
			# Then map them to be added to the new_parent
			PackedGeometry\
				.new(item)\
				.geometry\
				.map(new_parent.add_child)

			# Keep track of only that new parent
			self.geometries[item.id] = new_parent

		_:
			push_error("No feature converter defined for type <%s>" % item.type)


func configure() -> void:
	for key in self.geometries:
		
		var child = self.geometries[key]
		child.set_z_index(self.z_indexes[key])
		child.set_modulate(self.colors[key])
		
		if not key in self.widths:
			continue
		
		for subitem in child.get_children():
			subitem.set_width(self.widths[key])


func draw(parent: Node) -> void:
	for key in self.geometries:
		parent.add_child(geometries[key])
