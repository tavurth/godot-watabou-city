@tool
extends Node2D

@export var map: Resource

func _ready():
	print("HERE")
	self.map = WatabouCity.load("res://demo/trunwick.json")
	self.map.draw(self)
