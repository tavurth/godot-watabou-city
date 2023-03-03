extends Node2D

var map

func _ready():
	self.map = WatabouCity.create_from_json("trunwick.json")
	self.map.draw_all(self)
