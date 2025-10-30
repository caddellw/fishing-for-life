extends Control

@onready var level_transition = $LevelTransition
@onready var back_button = $BackButton

func _on_back_button_pressed():
	$AudioNode/ButtonClick.play()
	await level_transition.fade_to_blue()
	level_transition.fade_from_blue()
	get_tree().change_scene_to_file("res://start_screen.tscn")
