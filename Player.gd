extends CharacterBody2D

const SPEED = 150.0

var direction : Vector2 = Vector2.ZERO
var player_coords = ""
var tile_player_coords = ""
var tile_atlas = ""
var tile_source_id = ""
var animation_activation : bool = false
var cast_activation : bool = false
var number_of_reels_in = 0
var goal_number_of_reels = 0
var paused : bool = false
var completed : bool = false
var animation_position
var record_breaker : bool = false
var dialogue_animation_activation : bool = false
var bug_prevention = 0
var faster_dialogue_activated : bool = false
var clear_slot = load("res://Clear_Inventory_Slot.png")
var sell_texture
var amount_of_money = 0
var rock : bool = false

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var tile_map = $"../TileMap"
@onready var release_animation_timer = $ReleaseAnimationTimer
@onready var inventory = $Inventory
@onready var back_button = $Inventory/BackButton
@onready var inventory_slot_1 = $Inventory/Inventory_Row_1/Inventory_Slot_1
@onready var logbook = $Logbook
@onready var level_transition = $LevelTransition

signal catch_fish
signal reset_logbook
signal begin_reel_in_audio
signal end_reel_in_audio
signal append

func _ready():
	animated_sprite_2d.play("forward_idle")
	$Directions.visible = false
	$AudioNode/BackgroundAudio.play()

func _physics_process(_delta):
	if paused == true:
		return
	elif paused == false:
		if Input.is_action_just_released("cast"):
			if number_of_reels_in != goal_number_of_reels:
				return
			else:
				$AudioNode/Cast_Audio.play()
				player_coords = get_position() 
				tile_player_coords = tile_map.local_to_map(player_coords)
				tile_atlas = tile_map.get_cell_atlas_coords(1, tile_player_coords)
				tile_source_id = tile_map.get_cell_source_id(1, tile_player_coords)
				print(tile_source_id)
				if tile_source_id == 0 or tile_source_id == 7:
					handle_fishing_animations()
				else:
					return
		elif Input.is_action_just_released("reel_in"):
			if cast_activation == true:
				number_of_reels_in += 1
				if number_of_reels_in == 1:
					begin_reel_in_audio.emit()
				if number_of_reels_in == goal_number_of_reels:
					catch_fish.emit()
					end_reel_in_audio.emit()
					$AudioNode/CaughtFishAudio.play()
					cast_activation = false
					number_of_reels_in = 0
					goal_number_of_reels = 0
					release_animation_timer.start()
			else:
				return
		elif Input.is_action_pressed("move_left"):
			velocity = Vector2(-SPEED, 0)
			direction = velocity
		elif Input.is_action_pressed("move_right"):
			velocity = Vector2(SPEED, 0)
			direction = velocity
		elif Input.is_action_pressed("move_up"):
			velocity = Vector2(0, -SPEED)
			direction = velocity
		elif Input.is_action_pressed("move_down"):
			velocity = Vector2(0, SPEED)
			direction = velocity
		else:
			velocity = Vector2.ZERO
		run_animations()

func _process(_delta):
	if Input.is_action_just_released("inventory"):
		if inventory.visible == false:
			inventory.visible = true
			get_tree().paused = true
			paused = true
			inventory_slot_1.grab_focus()
			$Inventory/ColorRect/HBoxContainer/ColorRect/Market.visible = false
			if $Inventory/ColorRect/HBoxContainer/ColorRect/Market/Sell_Slot/Sell_Slot_Texture.get_texture() != clear_slot:
				inventory.check_for_open_inventory_slot()
				sell_texture = $Inventory/ColorRect/HBoxContainer/ColorRect/Market/Sell_Slot/Sell_Slot_Texture.get_texture()
				inventory.open_slot.set_texture(sell_texture)
				$Inventory/ColorRect/HBoxContainer/ColorRect/Market/Sell_Slot/Sell_Slot_Texture.set_texture(clear_slot)
				$Inventory/ColorRect/HBoxContainer/ColorRect/Market/Price_Label.text = "Sell Price: 0"
				inventory.market_visible = false
		elif inventory.visible == true:
			get_tree().paused = false
			paused = false
			inventory.visible = false
			inventory.clear_all_buttons()
			inventory.number_of_selected_boxes = 0
	elif Input.is_action_just_released("chat"):
		if rock == true: 
			if completed == false:
				$DialogueArea.visible = true
				completed = true
				$DialogueArea/AnimationPlayer.play("found", 0, 10.0)
				append.emit()
				await get_tree().create_timer(2.0).timeout
				$DialogueArea.visible = false
				$"../TextBubble2".visible = false
			else:
				return
		elif rock == false:
			if record_breaker == false:
				if bug_prevention == 1:
					return
				elif dialogue_animation_activation == true:
					$DialogueArea/AnimationPlayer.play("show_dialogue", 0, 20.0)
					bug_prevention = 1
					await get_tree().create_timer(2.15).timeout
					bug_prevention = 0
					$DialogueArea.visible = false
					dialogue_animation_activation = false
				elif dialogue_animation_activation == false:
					player_coords = get_position() 
					tile_player_coords = tile_map.local_to_map(player_coords)
					if tile_player_coords == Vector2i(55,26) or tile_player_coords == Vector2i(55,25):
						dialogue_animation_activation = true
						dialogue_box_code()
					elif tile_player_coords == Vector2i(57,26) or tile_player_coords == Vector2i(57,25):
						dialogue_animation_activation = true
						dialogue_box_code()
					elif tile_player_coords == Vector2i(56,26):
						dialogue_animation_activation = true
						dialogue_box_code()
					else:
						return
					print(tile_player_coords)
			elif record_breaker == true:
				$DialogueArea.visible = true
				completed = true
				$DialogueArea/AnimationPlayer.play("record_breaker", 0, 6.5)
				await get_tree().create_timer(3.0).timeout
				$DialogueArea.visible = false
				await get_tree().create_timer(0.75).timeout
				get_tree().change_scene_to_file("res://start_screen.tscn")
	elif Input.is_action_just_released("logbook"):
		if logbook.visible == false:
			logbook.visible = true
			get_tree().paused = true
			paused = true
		elif logbook.visible == true:
			get_tree().paused = false
			paused = false
			logbook.visible = false
			reset_logbook.emit()
	elif Input.is_action_just_released("home"):
		await level_transition.fade_to_green()
		await level_transition.fade_green_to_blue()
		get_tree().change_scene_to_file("res://start_screen.tscn")

