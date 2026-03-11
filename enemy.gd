extends CharacterBody3D

# Enemy stats
@export var max_health := 50.0
var current_health := 50.0

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
	# Quick white flash effect
	if mesh:
		var material = mesh.get_surface_override_material(0)
		if material:
			var original_color = material.albedo_color
			material.albedo_color = Color.WHITE
			await get_tree().create_timer(0.1).timeout
			material.albedo_color = original_color

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
