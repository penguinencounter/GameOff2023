class_name Cable
extends ReifiedCurve2D

func get_PCN(connector: Node2D) -> PositionChangeNotifier:
    return (connector.get_node("PCN") as PositionChangeNotifier)


var left_sub: OutputConnector = null
var right_sub: InputConnector = null


func _refresh_beginning(_source: PositionChangeNotifier, new_pos: Vector2):
    curve.set_point_position(0, to_local(new_pos))

func _refresh_end(_source: PositionChangeNotifier, new_pos: Vector2):
    curve.set_point_position(1, to_local(new_pos))


func subscribe(outp: OutputConnector, inp: InputConnector):
    subscribe_left(outp)
    subscribe_right(inp)


func subscribe_left(outp: OutputConnector):
    if left_sub != null:
        var sig := get_PCN(left_sub).position_changed
        if sig.is_connected(_refresh_beginning):
            sig.disconnect(_refresh_beginning)
    get_PCN(outp).position_changed.connect(_refresh_beginning)
    left_sub = outp


func subscribe_right(inp: InputConnector):
    if right_sub != null:
        var sig := get_PCN(right_sub).position_changed
        if sig.is_connected(_refresh_end):
            sig.disconnect(_refresh_end)
    get_PCN(inp).position_changed.connect(_refresh_end)
