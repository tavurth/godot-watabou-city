@tool
extends Node2D

@export var map: Resource = preload("res://addons/godot-watabou-city/Map.tres")

func _ready():
	self.map.load("res://demo/trunwick.json")
	self.map.draw(self)
