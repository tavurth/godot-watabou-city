@tool
extends Node2D

@export var map: WatabouMap = WatabouMap.new()

func _ready():
	self.map.load("res://demo/trunwick.json")
	self.map.draw(self)
