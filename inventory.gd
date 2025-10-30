extends CanvasLayer

signal back_button_released
signal pause_game
signal octopus_price
signal pufferfish_price
signal seahorse_price
signal sockeye_salmon_price
signal starfish_price
signal octopus_append
signal pufferfish_append
signal seahorse_append
signal sockeye_salmon_append
signal starfish_append

var mouse_pos
var next_texture : Texture2D
var starfish_texture_resource : Texture2D = load("res://Assets/Starfish_Image.png")
var pufferfish_texture_resource : Texture2D = load("res://Assets/Pufferfish_Image.png")
var sockeye_salmon_texture_resource : Texture2D = load("res://Assets/Sockeye_Salmon_Image.png")
var octopus_texture_resource : Texture2D = load("res://Assets/Octopus_Image.png")
var seahorse_texture_resource : Texture2D = load("res://Assets/Seahorse_Image.png")
var open_slot
var sell_texture
var price
var empty = str(load("res://Clear_Inventory_Slot.png"))
var clear_slot = load("res://Clear_Inventory_Slot.png")
var price_upgrade
var current_wallet

@onready var sell_slot_texture = $ColorRect/HBoxContainer/ColorRect/Market/Sell_Slot/Sell_Slot_Texture
@onready var price_label = $ColorRect/HBoxContainer/ColorRect/Market/Price_Label
@onready var sell_button = $ColorRect/HBoxContainer/ColorRect/Market/SellButton
@onready var price_upgrade_label = $ColorRect/HBoxContainer/ColorRect/Market/Price_Upgrade_Label

var number_of_selected_boxes = 0
var texture_1: Texture2D
var texture_2: Texture2D
var textured_object_1: TextureRect
var textured_object_2: TextureRect
var market_visible: bool = false

func _ready(): 
  # Dynamically connect all inventory slots
	for row in get_children():
		for slot in row.get_children():
			if slot.has_signal("pressed"):
		# creates one signal for all inventory button presses
				var argument: Node = slot.find_child("Inventory_Slot_Texture")
		# calls _on_inventory_slot_pressed
				slot.connect("pressed", Callable(self, "_on_inventory_slot_pressed").bind(argument))

func _process(_delta):
	if number_of_selected_boxes == 2:
		number_of_selected_boxes = 0
		clear_all_buttons()
		$ColorRect/BackButton.grab_focus()
		check_for_open_inventory_slot()


func _on_back_button_pressed():
	$AudioNode/ButtonClick.play()
	visible = false
	get_tree().paused = false
	back_button_released.emit()
	pause_game.emit()
	clear_all_buttons()
	$ColorRect/HBoxContainer/ColorRect/Market.visible = false
	if sell_slot_texture.get_texture() != clear_slot:
		check_for_open_inventory_slot()
		sell_texture = sell_slot_texture.get_texture()
		open_slot.set_texture(sell_texture)
		sell_slot_texture.set_texture(clear_slot)
		price_label.text = "Sell Price: 0"
		price_upgrade_label.text = "Price: 0"
	market_visible = false
	number_of_selected_boxes = 0

func clear_all_buttons():
	var color_rect = $ColorRect
	# Iterate through rows
	for row in color_rect.get_children():
		# Iterate through slots in each row
		for slot in row.get_children():
			# Ensure it's a button
			if slot.has_method("set_button_pressed"):
				slot.button_pressed = false

func check_for_open_inventory_slot():
	for row in find_children("Inventory_Row_?"):
		for slot in row.get_children():
			var texture_node = slot.find_child("Inventory_Slot_Texture")
			if str(texture_node.get_texture()) == empty:
				open_slot = texture_node
				open_slot.set_texture(next_texture)
				return
					
func _on_inventory_slot_pressed(texture_object):  
	if number_of_selected_boxes == 0:
		texture_1 = texture_object.get_texture()
		textured_object_1 = texture_object
		$AudioNode/ButtonClick.play()
		if market_visible == true:
			texture_2 = sell_slot_texture.get_texture()
			textured_object_2 = sell_slot_texture
			textured_object_1.set_texture(texture_2)
			textured_object_2.set_texture(texture_1)
			sell_texture = textured_object_2.get_texture()
			pricing_fish()
			pricing_upgrade()
			number_of_selected_boxes = 1
	elif number_of_selected_boxes == 1:
		if market_visible == false:
			texture_2 = texture_object.get_texture()
			textured_object_2 = texture_object
			$AudioNode/ButtonClick.play()
			# Swap the textures
			textured_object_1.set_texture(texture_2)
			textured_object_2.set_texture(texture_1)
	number_of_selected_boxes += 1
	# Reset after two selections
	if number_of_selected_boxes > 1:
		number_of_selected_boxes = 0

