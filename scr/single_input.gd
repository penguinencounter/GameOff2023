@tool
extends Node2D
class_name SingleInput

signal update_tint(color: Color)

# ===== UTILITY =====
var _readied := false
var _defer: Array[Callable] = []
func defer_setter_until_ready(base: Callable) -> Callable:
	var wrapper := func(set_val):
		if not _readied:
			_defer.append(FuncUtil.apply1(base, set_val))
			return
		base.call(set_val)
	return wrapper
# ===== END UTILITY =====


# begin width property

var _width: int = 0
func __set_width(new_width: int) -> void:
	if left_endcap == null or right_endcap == null or stretch == null:
		# too early
		return
	if new_width < cap_width_total:
		push_warning("attempt to set width of InputItem too small")
		new_width = cap_width_total
	var inbetween: int = new_width - cap_width_total

	stretch.region_rect.size.x = inbetween
	stretch.region_rect.size.y = stretch_height
	stretch.region_rect.position = Vector2.ZERO
	
	stretch.position.x = -((inbetween / 2.0) + right_cap_width)
	
	left_endcap.position.x = -(right_cap_width + inbetween + (left_cap_width / 2.0))

	var collider_offs = right_cap_width + inbetween + left_cap_width
	var poly = collider.polygon
	for k in collider_irp.keys():
		var v: Vector2 = collider_irp[k]
		var new_v := Vector2(v.x - collider_offs, v.y)
		poly[k] = new_v
	collider.polygon = poly
	
	_width = new_width

var _set_width := defer_setter_until_ready(__set_width)

# just a front for _width so that _set_width() doesn't do recursion
## Total width of the item.
##
## Setting this value automatically updates the positions and scales of the associated sprites.
@export var width: int :
	set(value):
		_set_width.call(value)
	get:
		return _width

# end width property
# begin color property
var _color: Color = Color(1.0, 1.0, 1.0)
func __set_color(new_color: Color) -> void:
	update_tint.emit(new_color)
	_color = new_color
var _set_color := defer_setter_until_ready(__set_color)
@export var color: Color = Color.WHITE :
	set(value):
		_set_color.call(value)
	get:
		return _color
# end color property
	
## Sprite that is always placed at the start of the item.
@export var left_endcap: Sprite2D
## Sprite that is always placed at the end of the item.
@export var right_endcap: Sprite2D
## Sprite that is streched / repeated to fill space.
@export var stretch: Sprite2D

## CollisionPolygon2D representing the entire object, not just the connection points.
@export var collider: CollisionPolygon2D

# consider PackedInt64Array
## Indexes of polypoints that need to shift with the size of the object.
## 
## Looks up indexes in the collider (also provided). These indexes are shifted proportionally to the
## width parameter and can move at runtime.
@export var collider_items: Array[int]

## index => relative position. dict[int, Vector2]
var collider_irp := {}

var cap_width_total: int = 0
var right_cap_width: int = 0
var left_cap_width: int = 0
var stretch_height: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	left_cap_width = left_endcap.texture.get_width()
	right_cap_width = right_endcap.texture.get_width()
	cap_width_total = left_cap_width + right_cap_width
	
	stretch_height = stretch.texture.get_height()

	var points := collider.polygon
	var matching_points := {}
	for i in collider_items:
		matching_points[i] = points[i]
	# compute the offset
	var x_coords: Array = (
			Array(matching_points.values() as Array[Vector2])
			.map(func(val: Vector2) -> float: return val.x)
	)
	var min_x: float = x_coords.min()
	for k in matching_points.keys():
		var v: Vector2 = matching_points[k]
		collider_irp[k] = Vector2(v.x - min_x, v.y)

	_readied = true
	for d in _defer:
		d.call()

var h := 0.0
const s := 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
