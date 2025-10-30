extends CanvasLayer

@onready var start_button = %StartButton
@onready var controls_button = %ControlsButton
@onready var quit_button = %QuitButton
@onready var level_transition = $LevelTransition

func _on_start_button_pressed():
	$AudioNode/ButtonClick.play()
	await level_transition.fade_to_blue()
	await level_transition.fade_blue_to_green()
	level_transition.fade_from_green()
	get_tree().change_scene_to_file("res://world.tscn")


func _on_controls_button_pressed():
	$AudioNode/ButtonClick.play()
	await level_transition.fade_to_blue()
	level_transition.fade_from_blue()
	get_tree().change_scene_to_file("res://controls_screen.tscn")


func _on_quit_button_pressed():
	$AudioNode/ButtonClick.play()
	get_tree().quit()
