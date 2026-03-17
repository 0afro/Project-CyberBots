extends Node
class_name PlayerStats

# Health system - Transformers WFC style segmented blocks
@export var max_health := 200.0
@export var health_blocks := 4  # Number of health segments
@export var health_regen_rate := 5.0  # HP per second
@export var regen_delay := 3.0  # Seconds before regen starts after damage

var current_health := 200.0
var current_max_health := 200.0  # Max health we can regen to (reduced when blocks lost)
var health_per_block := 50.0  # 200 / 4 = 50 HP per block
var time_since_damage := 0.0  # Timer for regen delay

# Shield system
@export var max_shield := 50.0
var current_shield := 0.0

# Damage boost system
var damage_multiplier := 1.0
var boost_timer := 0.0

# Speed boost system
var speed_multiplier := 1.0

# Signals
signal health_changed(new_health, max_health)
signal shield_changed(new_shield, max_shield)
signal died()

func _ready():
	current_health = max_health
	current_max_health = max_health
	health_per_block = max_health / health_blocks
	
	health_changed.emit(current_health, current_max_health)
	shield_changed.emit(current_shield, max_shield)
	
	print("PlayerStats initialized - Health: ", current_health, "/", current_max_health)
	print("Health blocks: ", health_blocks, " (", health_per_block, " HP each)")

func _process(delta):
	# Damage boost timer countdown
	if boost_timer > 0:
		boost_timer -= delta
		if boost_timer <= 0:
			damage_multiplier = 1.0
			speed_multiplier = 1.0
			print("Damage and speed boost expired")
	
	# Health regeneration (NEW!)
	if current_health < current_max_health:
		time_since_damage += delta
		
		# Start regenerating after delay
		if time_since_damage >= regen_delay:
			var regen_amount = health_regen_rate * delta
			current_health = min(current_health + regen_amount, current_max_health)
			health_changed.emit(current_health, current_max_health)

func take_damage(amount: float):
	# Reset regen timer
	time_since_damage = 0.0
	
	# Shield absorbs damage first
	if current_shield > 0:
		var shield_damage = min(amount, current_shield)
		current_shield -= shield_damage
		amount -= shield_damage
		shield_changed.emit(current_shield, max_shield)
		print("Shield absorbed ", shield_damage, " damage. Shield: ", current_shield)
	
	# Remaining damage goes to health
	if amount > 0:
		var old_health = current_health
		current_health = max(current_health - amount, 0)
		
		# Check if we lost a health block
		var old_block = ceil(old_health / health_per_block)
		var new_block = ceil(current_health / health_per_block)
		
		if new_block < old_block:
			# Lost a block! Reduce max regen health
			current_max_health = new_block * health_per_block
			print("HEALTH BLOCK LOST! Can now only regen to: ", current_max_health, " HP")
		
		health_changed.emit(current_health, current_max_health)
		print("Took ", amount, " damage. Health: ", current_health, "/", current_max_health)
		
		# Check if dead
		if current_health <= 0:
			die()

func heal(amount: float):
	# Regular healing - can't exceed current_max_health
	current_health = min(current_health + amount, current_max_health)
	health_changed.emit(current_health, current_max_health)
	print("Healed ", amount, " HP. Health: ", current_health, "/", current_max_health)

func restore_health_blocks():
	# Health pickup - restores lost blocks AND fills to max
	current_max_health = max_health
	current_health = max_health
	health_changed.emit(current_health, current_max_health)
	print("Health blocks restored! Full health: ", current_health, "/", current_max_health)

func add_shield(amount: float):
	current_shield = min(current_shield + amount, max_shield)
	shield_changed.emit(current_shield, max_shield)
	print("Shield increased by ", amount, ". Shield: ", current_shield, "/", max_shield)

func activate_damage_boost(multiplier: float, duration: float, speed_boost: float = 1.5):
	damage_multiplier = multiplier
	speed_multiplier = speed_boost
	boost_timer = duration
	print("Damage boost! x", multiplier, " + Speed boost x", speed_boost, " for ", duration, "s")

func get_damage_output(base_damage: float) -> float:
	return base_damage * damage_multiplier

func get_speed_output(base_speed: float) -> float:
	return base_speed * speed_multiplier

func die():
	print("Player died!")
	died.emit()
	
	# Reload scene after delay
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
