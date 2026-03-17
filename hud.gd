extends CanvasLayer

# References to UI elements
@onready var health_bar = $TopLeftContainer/StatsContainer/HealthContainer/HealthBar
@onready var health_value = $TopLeftContainer/StatsContainer/HealthContainer/HealthValue
@onready var health_divider_1 = $TopLeftContainer/StatsContainer/HealthContainer/HealthDivider1  
@onready var health_divider_2 = $TopLeftContainer/StatsContainer/HealthContainer/HealthDivider2  
@onready var health_divider_3 = $TopLeftContainer/StatsContainer/HealthContainer/HealthDivider3  
@onready var shield_bar = $TopLeftContainer/StatsContainer/ShieldContainer/ShieldBar
@onready var shield_value = $TopLeftContainer/StatsContainer/ShieldContainer/ShieldValue
@onready var boost_value = $TopLeftContainer/StatsContainer/BoostContainer/BoostValue

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	
# Position dividers at 25%, 50%, 75% of health bar width
	if health_divider_1 and health_divider_2 and health_divider_3:
		var bar_width = health_bar.size.x
		var bar_pos = health_bar.position
		
		var offset = 3
	
		health_divider_1.position = Vector2(bar_pos.x + (bar_width * 0.25) + 3, bar_pos.y)  # +3 moves right
		health_divider_2.position = Vector2(bar_pos.x + (bar_width * 0.50) + 3, bar_pos.y)
		health_divider_3.position = Vector2(bar_pos.x + (bar_width * 0.75) + 3, bar_pos.y)
	
		health_divider_1.rotation = 0.38
		health_divider_2.rotation = 0.38
		health_divider_3.rotation = 0.38
	
	# Find the player and connect to their stats
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.has_node("PlayerStats"):
		var stats = player.get_node("PlayerStats")
		
		# Connect to stat change signals
		stats.health_changed.connect(_on_health_changed)
		stats.shield_changed.connect(_on_shield_changed)
		
		# Initialize bars with current values
		_on_health_changed(stats.current_health, stats.max_health)
		_on_shield_changed(stats.current_shield, stats.max_shield)
		
		print("HUD connected to PlayerStats successfully!")
	else:
		print("ERROR: Could not find player or PlayerStats!")

func _process(delta):
	# Update boost timer display
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("PlayerStats"):
		var stats = player.get_node("PlayerStats")
		if stats.boost_timer > 0:
			boost_value.text = "%.1fs" % stats.boost_timer
		else:
			boost_value.text = "--"

# Called when health changes
func _on_health_changed(new_health: float, max_health: float):
	# Bar always shows full 200 HP range
	health_bar.max_value = 200.0
	health_bar.value = new_health
	health_value.text = str(int(new_health))
	
	# Cyan blue when healthy, red when critical
	var health_percent = new_health / 200.0
	if health_percent > 0.25:
		# Healthy - Bright cyan (like WFC)
		health_bar.modulate = Color(0.0, 0.9, 1.0)
	else:
		# Critical - Red
		health_bar.modulate = Color(1.0, 0.0, 0.0)

# Called when shield changes
func _on_shield_changed(new_shield: float, max_shield: float):
	shield_bar.max_value = max_shield
	shield_bar.value = new_shield
	shield_value.text = str(int(new_shield))
	
	# Shield is bright blue when active, gray when empty
	if new_shield > 0:
		shield_bar.modulate = Color(0.0, 0.8, 1.0)
	else:
		shield_bar.modulate = Color(0.3, 0.3, 0.3)
