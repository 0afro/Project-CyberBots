extends CharacterBody3D

# Enemy stats
@export var max_health := 50.0
@export var move_speed := 15.0
@export var stop_distance := 50.0
@export var gravity := 40.0

# Shooting stats
@export var damage := 3.0
@export var shoot_range := 50.0  # Matched to stop_distance
@export var fire_rate := 2.0

# AI behavior stats
@export var chase_radius := 65.0
@export var abandon_radius := 75.0
@export var roam_radius := 15.0
@export var roam_speed := 8.0
@export var roam_pause_time := 2.0

var current_health := 50.0
var player: Node3D = null
var can_shoot := false

# AI state machine
enum AIState { ROAMING, CHASING, SHOOTING }
var current_state := AIState.ROAMING
var spawn_position := Vector3.ZERO
var roam_target := Vector3.ZERO
var roam_timer := 0.0
var state_change_cooldown := 0.0  # Prevents rapid state switching

@onready var health_label = $HealthLabel if has_node("HealthLabel") else null
@onready var mesh = $EnemyModel
@onready var laser = $EnemyLaser if has_node("EnemyLaser") else null
@onready var muzzle_point = $MuzzlePoint if has_node("MuzzlePoint") else null

func _ready():
	current_health = max_health
	
	# Store spawn position
	spawn_position = global_position
	
	# Make material unique
	if mesh:
		var material = mesh.get_active_material(0)
		if material:
			mesh.set_surface_override_material(0, material.duplicate())
	
	update_health_display()
	print("Enemy spawned with ", max_health, " HP at ", spawn_position)
	
	# Wait for player to load
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("ERROR: Enemy could not find player!")
	
	# Random initial delay for shooting
	var initial_delay = randf_range(0.0, fire_rate)
	await get_tree().create_timer(initial_delay).timeout
	can_shoot = true
	
	# Set first roam target
	set_new_roam_target()

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Decrease state change cooldown
	if state_change_cooldown > 0:
		state_change_cooldown -= delta
	
	# AI behavior
	if player:
		update_ai_state()
		
		match current_state:
			AIState.ROAMING:
				ai_roam(delta)
			AIState.CHASING:
				ai_chase_player(delta)
			AIState.SHOOTING:
				ai_shoot_player()
	
	# Move
	move_and_slide()

func update_ai_state():
	# Don't change state if on cooldown (prevents rapid flickering)
	if state_change_cooldown > 0:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	var distance_to_spawn = global_position.distance_to(spawn_position)
	
	match current_state:
		AIState.ROAMING:
			# Start chasing if player gets close
			if distance_to_player <= chase_radius:
				current_state = AIState.CHASING
				state_change_cooldown = 0.5
				print("Enemy started chasing player")
		
		AIState.CHASING:
			# Stop chasing if player too far OR enemy too far from spawn
			if distance_to_player > abandon_radius or distance_to_spawn > abandon_radius:
				current_state = AIState.ROAMING
				state_change_cooldown = 0.5
				set_new_roam_target()
				print("Enemy abandoned chase, returning to patrol")
			# Start shooting if close enough
			elif distance_to_player <= stop_distance:
				current_state = AIState.SHOOTING
				state_change_cooldown = 0.3
		
		AIState.SHOOTING:
			# Go back to chasing if player moves away
			if distance_to_player > stop_distance + 5.0:  # Add small buffer
				current_state = AIState.CHASING
				state_change_cooldown = 0.3
			# Abandon if player runs too far
			elif distance_to_player > abandon_radius or distance_to_spawn > abandon_radius:
				current_state = AIState.ROAMING
				state_change_cooldown = 0.5
				set_new_roam_target()

