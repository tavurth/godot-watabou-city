extends RefCounted

const TreeModels = [
	preload("media/tree01.png"),
	preload("media/tree02.png"),
	preload("media/tree03.png"),
]

# Generate a random tree given a coordinate
static func random(coordinate: Array) -> Sprite2D:
	var rng = RandomNumberGenerator.new()

	var position = Vector2(coordinate[0], coordinate[1])
	rng.set_seed(hash(position))

	var to_return = Sprite2D.new()
	var texture = TreeModels[rng.randi_range(0, len(TreeModels)-1)]

	to_return.set_name("TreeModel")
	to_return.set_texture(texture)

	var scale = rng.randf() / 5.0 + 0.1
	to_return.set_scale(Vector2(scale, scale))
	to_return.set_position(position)
	
	return to_return
