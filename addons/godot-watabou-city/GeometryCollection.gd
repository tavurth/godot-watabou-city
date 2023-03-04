@tool
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


func random_tree(coordinate: Array) -> Array:
	var rng = RandomNumberGenerator.new()

	var position = coordinate_to_vector2(coordinate)
	rng.set_seed(hash(position))

	var tree_size = 15
	var num_vectors = 10
	var angle_step = (PI * 2) / num_vectors

	# Now generate a circle of vectors from the origin
	var random_vectors = []
	for i in range(num_vectors):
		var angle = i * angle_step
		var rand = rng.randf() + 0.2;
		var vector = Vector2(tree_size * rand, 0).rotated(angle)
		random_vectors.append(vector)

	# And generate a point from each vector position
	var tree_points = []
	for vector in random_vectors:
		var point = position + vector
		tree_points.append(point)

	var smooth_tree = []

	# Add the first point to the smooth path
	smooth_tree.append(tree_points[0])
	# Iterate over the remaining points in the tree_points list
	for i in range(1, len(tree_points)):
		# Interpolate between the previous point and the current point with a weight of 0.5
		var interpolated_point = (
			tree_points[i-1] + tree_points[i]
		) / 2.0

		# Add the interpolated point to the smooth path
		smooth_tree.append(interpolated_point)

		# Add the current point to the smooth path
		smooth_tree.append(tree_points[i])

	smooth_tree[0] = (smooth_tree[0] + smooth_tree[-1]) / 2.0

	return smooth_tree


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
			line.set_joint_mode(Line2D.LINE_JOINT_SHARP)
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
			for coordinate in item.coordinates:
				var poly = Polygon2D.new()
				poly.set_polygon(self.random_tree(coordinate))
				self.geometry.append(poly)

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


