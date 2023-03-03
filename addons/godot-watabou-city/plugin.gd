@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("WatabouCity", "res://addons/godot-watabou-city/WatabouCity.gd")


func _exit_tree():
	remove_autoload_singleton("WatabouCity")
