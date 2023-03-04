@tool
extends Node2D

@export var map: WatabouMap = WatabouMap.new()

func _ready():
	self.map.draw(self)
