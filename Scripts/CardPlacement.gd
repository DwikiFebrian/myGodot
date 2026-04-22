extends Node2D

const CARD_WIDTH = 150 # Jarak antar kartu saat dijejerkan
const BOARD_Y_POSITION = 500

# array yang langsung menyimpan kartu yang di-drop
var placed_cards = [] 
var center_screen_x

# jatah craft
var max_craft = 1   
var craft_used = 0    

# jatah hand
var max_submit = 3
var submit_used = 0

@onready var preview_label = $"../ScorePreview"
@onready var total_label = $"../TotalScore"
@onready var phase_label = $"../PhaseLabel"
@onready var submit_label = $"../VBoxContainer/SubmitCount"
@onready var craft_label = $"../VBoxContainer/CraftCount"

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	$"../OrderManager".connect("phase_changed", Callable(self, "_on_phase_changed"))
	update_submit_button()
	update_craft_button()
	update_total_score()
	update_phase_ui()
	update_submit_ui()
	update_craft_ui()

# fungsi untuk nambahin kartu di board
func add_card_to_board(card):
	if card not in placed_cards:
		placed_cards.append(card)
		update_board_positions()
		
		update_all_ui()

# fungsi untuk balikin kartu ke tangan
func remove_card_from_board(card):
	if card in placed_cards:
		placed_cards.erase(card)
		update_board_positions()
		
		update_all_ui()

# fungsi untuk merapikan kartu di board
func update_board_positions():
	var total_width = (placed_cards.size() - 1) * CARD_WIDTH
	
	for i in range(placed_cards.size()):
		var card = placed_cards[i]
		
		# rumus centering
		var target_x = center_screen_x + (i * CARD_WIDTH) - (total_width / 2)
		var target_position = Vector2(target_x, BOARD_Y_POSITION)
		
		# animasi saat ke tengah
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", target_position, 0.2).set_trans(Tween.TRANS_SINE)

# fungsi balikin array kartu untuk dievaluasi
func get_filled_cards():
	return placed_cards 

# fungsi cek aturan validasi susunan kartu (angka - operator - angka)
func is_valid_expression(cards):
	if cards.size() == 0:
		return false
	
	# harus mulai dengan number
	if cards[0].card_type != "number":
		print("harus mulai dengan angka")
		return false
	
	# tidak boleh berakhir dengan operator
	if cards[cards.size() - 1].card_type != "number":
		print("tidak boleh diakhiri operator")
		return false
	
	# cek pola selang-seling
	for i in range(cards.size()):
		var card = cards[i]
		
		if i % 2 == 0 and card.card_type != "number":
			print("posisi ", i, " harus number")
			return false
		
		if i % 2 == 1 and card.card_type != "operator":
			print("posisi ", i, " harus operator")
			return false
	
	return true

# fungsi eksekusi tombol Submit Kartu
func submit_placed_cards():
	if submit_used >= max_submit:
		print("jatah submit habis!")
		return
		
	var cards = get_filled_cards().duplicate()
	
	if not is_valid_expression(cards):
		print("format salah!")
		return
		
	var result = calculate_expression(cards)
	
	var cards_submitted = false
	
	# loop langsung ke kartunya untuk dibuang
	for card in placed_cards:
		if card.card_type == "number":
			$"../Deck".add_num_to_discard(card.value)
		elif card.card_type == "operator":
			$"../Deck".add_ops_to_discard(card.value)
		
		$"../PlayerHand".removed_card_from_hand(card)
		card.queue_free()
		cards_submitted = true
		
	# bersihkan board setelah submit
	placed_cards.clear() 
	submit_used += 1
	var om = $"../OrderManager"
	var old_phase = om.current_phase
	var phase_won_in_this_turn = false
	
	if result != null:
		var outcome = om.process_result(cards, result)

		if outcome.success:
			print("Score gained:", outcome.value)
		else:
			print("Penalty:", outcome.value)

		update_total_score()
		if old_phase != om.current_phase:
			phase_won_in_this_turn = true
	
	update_all_ui()
	
	if cards_submitted:
		if old_phase == om.current_phase:
			$"../PlayerHand".refill_hand()
	
	if submit_used >= max_submit:

		if submit_used >= max_submit:
			if not phase_won_in_this_turn: 
				if om.total_score < om.get_current_phase()["target"]:
					print("GAME OVER: Hand Habis & Target Tidak Tercapai")
					om.emit_signal("game_over")

