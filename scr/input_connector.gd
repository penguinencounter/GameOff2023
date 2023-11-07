extends Area2D
class_name InputConnector

@export var connecting_opacity := 1.0
@export var default_opacity := 0.5

var connected: bool = false
var connected_to: OutputConnector = null
var input_hovered := false

func _mouse_enter():
	input_hovered = true

func _mouse_exit():
	input_hovered = false

func _recompute_connected() -> bool:
	($WhenConnected as Sprite2D).visible = connected
	return connected

func _try_connect(source: OutputConnector):
	if input_hovered:
		if connected:
			connected_to.disconnect_from(self)
		connected = true
		_recompute_connected()
		connected_to = source
		Bus.successful_connection.emit(source, self)

# Called when the node enters the scene tree for the first time.
func _ready():
	_recompute_connected()
	Bus.request_finish_connection.connect(_try_connect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_input_event(viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		print_debug(event)
		viewport.set_input_as_handled()


func disconnect_from(source: OutputConnector):
	if connected_to == source:
		connected = false
		_recompute_connected()
		connected_to = null
		Bus.destroyed_connection.emit(source, self)
	else:
		print_debug("Tried to disconnect from a source that wasn't connected to this input")


func _exit_tree():
	if connected:
		connected_to.disconnect_from(self)
		connected = false
		_recompute_connected()
		connected_to = null
