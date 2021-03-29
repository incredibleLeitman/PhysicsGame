extends Control

const JOYPAD_DEADZONE = 0.2

var axis_value
var str_value

onready var axes = $Axes
onready var axes_mapped = $AxesMapped
onready var joypad_axes = $JoypadDiagram/Axes
onready var joypad_axes_mapped = $JoypadDiagramMapped/Axes

func _ready():
	# testing
	var val = -0.2
	var sign_val = sign(-1)

	val = max(0, val) # 0 -> results in -0
	#val = 0 # -> results in 0
	print("-> " + str(val) + " * " + str(sign_val) + " = " + str(val * sign_val))
	
	#set_physics_process(true)
	#Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	#InputMap.action_set_deadzone("ui_up", 0.25)


func _process(_delta):
	# Loop through the axes and show their current values.
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
			axis_value = (abs(axis_value) - JOYPAD_DEADZONE) / (1 - 2*JOYPAD_DEADZONE)
			axis_value = axis_sign * max(0, min(1, axis_value))
			#print("axis_val (with sign): " + str(axis_value))

			node.set_value(100 * axis_value)
			node.get_node("Value").set_text(str(axis_value))
			
			if axis <= JOY_ANALOG_RY:
				joypad_axes_mapped.get_node(str(axis) + "+").visible = axis_value > 0
				joypad_axes_mapped.get_node(str(axis) + "-").visible = axis_value < 0

			# Test with vector:
			if (axis == 0):
				var vec = Vector2(axis_value, 0)
				vec = vec.normalized() * ((vec.length() - JOYPAD_DEADZONE) / (1 - 2*JOYPAD_DEADZONE))
				if (str_value != str(vec)):
					str_value = str(vec)
					print("vec: " + str_value)
