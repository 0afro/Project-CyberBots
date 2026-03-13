extends CharacterBody3D

# Enemy stats
@export var max_health := 50.0
@export var move_speed := 15.0
@export var stop_distance := 50.0
@export var gravity := 40.0

# Shooting stats
@export var damage := 3.0  # Reduced damage
@export var shoot_range := 55.0
@export var fire_rate := 2.0  # Slower fire rate

var current_health := 50.0
var player: Node3D = null
var can_shoot := false  # Changed to false - will be enabled after random delay

@onready var health_label = $HealthLabel if has_node("HealthLabel") else null
@onready var mesh = $EnemyModel
@onready var laser = $EnemyLaser if has_node("EnemyLaser") else null
@onready var muzzle_point = $MuzzlePoint if has_node("MuzzlePoint") else null

func _ready():
	current_health = max_health
	
	# Make material unique for this enemy instance
	if mesh:
		var material = mesh.get_active_material(0)
		if material:
			mesh.set_surface_override_material(0, material.duplicate())
	
	update_health_display()
	print("Enemy spawned with ", max_health, " HP")
	
	# Wait for player to load
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("ERROR: Enemy could not find player!")
	
	# Random initial delay so enemies don't shoot in sync
	var initial_delay = randf_range(0.0, fire_rate)
	await get_tree().create_timer(initial_delay).timeout
	can_shoot = true  # Now ready to shoot at different times

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# AI behavior - chase and shoot player
	if player:
		ai_chase_player(delta)
		ai_shoot_player()
	
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
		
		# Remove Y component (only move on ground plane)
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
		
		# Still face player when stopped
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

func ai_shoot_player():
	# Only shoot if can shoot and player exists and player is in range
	if not can_shoot or not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if player is in shooting range
	if distance_to_player <= shoot_range:
		shoot_at_player()

func shoot_at_player():
	if not can_shoot:
		return
	
	print("Enemy shooting at player!")
	
	# Show laser
	if laser:
		laser.visible = true
	
	# Shoot from muzzle point (gun tip) or fallback to center
	var shoot_from = muzzle_point.global_position if muzzle_point else global_position + Vector3(0, 5, 0)
	
	# Add random inaccuracy to aim
	var accuracy_spread = 3.0  # Adjust for difficulty (higher = more miss)
	var random_offset = Vector3(
		randf_range(-accuracy_spread, accuracy_spread),
		randf_range(-accuracy_spread, accuracy_spread),
		randf_range(-accuracy_spread, accuracy_spread)
	)
	var shoot_to = player.global_position + Vector3(0, 5, 0) + random_offset
	
	# Raycast from gun to player (with inaccuracy)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(shoot_from, shoot_to)
	query.exclude = [self]  # Don't hit ourselves
	
	# Update laser to point from gun to target (shows inaccuracy visually)
	if laser:
		var distance = shoot_from.distance_to(shoot_to)
		var laser_center = (shoot_from + shoot_to) / 2.0
		
		laser.global_position = laser_center
		laser.look_at(shoot_to, Vector3.UP)
		laser.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
		laser.scale.y = distance / 100.0
		laser.scale.x = 1.0
		laser.scale.z = 1.0
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_object = result.collider
		
		# Check if we hit the player
		if hit_object == player:
			print("Enemy hit player for ", damage, " damage!")
			
			# Damage player
			if player.has_node("PlayerStats"):
				var stats = player.get_node("PlayerStats")
				stats.take_damage(damage)
		else:
			print("Enemy shot missed - hit: ", hit_object.name)
	else:
		print("Enemy shot missed completely!")
	
	# Hide laser after brief flash
	if laser:
		await get_tree().create_timer(0.05).timeout
		if laser:  # Safety check in case enemy died
			laser.visible = false
	
	# Start cooldown
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

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
				material.emission_energy_multiplier = 3.0
			
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
		
		# Change color based on health
		if current_health <= 0:
			health_label.modulate = Color.DARK_GRAY
		elif current_health < max_health * 0.3:
			health_label.modulate = Color.ORANGE
		else:
			health_label.modulate = Color.WHITE

func die():
	print("Enemy destroyed!")
	queue_free()  # Remove from scene
