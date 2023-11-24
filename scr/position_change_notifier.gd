class_name PositionChangeNotifier
extends Node2D

signal position_changed(source: PositionChangeNotifier, global_position: Vector2)

var last_position: Vector2

func _ready():
	last_position = global_position

func _process(_delta):
	if global_position != last_position:
		last_position = global_position
		position_changed.emit(self, global_position)

