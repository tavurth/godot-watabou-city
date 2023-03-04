@tool
extends Node

var Map = preload("Map.tres")


func load(json_file: String) -> Resource:
	var to_return = Map.duplicate(true)
	to_return.load(json_file)
	return to_return
