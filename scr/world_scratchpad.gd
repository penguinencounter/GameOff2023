extends Node2D


var in_progress_base := Vector2.ZERO
var in_progress: ReifiedCurve2D = null
const outgoing_control := Vector2(300, 0)
const incoming_control := Vector2(-300, 0)

## Connections are... interesting.
##
## Index with connections[from][to] -> ReifiedCurve2D (if it exists)
var connections := {}


func destroy_in_progress():
	# remove the child NOW to prevent race condition weirdness
	remove_child(in_progress)
	# do the actual deletion NEXT FRAME to prevent reference errors...
	in_progress.queue_free()
	in_progress = null


func destroy(connection: ReifiedCurve2D):
	remove_child(connection)
	connection.queue_free()


func _on_fail_connection():
	destroy_in_progress()

func _on_begin_connection(source: OutputConnector):
	in_progress = ReifiedCurve2D.new()
	in_progress.curve = Curve2D.new()
	add_child(in_progress)
	in_progress_base = to_local(source.global_position)
	in_progress.curve.add_point(in_progress_base, Vector2.ZERO, outgoing_control)
	in_progress.curve.add_point(in_progress_base, incoming_control, Vector2.ZERO)

func _on_successful_connection(from: OutputConnector, to: InputConnector):
	destroy_in_progress()
	var result := ReifiedCurve2D.new()
	result.curve = Curve2D.new()
	var from_p := to_local(from.global_position)
	var to_p := to_local(to.global_position)
	result.curve.add_point(from_p, Vector2.ZERO, outgoing_control)
	result.curve.add_point(to_p, incoming_control, Vector2.ZERO)

	if not connections.has(from):
		connections[from] = {}
	var from_set := connections[from] as Dictionary
	if from_set.has(to):  # this connection already exists???
		destroy(connections[from][to] as ReifiedCurve2D)
		connections[from].erase(to)
	connections[from][to] = result
	add_child(result)

func _on_destroyed_connection(from: OutputConnector, to: InputConnector):
	if not connections.has(from):
		return
	var from_set := connections[from] as Dictionary
	if not from_set.has(to):
		return
	destroy(connections[from][to] as ReifiedCurve2D)
	connections[from].erase(to)


# Called when the node enters the scene tree for the first time.
func _ready():
	Bus.fail_connection.connect(_on_fail_connection)
	Bus.begin_connection.connect(_on_begin_connection)
	Bus.successful_connection.connect(_on_successful_connection)
	Bus.destroyed_connection.connect(_on_destroyed_connection)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if in_progress != null:
		in_progress.curve.set_point_position(1, get_local_mouse_position())
