extends Node3D

@export var damage := 10.0
@export var fire_rate := 0.15
@export var max_ammo := 100
@export var infinite_ammo := true

var current_ammo := 100
var can_shoot := true

@onready var muzzle_point = $MuzzlePoint

func _ready():
	current_ammo = max_ammo

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
