extends CharacterBody3D
@export var walk_speed := 25.0
@export var sprint_speed := 35.0
@export var acceleration := 30.0
@export var jump_velocity := 25.0
@export var gravity := 40.0
@export var interact_hold_time := 0.5  # How long to hold E (in seconds)
@onready var blaster = $protoform_rigged/Armature/Skeleton3D/BoneAttachment3D/Blaster

@onready var cam_root = $Camroot/CamYaw/CamPitch/SpringArm3D/Camera3D   # camera pivot
@onready var pickup_area = $Area3D  # Detection area for pickups
@onready var stats = $PlayerStats  # Player health/shield system

# Track how long E has been held
var interact_timer := 0.0
var is_holding_interact := false

func _ready():
	# Add player to "player" group so pickups can find it
	add_to_group("player")
	
	# Connect to death signal
	if stats:
		stats.died.connect(_on_player_died)

func _physics_process(delta):
	# --- TEMPORARY TEST - Press K to damage yourself  ---
	if Input.is_action_just_pressed("test_damage"):  # K key
		stats.take_damage(10)
	
		# --- Shooting ---
	if Input.is_action_pressed("shoot") and blaster:
		blaster.shoot(cam_root, self)

	# --- Gravity ---
	# Apply gravity when not on the floor (makes the character fall)
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# --- Jump ---
	# Only allow jumping when on the floor to prevent double jumps
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# --- Movement input ---
	# Get input from WASD/arrow keys as a 2D vector
	# x = left/right, y = forward/back (ranges from -1 to 1)
	var input_dir = Input.get_vector("move_left","move_right","move_forward","move_back")
	
	# Get the camera's forward direction in world space
	# basis.z points "backward" from the camera, so we use it directly
	# This way when input_dir.y is positive (W pressed), we move in the camera's forward direction
	var cam_forward = cam_root.global_transform.basis.z
	
	# Get the camera's right direction in world space
	# basis.x points to the right of the camera
	var cam_right = cam_root.global_transform.basis.x
	
	# Combine forward/back input with camera forward direction
	# and left/right input with camera right direction
	# This creates movement relative to where the camera is looking
	# normalized() ensures diagonal movement isn't faster than cardinal movement
	var direction = (cam_forward * input_dir.y + cam_right * input_dir.x).normalized()
	
	# --- Interaction with Hold ---
	# Check if player is holding the interact button
	if Input.is_action_pressed("interact"):
		# Increment the timer while holding
		interact_timer += delta
		is_holding_interact = true
		
		# Once held long enough, try to pick up
		if interact_timer >= interact_hold_time:
			# Get all objects currently overlapping with the pickup area
			var overlapping_bodies = pickup_area.get_overlapping_bodies()
			# Check each overlapping object
			for body in overlapping_bodies:
				# If the object has an interact() method, call it
				if body.has_method("interact"):
					body.interact()
					break  # Only pick up one item at a time
			
			# Reset timer after successful pickup
			interact_timer = 0.0
			is_holding_interact = false
	else:
		# Reset timer if player releases the button early
		interact_timer = 0.0
		is_holding_interact = false
	
	# --- Sprint ---
	# Switch between walk and sprint speed based on sprint input
	var speed = walk_speed
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	
# Apply speed boost from power-up (NEW)
	if stats:
		speed = stats.get_speed_output(speed)

	# Calculate the target velocity based on direction and speed
	var target_velocity = direction * speed
	
	# --- Instant stop when no input ---
	# If there's no input (player released all movement keys), stop immediately
	# This prevents sliding and gives more responsive, arcade-like controls
	if direction.length() == 0:
		velocity.x = 0
		velocity.z = 0
	else:
		# Only use smooth acceleration when actually moving
		# move_toward prevents instant direction changes and creates smooth acceleration
		# Only affects horizontal movement (x and z), gravity handles y separately
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	
	# --- Floor Snap ---
	# Keeps player glued to floor, prevents catching on seams
	if is_on_floor() and velocity.y <= 0:
		velocity.y = -5.0  # Small downward pull to "stick" to ground
	
	# Apply the velocity and handle collisions with the environment
	move_and_slide()

func _on_player_died():
	print("Death callback triggered")
