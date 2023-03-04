@tool
extends Node2D

var map

func _ready():
	print("HERE")
	self.map = WatabouCity.load("res://demo/trunwick.json")
	self.map.draw(self)
