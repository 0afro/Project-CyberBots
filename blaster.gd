extends Node3D

@export var damage := 10.0
@export var fire_rate := 0.15
@export var max_ammo := 100
@export var infinite_ammo := true
@export var show_laser_sight := true  # Toggle laser always visible

var current_ammo := 100
var can_shoot := true

@onready var muzzle_point = $MuzzlePoint
@onready var laser_beam = $LaserBeam

func _ready():
	current_ammo = max_ammo
	if laser_beam:
		laser_beam.visible = show_laser_sight

func _process(delta):
	# Only update laser if it exists and should be visible
	if not laser_beam or not show_laser_sight:
		return
	
	# Get camera
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Raycast from camera
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var forward = -camera.global_transform.basis.z
	var to = from + forward * 100
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		query.exclude = [player]
	
	var result = space_state.intersect_ray(query)
	
	# Get hit point or max range
	var hit_point = result.position if result else to
	var laser_start = muzzle_point.global_position
	var distance = laser_start.distance_to(hit_point)
	
	# Position laser
	laser_beam.global_position = laser_start.lerp(hit_point, 0.5)
	laser_beam.look_at(hit_point, Vector3.UP)
	laser_beam.rotate_object_local(Vector3.RIGHT, PI / 2)
	
	# Scale laser to distance
	laser_beam.scale.y = distance / 100.0

func shoot(camera: Camera3D, player: Node3D):
	if not can_shoot:
		return
	
	if not infinite_ammo and current_ammo <= 0:
		print("Out of ammo!")
		return
	
	if not infinite_ammo:
		current_ammo -= 1
	
	print("Blaster fired! Ammo: ", current_ammo if not infinite_ammo else "∞")
	
	# Shoot from camera center
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var forward = -camera.global_transform.basis.z
	var to = from + forward * 100
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [player]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_object = result.collider
		var hit_position = result.position
		
		print("Hit: ", hit_object.name, " at ", hit_position)
		
		var final_damage = damage
		if player.has_node("PlayerStats"):
			var stats = player.get_node("PlayerStats")
			final_damage = stats.get_damage_output(damage)
		
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(final_damage)
	else:
		print("Shot missed!")
	
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
