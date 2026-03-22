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
	# Handle both touch and mouse input for testing
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.pressed):
		var touch_pos = Vector2.ZERO
		var pressed = false
		var index = 0
		
		if event is InputEventScreenTouch:
			var touch_event = event as InputEventScreenTouch
			touch_pos = touch_event.position
			pressed = touch_event.pressed
			index = touch_event.index
		elif event is InputEventMouseButton:
			var mouse_event = event as InputEventMouseButton
			touch_pos = mouse_event.position
			pressed = mouse_event.pressed
			index = 0

		if pressed:
			# Check if touch/mouse is within joystick area
			print("[VirtualJoystick] Touch/mouse pressed at global: ", touch_pos)
			
			# For Control nodes, use get_global_rect() to check if point is inside
			if get_global_rect().has_point(touch_pos):
				is_pressed = true
				touch_index = index
				_update_joystick_position(touch_pos)
				get_tree().root.set_input_as_handled()
				print("[VirtualJoystick] Input accepted")
			else:
				print("[VirtualJoystick] Input outside joystick area")
		else:
			if (event is InputEventMouseButton) or (event is InputEventScreenTouch and event.index == touch_index):
				is_pressed = false
				touch_index = -1
				input_vector = Vector2.ZERO
				knob_position = base_center
				input_changed.emit(input_vector)
				queue_redraw()
				get_tree().root.set_input_as_handled()

	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if is_pressed:
			var drag_pos = Vector2.ZERO
			
			if event is InputEventScreenDrag:
				var drag_event = event as InputEventScreenDrag
				if drag_event.index == touch_index:
					drag_pos = drag_event.position
					_update_joystick_position(drag_pos)
					get_tree().root.set_input_as_handled()
			elif event is InputEventMouseMotion:
				drag_pos = event.position
				_update_joystick_position(drag_pos)
				get_tree().root.set_input_as_handled()

## Update joystick based on touch position
func _update_joystick_position(touch_pos: Vector2) -> void:
	# For Control nodes, convert global touch position to local coordinates
	var local_pos = position + (touch_pos - global_position)
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

	print("[VirtualJoystick] Updated joystick - local_pos: ", local_pos, " delta: ", delta, " input_vector: ", input_vector)
	input_changed.emit(input_vector)
	queue_redraw()

func _draw() -> void:
	# Draw base
	draw_circle(size / 2, base_radius, base_color)

	# Draw knob
	draw_circle(knob_position, knob_radius, knob_color)
