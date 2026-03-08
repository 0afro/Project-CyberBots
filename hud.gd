extends CanvasLayer

# References to UI elements
@onready var health_bar = $TopLeftContainer/StatsContainer/HealthContainer/HealthBar
@onready var health_value = $TopLeftContainer/StatsContainer/HealthContainer/HealthValue
@onready var shield_bar = $TopLeftContainer/StatsContainer/ShieldContainer/ShieldBar
@onready var shield_value = $TopLeftContainer/StatsContainer/ShieldContainer/ShieldValue
@onready var boost_value = $TopLeftContainer/StatsContainer/BoostContainer/BoostValue

func _ready():
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
	health_bar.max_value = max_health
	health_bar.value = new_health
	health_value.text = str(int(new_health))
	
	# White when healthy, red when critical
	var health_percent = new_health / max_health
	if health_percent > 0.3:
		health_bar.modulate = Color.WHITE
	else:
		health_bar.modulate = Color.RED

# Called when shield changes
func _on_shield_changed(new_shield: float, max_shield: float):
	shield_bar.max_value = max_shield
	shield_bar.value = new_shield
	shield_value.text = str(int(new_shield))
	
	# Shield is bright blue
	shield_bar.modulate = Color.DODGER_BLUE
