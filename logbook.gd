extends CanvasLayer

signal pause_game
signal record_breaker

var best_octopus_weight = 0.0
var best_pufferfish_weight = 0.0
var best_seahorse_weight = 0.0
var best_sockeye_salmon_weight = 0.0
var best_starfish_weight = 0.0
var caught_weight
var record_weight = 92
#Changing record_weight alters the win condition; therefore, making it easier/harder

func _ready():
	update_all_best_weights()

func _process(_delta):
	if best_octopus_weight >= record_weight and best_pufferfish_weight >= record_weight and best_seahorse_weight >= record_weight and best_sockeye_salmon_weight >= record_weight and best_starfish_weight >= record_weight:
		record_breaker.emit()
	else:
		return

func _on_next_page_button_pressed():
	$AudioNode/ButtonClick.play()
	$BlankPage.visible = false
	$Page1.visible = false
	$Page2.visible = true
	$Page3.visible = true

func _on_last_page_button_pressed():
	$AudioNode/ButtonClick.play()
	$BlankPage.visible = true
	$Page1.visible = true
	$Page2.visible = false
	$Page3.visible = false

func _on_next_page_button_pressed_2():
	$AudioNode/ButtonClick.play()
	$Page2.visible = false
	$Page3.visible = false
	$Page4.visible = true
	$Page5.visible = true


func _on_last_page_button_pressed_2():
	$AudioNode/ButtonClick.play()
	$Page2.visible = true
	$Page3.visible = true
	$Page4.visible = false
	$Page5.visible = false


func _on_back_button_pressed():
	$AudioNode/ButtonClick.play()
	visible = false
	get_tree().paused = false
	pause_game.emit()
	$BlankPage.visible = true
	$Page1.visible = true
	$Page2.visible = false
	$Page3.visible = false
	$Page4.visible = false
	$Page5.visible = false


func _on_fish_octopus_caught():
	caught_weight = randf_range(5.0, 100.0)
	if caught_weight > best_octopus_weight:
		best_octopus_weight = caught_weight
	update_all_best_weights()


func _on_fish_pufferfish_caught():
	caught_weight = randf_range(5.0, 100.0)
	if caught_weight > best_pufferfish_weight:
		best_pufferfish_weight = caught_weight
	update_all_best_weights()


func _on_fish_seahorse_caught():
	caught_weight = randf_range(5.0, 100.0)
	if caught_weight > best_seahorse_weight:
		best_seahorse_weight = caught_weight
	update_all_best_weights()


func _on_fish_sockeye_salmon_caught():
	caught_weight = randf_range(5.0, 100.0)
	if caught_weight > best_sockeye_salmon_weight:
		best_sockeye_salmon_weight = caught_weight
	update_all_best_weights()


func _on_fish_starfish_caught():
	caught_weight = randf_range(5.0, 100.0)
	if caught_weight > best_starfish_weight:
		best_starfish_weight = caught_weight
	update_all_best_weights()

func update_all_best_weights():
	$Page1/BestWeight.text = "Best Weight: " + str(best_octopus_weight) + " lbs"
	$Page2/BestWeight.text = "Best Weight: " + str(best_pufferfish_weight) + " lbs"
	$Page3/BestWeight.text = "Best Weight: " + str(best_seahorse_weight) + " lbs"
	$Page4/BestWeight.text = "Best Weight: " + str(best_sockeye_salmon_weight) + " lbs"
	$Page5/BestWeight.text = "Best Weight: " + str(best_starfish_weight) + " lbs"


func _on_player_reset_logbook():
	$BlankPage.visible = true
	$Page1.visible = true
	$Page2.visible = false
	$Page3.visible = false
	$Page4.visible = false
	$Page5.visible = false
