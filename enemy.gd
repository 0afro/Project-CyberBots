extends CharacterBody3D

# Enemy stats
@export var max_health := 50.0
@export var move_speed := 15.0
@export var stop_distance := 50
@export var gravity := 40.0

var current_health := 50.0
var player: Node3D = null

@onready var health_label = $HealthLabel if has_node("HealthLabel") else null
@onready var mesh = $EnemyModel

func _ready():
	current_health = max_health
	
	# Make material unique for this enemy instance
	if mesh:
		var material = mesh.get_active_material(0)
		if material:
			mesh.set_surface_override_material(0, material.duplicate())
	
	update_health_display()
	print("Enemy spawned with ", max_health, " HP")
	
	# Find player
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# AI behavior - chase player
	if player:
		ai_chase_player(delta)
	
	# Move
	move_and_slide()

func ai_chase_player(delta):
	# Get direction to player
	var direction_to_player = (player.global_position - global_position)
	var distance_to_player = direction_to_player.length()
	
	# Only move if not too close
	if distance_to_player > stop_distance:
		# Normalize direction
		direction_to_player = direction_to_player.normalized()
		
		# Remove Y component (only move on ground)
		direction_to_player.y = 0
		direction_to_player = direction_to_player.normalized()
		
		# Move toward player
		velocity.x = direction_to_player.x * move_speed
		velocity.z = direction_to_player.z * move_speed
		
		# Face player
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	else:
		# Stop moving when close
		velocity.x = 0
		velocity.z = 0

func take_damage(amount: float):
	current_health -= amount
	print("Enemy took ", amount, " damage. HP: ", current_health, "/", max_health)
	
	# Flash white when hit
	flash_damage()
	
	# Update health display
	update_health_display()
	
	# Check if dead
	if current_health <= 0:
		die()

func flash_damage():
	if mesh:
		var material = mesh.get_surface_override_material(0)
		if material:
			# Store original colors
			var original_albedo = material.albedo_color
			var original_emission = material.emission if material.emission_enabled else Color.BLACK
			var original_emission_energy = material.emission_energy_multiplier if material.emission_enabled else 0.0
			
			# Flash to white
			material.albedo_color = Color.WHITE
			if material.emission_enabled:
				material.emission = Color.WHITE
				material.emission_energy_multiplier = 3.0  # Bright flash
			
			await get_tree().create_timer(0.1).timeout
			
			# Reset
			if material:
				material.albedo_color = original_albedo
				if material.emission_enabled:
					material.emission = original_emission
					material.emission_energy_multiplier = original_emission_energy

func update_health_display():
	if health_label:
		health_label.text = str(int(current_health)) + " HP"
		
		if current_health <= 0:
			health_label.modulate = Color.DARK_GRAY
		elif current_health < max_health * 0.3:
			health_label.modulate = Color.ORANGE
		else:
			health_label.modulate = Color.WHITE

func die():
	print("Enemy destroyed!")
	queue_free()