func handle_movement_animations():
	if direction.x > 0:
		animated_sprite_2d.play("right_idle" if velocity == Vector2.ZERO else "right_walk")
		animated_sprite_2d.flip_h = false
	elif direction.x < 0: #Right Movement but flipped w/ flip_h command to create left movement
		animated_sprite_2d.play("right_idle" if velocity == Vector2.ZERO else "right_walk")
		animated_sprite_2d.flip_h = true
	elif direction.y > 0:
		animated_sprite_2d.play("forward_idle" if velocity == Vector2.ZERO else "forward_walk")
		animated_sprite_2d.flip_h = false
	elif direction.y < 0:
		animated_sprite_2d.play("backward_idle" if velocity == Vector2.ZERO else "backward_walk")
		animated_sprite_2d.flip_h = false

func run_animations():
	if animation_activation == true:
		return
	else:
		handle_movement_animations()
		move_and_slide()
	animation_activation = false

func handle_fishing_animations():
		if tile_source_id == 0:
			print(tile_atlas)
			if direction.y > 0 and tile_atlas == Vector2i(0,1) or direction.y > 0 and tile_atlas == Vector2i(3,0) or direction.y > 0 and tile_atlas == Vector2i(4,0) or direction.y > 0 and tile_atlas == Vector2i(1,2) or direction.y > 0 and tile_atlas == Vector2i(2,1):
				animated_sprite_2d.play("forward_fishing")
				animated_sprite_2d.flip_h = false
				print("forward_fishing")
				goal_number_of_reels = randi_range(10, 30)
				cast_activation = true
				animation_activation = true
			elif direction.y < 0 and tile_atlas == Vector2i(0,0) or direction.y < 0 and tile_atlas == Vector2i(1,0) or direction.y < 0 and tile_atlas == Vector2i(2,0)or direction.y < 0 and tile_atlas == Vector2i(3,1) or direction.y < 0 and tile_atlas == Vector2i(4,1):
				animated_sprite_2d.play("backward_fishing")
				animated_sprite_2d.flip_h = false
				print("backward_fishing")
				goal_number_of_reels = randi_range(10, 30)
				cast_activation = true
				animation_activation = true
			elif direction.x > 0 and tile_atlas == Vector2i(2,0) or direction.x > 0 and tile_atlas == Vector2i(2,1) or direction.x > 0 and tile_atlas == Vector2i(2,2) or direction.x > 0 and tile_atlas == Vector2i(3,0) or direction.x > 0 and tile_atlas == Vector2i(3,1) or direction.x > 0 and tile_atlas == Vector2i(1,2):
				animated_sprite_2d.play("right_fishing")
				animated_sprite_2d.flip_h = false
				print("right_fishing")
				goal_number_of_reels = randi_range(10, 30)
				cast_activation = true
				animation_activation = true
			elif direction.x < 0 and tile_atlas == Vector2i(0,0) or direction.x < 0 and tile_atlas == Vector2i(0,1) or direction.x < 0 and tile_atlas == Vector2i(0,2) or direction.x < 0 and tile_atlas == Vector2i(4,0) or direction.x < 0 and tile_atlas == Vector2i(4,1):
				animated_sprite_2d.play("right_fishing")
				animated_sprite_2d.flip_h = true
				print("left_fishing")
				goal_number_of_reels = randi_range(10, 30)
				cast_activation = true
				animation_activation = true
			else:
				return
		elif tile_source_id == 7:
			print(tile_atlas)
			if direction.y > 0 and tile_atlas == Vector2i(0,0) or direction.y > 0 and tile_atlas == Vector2i(1,0) or direction.y > 0 and tile_atlas == Vector2i(2,0) or direction.y > 0 and tile_atlas == Vector2i(0,4) or direction.y > 0 and tile_atlas == Vector2i(1,4):
				animated_sprite_2d.play("forward_fishing")
				animated_sprite_2d.flip_h = false
				print("forward_fishing")
				goal_number_of_reels = randi_range(10, 30)
				cast_activation = true
				animation_activation = true
			elif direction.y < 0 and tile_atlas == Vector2i(0,2) or direction.y < 0 and tile_atlas == Vector2i(1,2) or direction.y < 0 and tile_atlas == Vector2i(2,2) or direction.y < 0 and tile_atlas == Vector2i(0,3) or direction.y < 0 and tile_atlas == Vector2i(1,3):
				animated_sprite_2d.play("backward_fishing")
				animated_sprite_2d.flip_h = false
				print("backward_fishing")
				goal_number_of_reels = randi_range(10, 30)
				cast_activation = true
				animation_activation = true
			elif direction.x > 0 and tile_atlas == Vector2i(0,0) or direction.x > 0 and tile_atlas == Vector2i(0,1) or direction.x > 0 and tile_atlas == Vector2i(0,2) or direction.x > 0 and tile_atlas == Vector2i(1,3) or direction.x > 0 and tile_atlas == Vector2i(1,4):
				animated_sprite_2d.play("right_fishing")
				animated_sprite_2d.flip_h = false
				print("right_fishing")
				goal_number_of_reels = randi_range(10, 30)
				cast_activation = true
				animation_activation = true
			elif direction.x < 0 and tile_atlas == Vector2i(2,0) or direction.x < 0 and tile_atlas == Vector2i(2,1) or direction.x < 0 and tile_atlas == Vector2i(2,2) or direction.x < 0 and tile_atlas == Vector2i(0,3) or direction.x < 0 and tile_atlas == Vector2i(0,4):
				animated_sprite_2d.play("right_fishing")
				animated_sprite_2d.flip_h = true
				print("left_fishing")
				goal_number_of_reels = randi_range(10, 30)
				cast_activation = true
				animation_activation = true
			else:
				return
		else:
			return