func pricing_fish():
	if sell_texture == octopus_texture_resource:
		price = 10
		price_label.text = "Sell Price: " + str(price)
	elif sell_texture == pufferfish_texture_resource:
		price = 2
		price_label.text = "Sell Price: " + str(price)
	elif sell_texture == seahorse_texture_resource:
		price = 12
		price_label.text = "Sell Price: " + str(price)
	elif sell_texture == sockeye_salmon_texture_resource:
		price = 4
		price_label.text = "Sell Price: " + str(price)
	elif sell_texture == starfish_texture_resource:
		price = 6
		price_label.text = "Sell Price: " + str(price)
	else:
		price = 0
		price_label.text = "Sell Price: " + str(price)

func pricing_upgrade():
	if sell_texture == octopus_texture_resource:
		price_upgrade = 75
		price_upgrade_label.text = "Price: " + str(price_upgrade)
	elif sell_texture == pufferfish_texture_resource:
		price_upgrade = 25
		price_upgrade_label.text = "Price: " + str(price_upgrade)
	elif sell_texture == seahorse_texture_resource:
		price_upgrade = 100
		price_upgrade_label.text = "Price: " + str(price_upgrade)
	elif sell_texture == sockeye_salmon_texture_resource:
		price_upgrade = 30
		price_upgrade_label.text = "Price: " + str(price_upgrade)
	elif sell_texture == starfish_texture_resource:
		price_upgrade = 50
		price_upgrade_label.text = "Price: " + str(price_upgrade)
	else:
		price_upgrade = 0
		price_upgrade_label.text = "Price: " + str(price_upgrade)

func _on_fish_octopus_caught():
	next_texture = octopus_texture_resource
	check_for_open_inventory_slot()

func _on_fish_pufferfish_caught():
	next_texture = pufferfish_texture_resource
	check_for_open_inventory_slot()

func _on_fish_seahorse_caught():
	next_texture = seahorse_texture_resource
	check_for_open_inventory_slot()

func _on_fish_sockeye_salmon_caught():
	next_texture = sockeye_salmon_texture_resource
	check_for_open_inventory_slot()

func _on_fish_starfish_caught(): 
	next_texture = starfish_texture_resource
	check_for_open_inventory_slot()

func _on_market_button_pressed():
	$AudioNode/ButtonClick.play()
	if market_visible == true:
		$ColorRect/HBoxContainer/ColorRect/Market.visible = false
		if sell_slot_texture.get_texture() != clear_slot:
			check_for_open_inventory_slot()
			sell_texture = sell_slot_texture.get_texture()
			open_slot.set_texture(sell_texture)
			sell_slot_texture.set_texture(clear_slot)
			price_label.text = "Sell Price: 0"
			price_upgrade_label.text = "Price: 0"
		market_visible = false
	elif market_visible == false:
		$ColorRect/HBoxContainer/ColorRect/Market.visible = true
		market_visible = true

func _on_sell_button_pressed():
	sell_texture = sell_slot_texture.get_texture()
	pricing_fish()
	if price == 10:
		octopus_price.emit()
	elif price == 2:
		pufferfish_price.emit()
	elif price == 12:
		seahorse_price.emit()
	elif price == 4:
		sockeye_salmon_price.emit()
	elif price == 6:
		starfish_price.emit()
	elif price == 0:
		return
	$AudioNode/SellSound.play()
	sell_slot_texture.set_texture(clear_slot)
	price_label.text = "Sell Price: 0"
	price_upgrade_label.text = "Price: 0"
	price = 0

func _on_increase_catch_button_pressed():
	sell_texture = sell_slot_texture.get_texture()
	pricing_upgrade()
	current_wallet = $"..".amount_of_money
	current_wallet -= price_upgrade
	if current_wallet >= 0:
		$"..".amount_of_money = current_wallet
		$"../WalletImage/WalletAmount".text = "$ " + str($"..".amount_of_money)
		if sell_texture == octopus_texture_resource:
			$AudioNode/SellSound.play()
			octopus_append.emit()
		elif sell_texture == pufferfish_texture_resource:
			$AudioNode/SellSound.play()
			pufferfish_append.emit()
		elif sell_texture == seahorse_texture_resource:
			$AudioNode/SellSound.play()
			seahorse_append.emit()
		elif sell_texture == starfish_texture_resource:
			$AudioNode/SellSound.play()
			starfish_append.emit()
		elif sell_texture == sockeye_salmon_texture_resource:
			$AudioNode/SellSound.play()
			sockeye_salmon_append.emit()
	elif current_wallet < 0:
		current_wallet += price_upgrade
		return
