extends Control

func _ready():
	get_tree().paused = false
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)

func _on_restart_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://floor_1.tscn")

func _on_main_menu_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://main_menu.tscn")