func ai_roam(delta):
	# Safety: Don't roam too far from spawn
	var distance_to_spawn = global_position.distance_to(spawn_position)
	if distance_to_spawn > roam_radius * 1.5:
		# Too far - return to spawn
		roam_target = spawn_position
	
	# Move toward roam target
	var direction_to_target = (roam_target - global_position)
	var distance_to_target = direction_to_target.length()
	
	# Reached roam point - pause, then pick new target
	if distance_to_target < 2.0:
		velocity.x = 0
		velocity.z = 0
		
		roam_timer += delta
		if roam_timer >= roam_pause_time:
			set_new_roam_target()
			roam_timer = 0.0
	else:
		# Move toward roam target
		direction_to_target = direction_to_target.normalized()
		direction_to_target.y = 0
		direction_to_target = direction_to_target.normalized()
		
		velocity.x = direction_to_target.x * roam_speed
		velocity.z = direction_to_target.z * roam_speed
		
		# Face movement direction
		if direction_to_target.length() > 0.1:
			look_at(Vector3(roam_target.x, global_position.y, roam_target.z), Vector3.UP)

func set_new_roam_target():
	# Pick random point within roam_radius of spawn
	var random_offset = Vector3(
		randf_range(-roam_radius, roam_radius),
		0,
		randf_range(-roam_radius, roam_radius)
	)
	roam_target = spawn_position + random_offset
	roam_target.y = spawn_position.y  # Keep same height

func ai_chase_player(delta):
	# Safety: Don't chase too far from spawn
	var distance_to_spawn = global_position.distance_to(spawn_position)
	if distance_to_spawn > abandon_radius:
		current_state = AIState.ROAMING
		state_change_cooldown = 0.5
		set_new_roam_target()
		return
	
	var direction_to_player = (player.global_position - global_position)
	var distance_to_player = direction_to_player.length()
	
	# Move toward player
	direction_to_player = direction_to_player.normalized()
	direction_to_player.y = 0
	direction_to_player = direction_to_player.normalized()
	
	velocity.x = direction_to_player.x * move_speed
	velocity.z = direction_to_player.z * move_speed
	
	# Face player
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

func ai_shoot_player():
	# Stop moving
	velocity.x = 0
	velocity.z = 0
	
	# Face player
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Shoot if in range
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= shoot_range:
		shoot_at_player()

func shoot_at_player():
	if not can_shoot:
		return
	
	print("Enemy shooting at player!")
	
	# Show laser
	if laser:
		laser.visible = true
	
	# Shoot from muzzle point
	var shoot_from = muzzle_point.global_position if muzzle_point else global_position + Vector3(0, 5, 0)
	
	# Add inaccuracy
	var accuracy_spread = 5.0
	var random_offset = Vector3(
		randf_range(-accuracy_spread, accuracy_spread),
		randf_range(-accuracy_spread, accuracy_spread),
		randf_range(-accuracy_spread, accuracy_spread)
	)
	var shoot_to = player.global_position + Vector3(0, 5, 0) + random_offset
	
	# Raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(shoot_from, shoot_to)
	query.exclude = [self]
	
	# Update laser
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
		
		if hit_object == player:
			print("Enemy hit player for ", damage, " damage!")
			
			if player.has_node("PlayerStats"):
				var stats = player.get_node("PlayerStats")
				stats.take_damage(damage)
		else:
			print("Enemy shot missed - hit: ", hit_object.name)
	else:
		print("Enemy shot missed completely!")
	
	# Hide laser
	if laser:
		await get_tree().create_timer(0.05).timeout
		if laser:
			laser.visible = false
	
	# Cooldown
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func take_damage(amount: float):
	current_health -= amount
	print("Enemy took ", amount, " damage. HP: ", current_health, "/", max_health)
	
	flash_damage()
	update_health_display()
	
	# When hit, switch to chase mode
	if player and current_state == AIState.ROAMING:
		current_state = AIState.CHASING
		state_change_cooldown = 0.5
		print("Enemy alerted - chasing player!")
	
	if current_health <= 0:
		die()

func flash_damage():
	if mesh:
		var material = mesh.get_surface_override_material(0)
		if material:
			var original_albedo = material.albedo_color
			var original_emission = material.emission if material.emission_enabled else Color.BLACK
			var original_emission_energy = material.emission_energy_multiplier if material.emission_enabled else 0.0
			
			material.albedo_color = Color.WHITE
			if material.emission_enabled:
				material.emission = Color.WHITE
				material.emission_energy_multiplier = 3.0
			
			await get_tree().create_timer(0.1).timeout
			
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
