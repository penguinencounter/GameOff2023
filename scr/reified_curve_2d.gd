@tool
extends Node2D
class_name ReifiedCurve2D


@export var curve: Curve2D :
	set(new_value):
		curve = new_value
		queue_redraw()
		if curve != null:
			curve.changed.connect(refresh)

@export var color: Color = Color.WHITE :
	set(new_value):
		color = new_value
		queue_redraw()
@export var line_thickness: float = 5.0 :
	set(new_value):
		line_thickness = new_value
		queue_redraw()

@export var round := false :
	set(new_value):
		round = new_value
		queue_redraw()


func refresh():
	queue_redraw()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _draw():
	if curve == null:
		return
	var baked := curve.get_baked_points()
	if baked.size() == 0:
		return
	if baked.size() == 1:
		if round:
			var point := baked[0]
			draw_circle(point, line_thickness / 2.0, color)
		return
	draw_polyline(baked, color, line_thickness)
	if round:
		var start := baked[0]
		var end := baked[-1]
		draw_circle(start, line_thickness / 2.0, color)
		draw_circle(end, line_thickness / 2.0, color)
