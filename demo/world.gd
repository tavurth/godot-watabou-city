@tool
extends Node2D

@export var map: WatabouMap = WatabouMap.new():
	set = _set_map


func _set_map(new_map: WatabouMap) -> void:
	for child in self.get_children():
		self.remove_child(child)

	map = new_map
	map.draw(self)
