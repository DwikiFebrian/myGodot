extends Node2D

const SPEED_DRAW = 0.3
const CARD_SCENE_PATH = "res://Scene/Card.tscn"
const CARD_WIDTH = 148
const HAND_Y_POSITION = 900
const HAND_SPACING = 140
const CURVE_FACTOR = 2.0 
const ROTATION_FACTOR = 3.0 #

var player_hand = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	#var deck = $"../Deck"
	#deck.deck_ready.connect(refill_hand)

# fungsi untuk refill hand setelah submit
func refill_hand():
	var deck = $"../Deck"
	
	var number_count = count_type("number")
	var operator_count = count_type("operator")
	
	await get_tree().create_timer(0.2).timeout
	
	# tambah number sampai 5 angka
	while number_count < 5:
		var value = deck.draw_number()
		if value == null:
			break
		
		var card = create_card("number", value)
		$"../CardManager".add_child(card)
		
		card.global_position = deck.global_position
		card.rotation = deg_to_rad(randf_range(-30, 30))
		
		add_card_to_hand(card)
		
		number_count += 1
		await get_tree().create_timer(0.1).timeout
	
	# tambah operator sampai 4 operator
	while operator_count < 4:
		var value = deck.draw_operator()
		if value == null:
			break
		
		var card = create_card("operator", value)
		$"../CardManager".add_child(card)
		
		card.global_position = deck.global_position
		card.rotation = deg_to_rad(randf_range(-30, 30))
		
		add_card_to_hand(card)
		
		operator_count += 1
		await get_tree().create_timer(0.2).timeout

# fungsi bikin kartu
func create_card(type, value):
	var card_scene = preload(CARD_SCENE_PATH)
	var card = card_scene.instantiate()
	
	card.card_type = type
	card.value = value
	
	return card

# fungsi hitung kartu di tangan
func count_type(type):
	var count = 0
	for card in player_hand:
		if card.card_type == type:
			count += 1
	return count

# fungsi nambahin kartu ke tangan
func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.append(card)
		player_hand.sort_custom(sort_cards_by_type)
		update_hand_position()
	else:
		# ambil rotasi aslinya, kalau null set ke 0
		var rot = card.get_meta("starting_rotation") if card.has_meta("starting_rotation") else 0.0
		animate_card_to_position(card, card.starting_position, rot, SPEED_DRAW)

# ambil kartu setelah craft
func add_card_to_hand_for_craft(card):
	if card not in player_hand:
		# kalau kartu baru (hasil craft / draw)
		if not card.has_meta("is_new"):
			card.set_meta("is_new", true)
		
		if card.get_meta("is_new"):
			player_hand.append(card)
		else:
			var target_index = card.saved_hand_index
			player_hand.insert(target_index, card)
		
		update_hand_position()
	else:
		# ambil rotasi aslinya, kalau null set ke 0
		var rot = card.get_meta("starting_rotation") if card.has_meta("starting_rotation") else 0.0
		animate_card_to_position(card, card.starting_position, rot, SPEED_DRAW)

# fungsi perbaiki posisi kartu
func update_hand_position():
	var center_index = (player_hand.size() - 1) / 2.0
	
	for i in range(player_hand.size()):
		var card = player_hand[i]
		
		var dist_from_center = i - center_index
		
		var target_x = center_screen_x + (dist_from_center * HAND_SPACING)
		
		var target_y = HAND_Y_POSITION + (dist_from_center * dist_from_center * CURVE_FACTOR)
		
		var target_rotation = deg_to_rad(dist_from_center * ROTATION_FACTOR)
		
		var new_position = Vector2(target_x, target_y)
		card.starting_position = new_position
		
		card.set_meta("starting_position", new_position)
		card.set_meta("starting_rotation", target_rotation)
		
		# panggil animasi
		animate_card_to_position(card, new_position, target_rotation, SPEED_DRAW)

# short type
func sort_cards_by_type(a, b):
	if a.card_type == "number" and b.card_type == "operator":
		return true 
	if a.card_type == "operator" and b.card_type == "number":
		return false
	
	return a.value < b.value

# fungsi animasinya
func animate_card_to_position(card, new_position, new_rotation, speed):
	var tween = get_tree().create_tween().set_parallel(true)
	
	tween.tween_property(card, "position", new_position, speed)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
	tween.tween_property(card, "rotation", new_rotation, speed)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# fungsi hitung posisi kartu di tangan
func calculate_hand_position(indeks):
	var total_width = (player_hand.size() -1) * CARD_WIDTH
	var x_offset = center_screen_x + indeks * CARD_WIDTH - total_width /2
	return x_offset

# fungsi hapus kartu di tangan
func removed_card_from_hand(card):
	if card in player_hand:
		card.saved_hand_index = player_hand.find(card) 
		player_hand.erase(card)
		update_hand_position()

# hapus semua kartu di tangan
func clear_all_cards():
	for card in player_hand:
		if is_instance_valid(card):
			var tween = create_tween()
			tween.tween_property(card, "modulate:a", 0.0, 0.2)
			tween.tween_callback(card.queue_free)
	
	player_hand.clear()
	print("Tangan dibersihkan untuk fase baru.")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
