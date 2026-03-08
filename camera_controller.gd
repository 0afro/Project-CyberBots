extends Node3D

@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var spring_arm = $CamYaw/CamPitch/SpringArm3D

var yaw : float = 0
var pitch : float = 0

# settings
var sensitivity : float = 0.35
var smoothness : float = 14

var pitch_max : float = 75
var pitch_min : float = -55

func _input(event):

	# rotate camera ONLY while RMB held
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event is InputEventMouseMotion:
			yaw -= event.relative.x * sensitivity
			pitch -= event.relative.y * sensitivity

	# zoom with scroll
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length -= 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length += 1

		spring_arm.spring_length = clamp(spring_arm.spring_length, 6, 30)

func _process(delta):

	pitch = clamp(pitch, pitch_min, pitch_max)

	yaw_node.rotation_degrees.y = lerp(
		yaw_node.rotation_degrees.y,
		yaw,
		smoothness * delta
	)

	pitch_node.rotation_degrees.x = lerp(
		pitch_node.rotation_degrees.x,
		pitch,
		smoothness * delta
	)