func _on_texture_button_pressed():
	$AudioNode/ButtonClick.play()
	inventory.visible = true
	get_tree().paused = true
	paused = true
	back_button.grab_focus()

func dialogue_box_code():
	$DialogueArea.visible = true
	$DialogueArea/AnimationPlayer.play("show_dialogue")
	await get_tree().create_timer(18).timeout
	$DialogueArea.visible = false
	dialogue_animation_activation = false

func _on_release_animation_timer_timeout():
	if direction.y > 0:
		animated_sprite_2d.play("forward_idle")
		animated_sprite_2d.flip_h = false
	elif direction.y < 0:
		animated_sprite_2d.play("backward_idle")
		animated_sprite_2d.flip_h = false
	elif direction.x > 0:
		animated_sprite_2d.play("right_idle")
		animated_sprite_2d.flip_h = false
	elif direction.x < 0:
		animated_sprite_2d.play("right_idle")
		animated_sprite_2d.flip_h = true
	animation_activation = false #Allows for movement following animation



func _on_inventory_pause_game():
	paused = false




func _on_interaction_detector_body_entered(body):
	if body == $".":
		$"../NPC/TextBubble".visible = true


func _on_interaction_detector_body_exited(body):
	if body == $".":
		$"../NPC/TextBubble".visible = false


func _on_texture_button_2_pressed():
	$AudioNode/ButtonClick.play()
	$Logbook.visible = true
	get_tree().paused = true
	paused = true


func _on_logbook_pause_game():
	paused = false

func _on_begin_reel_in_audio():
	$AudioNode/Reel_In_Audio.play()

func _on_end_reel_in_audio():
	$AudioNode/Reel_In_Audio.stop()

func _on_background_audio_finished():
	$AudioNode/BackgroundAudio.play()

#Amount of money can be changed for various fish but must change price on inventory/market code
func _on_inventory_pufferfish_price():
	amount_of_money += 2
	$WalletImage/WalletAmount.text = "$ " + str(amount_of_money)

func _on_inventory_octopus_price():
	amount_of_money += 10
	$WalletImage/WalletAmount.text = "$ " + str(amount_of_money)

func _on_inventory_seahorse_price():
	amount_of_money += 12
	$WalletImage/WalletAmount.text = "$ " + str(amount_of_money)

func _on_inventory_sockeye_salmon_price():
	amount_of_money += 4
	$WalletImage/WalletAmount.text = "$ " + str(amount_of_money)

func _on_inventory_starfish_price():
	amount_of_money += 6
	$WalletImage/WalletAmount.text = "$ " + str(amount_of_money)


func _on_interaction_detector_2_body_entered(body):
	if body == $"." and completed == false:
		$"../TextBubble2".visible = true
		rock = true

func _on_interaction_detector_2_body_exited(body):
	if body == $".":
		$"../TextBubble2".visible = false
		rock = false

func _on_logbook_record_breaker():
	record_breaker = true
	$Directions.visible = true