# fungsi kalkulasi ekspresi matematika di board
func calculate_expression(cards):
	var tokens = []
	
	for card in cards:
		tokens.append(card.value)
	
	# pemdas * /
	var i = 0
	while i < tokens.size():
		if str(tokens[i]) == "*" or str(tokens[i]) == "/":
			var left = tokens[i-1]
			var right = tokens[i+1]
			
			var res
			if str(tokens[i]) == "*":
				res = left * right
			else:
				if right == 0:
					print("bagi 0!")
					return null
				res = left / right
			
			tokens[i-1] = res
			tokens.remove_at(i)
			tokens.remove_at(i)
			
			i = 0
		else:
			i += 1
	
	# pemdas + dan -
	var result = tokens[0]
	i = 1
	
	while i < tokens.size():
		var op = str(tokens[i])
		var val = tokens[i+1]
		
		if op == "+":
			result += val
		elif op == "-":
			result -= val
		
		i += 2
	
	return result

# fungsi hitung kalkulasi kartu di board
func get_current_board_score():
	if placed_cards.size() == 0:
		return null
	
	if not is_valid_expression(placed_cards):
		return null
	
	return calculate_expression(placed_cards)

# update score sementara
func update_score_preview(): 
	var score = get_current_board_score()
	
	if score == null:
		preview_label.text = ""
	else:
		preview_label.text = "Board Score: " + str(score)

# fungsi buat cek apakah ready submit atau ga
func is_ready_to_submit():
	return is_valid_expression(placed_cards)

# fungsi tombol submit yang berubah
func update_submit_button():
	var is_valid = is_valid_expression(placed_cards)
	var can_submit = submit_used < max_submit
	
	$"../HBoxContainer/SubmitButton".disabled = not (is_valid and can_submit)

# fungsi hasil craft kartu
func craft_cards():
	if not is_ready_to_craft():
		return
	
	craft_used += 1
	
	var result = calculate_expression(placed_cards)
	
	if result == null:
		return
	
	# buang kartu lama
	for card in placed_cards:
		if card.card_type == "number":
			$"../Deck".add_num_to_discard(card.value)
		elif card.card_type == "operator":
			$"../Deck".add_ops_to_discard(card.value)
		
		$"../PlayerHand".removed_card_from_hand(card)
		card.queue_free()
	
	placed_cards.clear()
	
	update_all_ui()
	
	# bikin kartu baru
	create_result_card(result)

# balikin hasil jadi value untuk dibuat label
func create_result_card(value):
	var card_scene = preload("res://Scene/Card.tscn")
	var new_card = card_scene.instantiate()
	
	new_card.card_type = "number"
	new_card.value = value
	
	$"../CardManager".add_child(new_card)
	
	$"../PlayerHand".add_card_to_hand_for_craft(new_card)
	
	update_all_ui()

func update_total_score():
	var total = $"../OrderManager".total_score
	total_label.text = "Score: " + str(total)

# fungsi cek craft
func is_ready_to_craft():
	return is_valid_expression(placed_cards) \
		and placed_cards.size() == 3 \
		and craft_used < max_craft

# update button craft
func update_craft_button():
	var is_ready = is_ready_to_craft()
	$"../HBoxContainer/CraftButton".disabled = not is_ready

# info phase
func update_phase_ui():
	var phase = $"../OrderManager".get_current_phase()
	var order = $"../OrderManager".get_current_order_name()
	var remaining = phase["target"] - $"../OrderManager".total_score

	var text = ""
	text += order + "\n"
	text += phase["name"] + "\n"
	text += "Make: 24\n"
	text += "Score to Next: " + str(phase["target"]) + "\n"
	text += "Need: " + str(max(0, remaining)) + "\n"
	text += "Range: " + str(24 - phase["galat"]) + " - " + str(24 + phase["galat"])

	phase_label.text = text

# info hand submit sisa
func update_submit_ui():
	submit_label.text = "Submit: " + str(max_submit - submit_used)

# info craft sisa
func update_craft_ui():
	craft_label.text = "Craft: " + str(max_craft - craft_used)

func _on_phase_changed():
	submit_used = 0
	craft_used = 0
	
	$"../Deck".reset_deck_for_new_phase()
	update_all_ui()
	
	print("Phase baru! submit & craft di-reset")

# fungsi update ui
func update_all_ui():
	update_score_preview()
	update_submit_button()
	update_craft_button()
	update_phase_ui()
	update_submit_ui()
	update_craft_ui()
