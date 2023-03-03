extends Node2D

var map

func _ready():
	self.map = WatabouCity.create_from_json("res://demo/trunwick.json")
	self.map.draw_all(self)
