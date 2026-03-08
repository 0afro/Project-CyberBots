extends Node3D

# Pickup types
enum PickupType { HEALTH, ENERGON_SHIELD, ENERGON_DAMAGE }

# Configure in inspector
@export var pickup_type: PickupType = PickupType.HEALTH
@export var item_name: String = "Item"

# Pickup values
@export var health_amount: float = 30.0
@export var shield_amount: float = 25.0
@export var damage_boost_multiplier: float = 1.5
@export var speed_boost_multiplier: float = 2  
@export var damage_boost_duration: float = 10.0

# Respawn settings
@export var respawn_time: float = 15.0  # Seconds until respawn
@export var respawns: bool = true  # Enable/disable respawning

# Animation settings
@export var rotation_speed: float = 90.0
@export var bob_height: float = 0.5
@export var bob_speed: float = 2.0

# References to visual elements
@onready var mesh_instance = $MeshInstance3D
@onready var decal = $Decal3D if has_node("Decal3D") else null  # if need decal

# State
var time_passed: float = 0.0
var start_y: float = 0.0
var is_collected: bool = false

func _ready():
	setup_visual()
	start_y = position.y

func _process(delta):
	if not is_collected:
		# Rotate and bob when active
		rotate_y(deg_to_rad(rotation_speed * delta))
		time_passed += delta
		position.y = start_y + sin(time_passed * bob_speed) * bob_height

func setup_visual():
	var material = mesh_instance.get_surface_override_material(0)
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, material)
	
	# Set colors based on type
	match pickup_type:
		PickupType.HEALTH:
			material.albedo_color = Color.WHITE
			if decal:
				decal.visible = true
		PickupType.ENERGON_SHIELD:
			material.albedo_color = Color.BLUE
			if decal:
				decal.visible = false
		PickupType.ENERGON_DAMAGE:
			material.albedo_color = Color.RED
			if decal:
				decal.visible = false

func interact():
	if is_collected:
		return  # Already collected, ignore
	
	print("Picked up: ", item_name)
	
	# Find player and apply effect
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("PlayerStats"):
		var stats = player.get_node("PlayerStats")
		
		match pickup_type:
			PickupType.HEALTH:
				stats.heal(health_amount)
			PickupType.ENERGON_SHIELD:
				stats.add_shield(shield_amount)
			PickupType.ENERGON_DAMAGE:
				stats.activate_damage_boost(damage_boost_multiplier, damage_boost_duration, speed_boost_multiplier)
	
	# Hide the pickup
	is_collected = true
	hide_pickup()
	
	# Respawn after delay (if enabled)
	if respawns:
		await get_tree().create_timer(respawn_time).timeout
		respawn_pickup()

func hide_pickup():
	# Hide visual
	visible = false
	# Disable collision so player can't interact
	$CollisionShape3D.disabled = true

func respawn_pickup():
	# Show visual again
	visible = true
	# Re-enable collision
	$CollisionShape3D.disabled = false
	# Reset state
	is_collected = false
	print(item_name, " respawned!")
