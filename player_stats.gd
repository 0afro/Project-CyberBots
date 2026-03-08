extends Node
class_name PlayerStats

# Health system
@export var max_health := 100.0
var current_health := 100.0

# Shield system
@export var max_shield := 50.0
var current_shield := 0.0  # Starts at 0, gain from pickups

# Damage multiplier (for damage boost power-up)
var damage_multiplier := 1.0
var boost_timer := 0.0
var speed_multiplier := 1.0

# Signals for UI updates
signal health_changed(new_health, max_health)
signal shield_changed(new_shield, max_shield)
signal died()

func _ready():
	current_health = max_health
	current_shield = 0.0
	print("PlayerStats initialized - Health: ", current_health, "/", max_health)

func _process(delta):
	# Damage boost timer countdown
	if boost_timer > 0:
		boost_timer -= delta
		if boost_timer <= 0:
			damage_multiplier = 1.0
			speed_multiplier = 1.0
			print("Damage and speed boost expired")

# Take damage - shield absorbs first, then health
func take_damage(amount: float):
	print("=== TAKING DAMAGE: ", amount, " ===")
	
	# Shield absorbs damage first
	if current_shield > 0:
		var shield_damage = min(amount, current_shield)
		current_shield -= shield_damage
		amount -= shield_damage
		shield_changed.emit(current_shield, max_shield)
		print("Shield absorbed ", shield_damage, ". Remaining: ", current_shield)
	
	# Remaining damage goes to health
	if amount > 0:
		current_health -= amount
		current_health = max(current_health, 0)
		health_changed.emit(current_health, max_health)
		print("Health: ", current_health, "/", max_health)
	
	# Check if dead
	if current_health <= 0:
		die()

# Heal player (health pickup)
func heal(amount: float):
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
	print("Healed +", amount, ". Health: ", current_health, "/", max_health)

# Add shield (energon shield pickup)
func add_shield(amount: float):
	current_shield = min(current_shield + amount, max_shield)
	shield_changed.emit(current_shield, max_shield)
	print("Shield +", amount, ". Shield: ", current_shield, "/", max_shield)

# Activate damage AND speed boost (energon damage pickup)
func activate_damage_boost(multiplier: float, duration: float, speed_boost: float = 1.5):
	damage_multiplier = multiplier
	speed_multiplier = speed_boost  # NEW
	boost_timer = duration
	print("Damage boost! x", multiplier, " + Speed boost x", speed_boost, " for ", duration, "s")
	
# Get damage output (for weapons)
func get_damage_output(base_damage: float) -> float:
	return base_damage * damage_multiplier

# Get current speed output (for player movement)
func get_speed_output(base_speed: float) -> float:
	return base_speed * speed_multiplier
	
func die():
	print("========== PLAYER DIED ==========")
	died.emit()
	# Reload scene after 2 seconds
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
