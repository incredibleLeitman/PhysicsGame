extends Control

var axis_value
var str_value

onready var axes = $Axes
onready var axes_mapped = $AxesMapped
onready var joypad_axes = $JoypadDiagram/Axes
onready var joypad_axes_mapped = $JoypadDiagramMapped/Axes

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_K:
			self.visible = !self.visible

func _physics_process(_delta: float) -> void:
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

			node.set_value(100 * axis_value)
			node.get_node("Value").set_text(str(axis_value))

			if axis <= JOY_ANALOG_RY:
				joypad_axes_mapped.get_node(str(axis) + "+").visible = axis_value > 0
				joypad_axes_mapped.get_node(str(axis) + "-").visible = axis_value < 0

func getAxis():
	pass

func getJump():
	pass
