extends Resource

var PackedGeometry = preload("GeometryCollection.gd")

@export var values: Dictionary = {}

var indexes = {
	"buildings": 1,
	"earth": -1,
	"fields": 1,
	"greens": 1,
	"planks": 1,
	"rivers": 1,
	"roads": 1,
	"trees": 1,
	"walls": 1,
	"water": 1,
	"squares": 1,

	# Misc
	"districts": 2,
	"prisms": 2,
}

var colors = {
	"buildings": Color.BLACK,
	"earth": Color.WHITE,
	"fields": Color.GREEN,
	"greens": Color.GREEN,
	"planks": Color.BLACK,
	"rivers": Color.BLUE,
	"roads": Color.BLACK,
	"trees": Color.GREEN,
	"walls": Color.BROWN,
	"water": Color.BLUE,
	"squares": Color(1, 1, 0, 0.2),

	# Misc
	"districts": Color(1, 0, 0, 0.2),
	"prisms": Color(0, 1, 0, 0.2),
}

var geometries = {
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

func build_feature(item: Dictionary) -> void:
	match item.type:
		"Feature":
			pass
		
		"GeometryCollection", "MultiPolygon", "MultiPoint", "Polygon":
			if not item.id in self.geometries:
				push_error("Map has no variable to store <%s>" % item.id)
				return

			self.geometries[item.id] = PackedGeometry.new(item)

		_:
			push_error("No feature converter defined for type <%s>" % item.type)



func draw_all(parent: Node) -> void:
	for key in self.geometries:
		self.geometries[key].draw(parent, colors[key], indexes[key])
