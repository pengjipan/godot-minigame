extends Control
## Virtual joystick for mobile touch input
class_name VirtualJoystick

signal input_changed(input_vector: Vector2)

@export var base_radius: float = 50.0
@export var knob_radius: float = 30.0
@export var input_deadzone: float = 0.15
@export var base_color: Color = Color(1, 1, 1, 0.3)
@export var knob_color: Color = Color(1, 1, 1, 0.8)

var is_pressed: bool = false
var touch_index: int = -1
var input_vector: Vector2 = Vector2.ZERO
var base_center: Vector2 = Vector2.ZERO
var knob_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	base_center = global_position + size / 2
	knob_position = base_center

## Get current input vector
func get_input_vector() -> Vector2:
	return input_vector

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event = event as InputEventScreenTouch
		var touch_pos = touch_event.position

		if touch_event.pressed:
			# Check if touch is within joystick area
			if get_rect().has_point(get_local_mouse_position()):
				is_pressed = true
				touch_index = touch_event.index
				_update_joystick_position(touch_pos)
				get_tree().root.set_input_as_handled()
		else:
			if touch_event.index == touch_index:
				is_pressed = false
				touch_index = -1
				input_vector = Vector2.ZERO
				knob_position = base_center
				input_changed.emit(input_vector)
				queue_redraw()
				get_tree().root.set_input_as_handled()

	elif event is InputEventScreenDrag:
		var drag_event = event as InputEventScreenDrag
		if is_pressed and drag_event.index == touch_index:
			_update_joystick_position(drag_event.position)
			get_tree().root.set_input_as_handled()

## Update joystick based on touch position
func _update_joystick_position(touch_pos: Vector2) -> void:
	var local_pos = get_local_mouse_position()
	var delta = local_pos - (size / 2)

	# Limit to radius
	var distance = delta.length()
	if distance > base_radius:
		delta = delta.normalized() * base_radius

	knob_position = (size / 2) + delta

	# Calculate normalized input vector
	var raw_input = delta / base_radius
	if raw_input.length() < input_deadzone:
		input_vector = Vector2.ZERO
	else:
		input_vector = raw_input.normalized()

	input_changed.emit(input_vector)
	queue_redraw()

func _draw() -> void:
	# Draw base
	draw_circle(size / 2, base_radius, base_color)

	# Draw knob
	draw_circle(knob_position, knob_radius, knob_color)
