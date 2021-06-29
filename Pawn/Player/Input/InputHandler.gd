extends Control

# controls
var _dir := Vector2.ZERO setget , get_move_dir
var _jump := false setget , is_jumping

# temp value
var axis_value := 0.0
var str_value := ""

# ui animation
var _pos_to := 0

onready var axes = $Axes
onready var axes_mapped = $AxesMapped
onready var joypad_axes = $JoypadDiagram/Axes
onready var joypad_axes_mapped = $JoypadDiagramMapped/Axes

const POS_HIDDEN = -260
const JOYPAD_DEADZONE := 0.2 # symetric inner and outer


func _ready() -> void:
	rect_position.y = POS_HIDDEN
	_pos_to = POS_HIDDEN

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_K:
			_pos_to = 0 if _pos_to != 0 else POS_HIDDEN

func _physics_process(_delta: float) -> void:

	# scroll ui
	if rect_position.y != _pos_to:
		rect_position.y += ceil((_pos_to - rect_position.y) * 0.1)

	# TODO: theoretically the full axis input vector should be mapped instead of each direction

	# Loop through the axes and show their current values
	for axis in range(4):
		var node = axes.get_node("Axis" + str(axis) + "/ProgressBar")
		if node:
			# input axis: 0... LS X, 1... LS Y, 2... RS X, 3... RS Y
			axis_value = Input.get_joy_axis(0, axis)
			node.set_value(100 * axis_value)
			node.get_node("Value").set_text(str(axis_value))

			# Show joypad direction indicators
			joypad_axes.get_node(str(axis) + "+").visible = axis_value > 0
			joypad_axes.get_node(str(axis) + "-").visible = axis_value < 0

			# mapped
			node = axes_mapped.get_node("Axis" + str(axis) + "/ProgressBar")
			var axis_sign = sign(axis_value)
			#axis_value = (abs(axis_value) - JOYPAD_INNER_DEADZONE) / (1 - JOYPAD_INNER_DEADZONE - JOYPAD_OUTER_DEADZONE)
			axis_value = (abs(axis_value) - JOYPAD_DEADZONE) / (1 - 2*JOYPAD_DEADZONE)
			axis_value = axis_sign * clamp(axis_value, 0, 1)
			node.set_value(100 * axis_value)
			node.get_node("Value").set_text(str(axis_value))

			joypad_axes_mapped.get_node(str(axis) + "+").visible = axis_value > 0
			joypad_axes_mapped.get_node(str(axis) + "-").visible = axis_value < 0

			# apply to move direction
			if axis == 0:
				_dir.x = axis_value
			elif axis == 1:
				_dir.y = axis_value

	# get additional button values
	_jump = Input.is_action_pressed("jump")
	
	# override for key controls
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")


# only gets movement in x direction
func get_move_dir() -> Vector2:
	return Vector2(_dir.x, 0)

func get_dir() -> Vector2:
	return _dir

func is_jumping() -> bool:
	return _jump
