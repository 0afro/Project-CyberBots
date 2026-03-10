extends Node3D

@export var damage := 10.0
@export var fire_rate := 0.15
@export var max_ammo := 100
@export var infinite_ammo := true

var current_ammo := 100
var can_shoot := true

@onready var muzzle_point = $MuzzlePoint
@onready var laser_beam = $LaserBeam

func _ready():
	current_ammo = max_ammo
	
	if laser_beam:
		laser_beam.visible = false

func _process(delta):
	var is_shooting = Input.is_action_pressed("shoot")
	
	if laser_beam:
		laser_beam.visible = is_shooting
	
	if laser_beam and laser_beam.visible:
		update_laser_position()

func get_mouse_raycast():
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return null
	
	# Get mouse position on screen
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Project from mouse position into 3D world
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	# Raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		query.exclude = [player]
	
	return space_state.intersect_ray(query)

func update_laser_position():
	var result = get_mouse_raycast()
	if not result:
		return
	
	var hit_point = result.position if result else muzzle_point.global_position + Vector3(0, 0, -100)
	var laser_start = muzzle_point.global_position
	var laser_end = hit_point
	
	var distance = laser_start.distance_to(laser_end)
	
	var laser_center = (laser_start + laser_end) / 2.0
	laser_beam.global_position = laser_center
	
	laser_beam.look_at(laser_end, Vector3.UP)
	laser_beam.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
	
	laser_beam.scale.y = distance / 100.0
	laser_beam.scale.x = 1.5
	laser_beam.scale.z = 1.5

func shoot(camera: Camera3D, player: Node3D):
	if not can_shoot:
		return
	
	if not infinite_ammo and current_ammo <= 0:
		print("Out of ammo!")
		return
	
	if not infinite_ammo:
		current_ammo -= 1
	
	print("Blaster fired! Ammo: ", current_ammo if not infinite_ammo else "∞")
	
	# Shoot where mouse cursor is
	var result = get_mouse_raycast()
	
	if result:
		var hit_object = result.collider
		var hit_position = result.position
		
		print("Hit: ", hit_object.name)
		
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
