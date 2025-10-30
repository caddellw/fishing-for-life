extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func fade_to_blue():
	animation_player.play("fade_to_blue")
	await animation_player.animation_finished

func fade_from_blue():
	animation_player.play("fade_from_blue")
	await animation_player.animation_finished

func fade_blue_to_green():
	animation_player.play("fade_blue_to_green")
	await animation_player.animation_finished

func fade_from_green():
	animation_player.play("fade_from_green")
	await animation_player.animation_finished

func fade_to_green():
	animation_player.play("fade_to_green")
	await animation_player.animation_finished

func fade_green_to_blue():
	animation_player.play("fade_green_to_blue")
	await animation_player.animation_finished
