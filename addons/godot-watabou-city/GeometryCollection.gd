@tool
extends RefCounted

var Helpers = preload("Helpers.gd")
var TreeShape = preload("TreeShape.gd")

var id: String = ""
var geometry: Array = []


func is_holding_array(item) -> bool:
	return typeof(item) == TYPE_ARRAY and len(item) == 1


# Args:
#   coordinate (Array): The 2D coordinate in array format [x, y]
#
# Returns:
#   Vector2: A Vector2 object with the same x and y values as the input coordinate array.
func coordinate_to_vector2(coordinate: Array) -> Vector2:
	return Vector2(coordinate[0], coordinate[1])


# Args:
#   coordinates (Array): An array of 2D coordinates in array format [x, y]
#
# Returns:
#   PackedVector2Array: A PackedVector2Array object containing Vector2
#   objects with the same x and y values as the input coordinates array.
func coordinates_to_packed_vector2(coords: Array) -> PackedVector2Array:
	if is_holding_array(coords):
		coords = coords[0]

	if "walls" in self.id:
		coords.append(coords[0])

	return coords.map(coordinate_to_vector2)


func apply_smoothing_cases(line: Line2D) -> Line2D:
	if self.id in ["rivers", "water", "greens", "roads"]:
		Helpers.smooth_line2d(line)

	return line

# Args:
#   item (Dictionary): An item in dictionary format containing a "type" key and a "coordinates" key
#
# Returns:
#   Object: An Object instance (not used)
func convert_item(item: Dictionary) -> Object:
	match item.type:
		"LineString":
			var line = Line2D.new()
			line.set_sharp_limit(2)
			line.set_joint_mode(Line2D.LINE_JOINT_BEVEL)
			line.set_end_cap_mode(Line2D.LINE_CAP_ROUND)
			line.set_begin_cap_mode(Line2D.LINE_CAP_ROUND)

			var coords = item.coordinates
			line.set_points(coordinates_to_packed_vector2(coords))

			# Apply smoothing to certain types of line
			line = self.apply_smoothing_cases(line)

			self.geometry.append(line)

		"Polygon":
			var poly = Polygon2D.new()
			poly.set_polygon(coordinates_to_packed_vector2(item.coordinates))
			self.geometry.append(poly)
		
		"MultiPolygon":
			for subitem in item.coordinates:
				self.convert_item({ "type": "Polygon", "coordinates": subitem })
		
		"MultiPoint":
			for coordinate in item.coordinates:
				self.geometry.append(TreeShape.random(coordinate))

		_:
			push_error("convert_item unsupported type: <%s>" % item.type)

	return Object()

# Fix bugs with the web implementation
func normalize_item(item: Dictionary) -> Dictionary:
	match self.id:
		"walls":
			item.type = "LineString"

	return item


# Args:
#   items (Array): An array of items in dictionary format
#
# Returns:
#   Array: An array of Geometry objects
func convert_array(items: Array) -> Array:
	var to_return = []
	
	for item in items:
		if is_holding_array(item):
			item = item[0]

		self.convert_item(normalize_item(item))
	
	return to_return


func _init(item: Dictionary) -> void:
	self.id = item.id
	
	if "coordinates" in item:
		self.convert_item(item)
	
	elif "geometries" in item:
		self.convert_array(item.geometries)
	
	else:
		push_error("Unsupported type")


