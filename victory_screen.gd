extends Control

func _ready():
	get_tree().paused = false
	
	# Hide the HUD so it doesn't show over the victory screen
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.visible = false
	
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)

func _on_restart_pressed():
	# HUD rebuilds fresh from scene so no need to restore visibility
	queue_free()
	get_tree().change_scene_to_file("res://floor_1.tscn")

func _on_main_menu_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://main_menu.tscn")
