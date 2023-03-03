extends RefCounted

var id: String = ""
var geometry: Array = []


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
func coordinates_to_packed_vector2(coordinates: Array) -> PackedVector2Array:
	if len(coordinates) == 1:
		coordinates = coordinates[0]
	
	return coordinates.map(coordinate_to_vector2)


# Args:
#   item (Dictionary): An item in dictionary format containing a "type" key and a "coordinates" key
#
# Returns:
#   Object: An Object instance (not used)
func convert_item(item: Dictionary) -> Object:
	match item.type:
		"LineString":
			var line = Line2D.new()
			line.set_joint_mode(Line2D.LINE_JOINT_BEVEL)
			line.set_end_cap_mode(Line2D.LINE_CAP_ROUND)
			line.set_begin_cap_mode(Line2D.LINE_CAP_ROUND)

			line.set_points(coordinates_to_packed_vector2(item.coordinates))
			self.geometry.append(line)
		
		"Polygon":
			var poly = Polygon2D.new()
			poly.set_polygon(coordinates_to_packed_vector2(item.coordinates))
			self.geometry.append(poly)
		
		"MultiPolygon":
			for subitem in item.coordinates:
				self.convert_item({ "type": "Polygon", "coordinates": subitem })
		
		"MultiPoint":
			pass
		
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
		if typeof(item) == TYPE_ARRAY and len(item) == 1:
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


# Draw the geometry on a parent Node
#
# Args:
#   parent (Node): The parent Node to add the geometry children to
#   color (Color): The color to draw the polygon or line in
#   z_index (int): Which z-index to draw the geometry at
#
# Returns:
#   void
func draw(parent: Node, color: Color = Color.WHITE, z_index: int = 0) -> Array:
	var to_return = []

	for child in self.geometry:
		child.set_modulate(color)
		child.set_z_index(z_index)
		parent.add_child(child)
		to_return.append(child)

	return to_return
