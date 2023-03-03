extends Camera2D

# camera movement speed
@export var camera_speed = 500

# camera zoom speed
@export var zoom_speed = 0.1

# mouse panning
var is_panning = false
var mouse_start_pos = Vector2.ZERO

func _input(event):
	if event is InputEventMagnifyGesture:
		self.zoom *= event.factor

	elif event is InputEventScreenDrag:
		self.global_position -= event.delta

	elif event is InputEventPanGesture:
		self.global_position += event.delta * 10


func _process(delta: float) -> void:
	# handle keyboard input for panning and zooming
	var pan_direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		pan_direction.x += 1

	elif Input.is_action_pressed("ui_left"):
		pan_direction.x -= 1

	if Input.is_action_pressed("ui_down"):
		pan_direction.y += 1

	elif Input.is_action_pressed("ui_up"):
		pan_direction.y -= 1

	# update camera position and zoom level
	position += pan_direction.normalized() * camera_speed * delta
