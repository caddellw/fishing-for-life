extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

var fish_array = ["octopus", "pufferfish", "seahorse", "sockeye_salmon", "starfish", "pufferfish", "pufferfish", "sockeye_salmon"]
var selected_fish = ""

signal octopus_caught
signal pufferfish_caught
signal seahorse_caught
signal sockeye_salmon_caught
signal starfish_caught

func _on_player_catch_fish():
	selected_fish = fish_array.pick_random()
	if selected_fish == "octopus":
		octopus_caught.emit()
	elif selected_fish == "pufferfish":
		pufferfish_caught.emit()
	elif selected_fish == "seahorse":
		seahorse_caught.emit()
	elif selected_fish == "sockeye_salmon":
		sockeye_salmon_caught.emit()
	elif selected_fish == "starfish":
		starfish_caught.emit()
	animated_sprite_2d.play(selected_fish)
	animation_player.play("display_fish")
	selected_fish = ""


func _on_player_append():
	fish_array.append("seahorse")


func _on_inventory_octopus_append():
	fish_array.append("octopus")


func _on_inventory_pufferfish_append():
	fish_array.append("pufferfish")


func _on_inventory_seahorse_append():
	fish_array.append("seahorse")


func _on_inventory_sockeye_salmon_append():
	fish_array.append("sockeye_salmon")


func _on_inventory_starfish_append():
	fish_array.append("starfish")
