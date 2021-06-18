extends Control

# controls
var _dir := Vector2.ZERO setget , get_move_dir
var _jump := false setget , is_jumping

# temp value
var axis_value := 0.0
var str_value := ""

var _pos_to := 0

onready var axes = $Axes
onready var axes_mapped = $AxesMapped
onready var joypad_axes = $JoypadDiagram/Axes
onready var joypad_axes_mapped = $JoypadDiagramMapped/Axes

var POS_HIDDEN = -260


func _ready() -> void:
	rect_position.y = POS_HIDDEN
	_pos_to = rect_position.y

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_K:
			_pos_to = 0 if _pos_to != 0 else POS_HIDDEN

func _physics_process(_delta: float) -> void:

	if rect_position.y != _pos_to:
		rect_position.y += ceil((_pos_to - rect_position.y) * 0.1)

	_dir = Vector2.ZERO
	
	# Loop through the axes and show their current values
	for axis in range(4):
		var node = axes.get_node("Axis" + str(axis) + "/ProgressBar")
		if node:
			# input axis
			axis_value = Input.get_joy_axis(0, axis)
			node.set_value(100 * axis_value)
			node.get_node("Value").set_text(str(axis_value))

			# Show joypad direction indicators
			if axis <= JOY_ANALOG_RY:
				#joypad_axes_mappedindicatorPos.visible = (abs(axis_value) > JOYPAD_DEADZONE && axis_value > 0)
				#indicatorNeg.visible = (abs(axis_value) > JOYPAD_DEADZONE && axis_value < 0)
				joypad_axes.get_node(str(axis) + "+").visible = axis_value > 0
				joypad_axes.get_node(str(axis) + "-").visible = axis_value < 0

			# mapped
			node = axes_mapped.get_node("Axis" + str(axis) + "/ProgressBar")
			var axis_sign = sign(axis_value)
			axis_value = (abs(axis_value) - Constants.JOYPAD_DEADZONE) / (1 - 2*Constants.JOYPAD_DEADZONE)
			axis_value = axis_sign * clamp(axis_value, 0, 1)

			if axis == 0:
				_dir.x += axis_value
			elif axis == 1:
				_dir.x -= axis_value
			elif axis == 2:
				_dir.y += axis_value
			elif axis == 3:
				_dir.y -= axis_value

			node.set_value(100 * axis_value)
			node.get_node("Value").set_text(str(axis_value))

			if axis <= JOY_ANALOG_RY:
				joypad_axes_mapped.get_node(str(axis) + "+").visible = axis_value > 0
				joypad_axes_mapped.get_node(str(axis) + "-").visible = axis_value < 0

	# get additional button values
	_jump = Input.is_action_just_pressed("jump")


func get_move_dir() -> Vector2:
	#var dir := Vector2(
	#	Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
	#	0.0
	#)
	return _dir

func is_jumping() -> bool:
	return _jump