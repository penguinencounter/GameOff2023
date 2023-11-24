extends Area2D
class_name OutputConnector

var n_connections: int = 0
var connections: Array[InputConnector] = []
var in_progress: bool = false

func _recompute_connected() -> bool:
	var value := n_connections > 0 or in_progress
	($WhenConnected as Sprite2D).visible = value
	return value


# Called when the node enters the scene tree for the first time.
func _ready():
	_recompute_connected()


# USE ONESHOT CONNECTIONS ONLY
func _fail_connect():
	in_progress = false
	_recompute_connected()


var input_hovered := false


func _mouse_enter():
	input_hovered = true


func _mouse_exit():
	input_hovered = false


func _click():
	if in_progress:
		return
	in_progress = true
	_recompute_connected()
	Bus.begin_connection.emit(self)
	if not Bus.fail_connection.is_connected(_fail_connect):
		Bus.fail_connection.connect(_fail_connect, CONNECT_ONE_SHOT)


func _unhandled_input(event: InputEvent):
	if input_hovered and event is InputEventMouseButton:
		var tev := event as InputEventMouseButton
		if tev.button_index == MOUSE_BUTTON_LEFT and tev.pressed:
			_click()
			get_viewport().set_input_as_handled()


func _connection_callback(_self: OutputConnector, connector: InputConnector):
	if in_progress:
		if connections.has(connector):
			push_warning("attempt to connect to the same connector twice")
			return
		if _self != self:
			push_warning("the connection callback for " + _self.to_string() + " ended up being called for " + self.to_string() + " instead")
			return
		connections.append(connector)
		n_connections += 1
		print_debug("connecting " + _self.to_string() + " to " + connector.to_string() + ". " + str(n_connections) + " connections " + str(connections))
		in_progress = false
	else:
		push_warning("more than one connection callback received")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if in_progress and not Input.is_action_pressed("begin_connection"):
		# prepare to complete the connection with whoever is listening
		if not Bus.successful_connection.is_connected(_connection_callback):
			Bus.successful_connection.connect(_connection_callback)
		
		Bus.request_finish_connection.emit(self)

		if Bus.successful_connection.is_connected(_connection_callback):
			Bus.successful_connection.disconnect(_connection_callback)
		if in_progress:
			# no callbacks? (megamind voice)
			in_progress = false
			Bus.fail_connection.emit()
		_recompute_connected()


func disconnect_from(connector: InputConnector) -> bool:
	var index := connections.find(connector)
	if index < 0:
		return false
	Bus.destroyed_connection.emit(self, connector)
	connections.remove_at(index)
	n_connections -= 1
	_recompute_connected()
	return true


func _exit_tree():
	for connector in connections:
		connector.disconnect_from(self)
	connections.clear()
	n_connections = 0
	_recompute_connected()
