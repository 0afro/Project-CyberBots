extends CharacterBody3D

@export var walk_speed := 35
@export var sprint_speed := 50
@export var acceleration := 30.0
@export var jump_velocity := 25.0
@export var gravity := 40.0
@export var interact_hold_time := 0.5

@onready var blaster = $protoform_rigged/Armature/Skeleton3D/BoneAttachment3D/Blaster
@onready var cam_root = $Camroot/CamYaw/CamPitch/SpringArm3D/Camera3D
@onready var pickup_area = $Area3D
@onready var stats = $PlayerStats

var interact_timer := 0.0
var is_holding_interact := false

func _ready():
	add_to_group("player")
	
	if stats:
		stats.died.connect(_on_player_died)

func _physics_process(delta):
	# --- TEMPORARY TEST ---
	if Input.is_action_just_pressed("test_damage"):
		stats.take_damage(10)
	
	# --- Shooting ---
	if Input.is_action_pressed("shoot") and blaster and cam_root:
		blaster.shoot(cam_root, self)

	# --- Gravity ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# --- Jump ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# --- Movement input (CAMERA-RELATIVE - original version) ---
	var input_dir = Input.get_vector("move_left","move_right","move_forward","move_back")
	
	var cam_forward = cam_root.global_transform.basis.z
	var cam_right = cam_root.global_transform.basis.x
	
	var direction = (cam_forward * input_dir.y + cam_right * input_dir.x).normalized()
	
	# --- Interaction ---
	if Input.is_action_pressed("interact"):
		interact_timer += delta
		is_holding_interact = true
		
		if interact_timer >= interact_hold_time:
			var overlapping_bodies = pickup_area.get_overlapping_bodies()
			for body in overlapping_bodies:
				if body.has_method("interact"):
					body.interact()
					break
			
			interact_timer = 0.0
			is_holding_interact = false
	else:
		interact_timer = 0.0
		is_holding_interact = false
	
	# --- Sprint ---
	var speed = walk_speed
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	
	# Apply speed boost from power-up
	if stats:
		speed = stats.get_speed_output(speed)

	var target_velocity = direction * speed
	
	# --- Instant stop when no input ---
	if direction.length() == 0:
		velocity.x = 0
		velocity.z = 0
	else:
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	
	# --- Floor Snap ---
	if is_on_floor() and velocity.y <= 0:
		velocity.y = -5.0
	
	move_and_slide()

func _on_player_died():
	print("Death callback triggered")
