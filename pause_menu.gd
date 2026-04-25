extends Control

func _ready():
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_resume_pressed():
	get_tree().paused = false
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_paused = false
	queue_free()

func _on_main_menu_pressed():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
