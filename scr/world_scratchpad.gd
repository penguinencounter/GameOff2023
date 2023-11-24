extends Node2D


var in_progress_base: OutputConnector = null
var in_progress: Cable = null
const outgoing_control := Vector2(300, 0)
const incoming_control := Vector2(-300, 0)

## Connections are... interesting.
##
## Index with connections[from][to] -> Cable (if it exists)
var connections := {}


func destroy_in_progress():
	# remove the child NOW to prevent race condition weirdness
	remove_child(in_progress)
	# do the actual deletion NEXT FRAME to prevent reference errors...
	in_progress.queue_free()
	in_progress = null


func destroy(connection: Cable):
	remove_child(connection)
	connection.queue_free()


func get_PCN(connector: Node2D) -> PositionChangeNotifier:
	return (connector.get_node("PCN") as PositionChangeNotifier)


func _on_fail_connection():
	destroy_in_progress()

func _on_begin_connection(source: OutputConnector):
	in_progress = Cable.new()
	in_progress.curve = Curve2D.new()
	add_child(in_progress)
	in_progress_base = source
	in_progress.curve.add_point(source.global_position, Vector2.ZERO, outgoing_control)
	in_progress.curve.add_point(source.global_position, incoming_control, Vector2.ZERO)
	in_progress.subscribe_left(source)

func _on_successful_connection(from: OutputConnector, to: InputConnector):
	destroy_in_progress()
	var result := Cable.new()
	result.curve = Curve2D.new()
	var from_p := to_local(from.global_position)
	var to_p := to_local(to.global_position)
	result.curve.add_point(from_p, Vector2.ZERO, outgoing_control)
	result.curve.add_point(to_p, incoming_control, Vector2.ZERO)

	if not connections.has(from):
		connections[from] = {}
	var from_set := connections[from] as Dictionary
	if from_set.has(to):  # this connection already exists???
		destroy(from_set[to] as Cable)
		from_set.erase(to)
	from_set[to] = result
	
	result.subscribe(from, to)

	add_child(result)

func _on_destroyed_connection(from: OutputConnector, to: InputConnector):
	if connections.has(from):
		var from_set := connections[from] as Dictionary
		if from_set.has(to):
			destroy(from_set[to] as Cable)
			from_set.erase(to)



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
