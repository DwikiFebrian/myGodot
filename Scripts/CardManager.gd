extends Node2D

const COLLISION_MASK = 1
const COLLISION_MASK_BOARD = 2 

var card_being_dragged
var screen_size
var is_hovereng_on_card
var hovered_card = null
var interaction_enabled = false

var active_scroll: Scroll = null
var is_targeting_scroll: bool = false
signal scroll_used(success: bool)

# referensi ke node lain
var player_hand_reference
var card_placement_reference

const CARD_SCENE_PATH = "res://Scene/Card.tscn"

# fungsi diinisiasi di awal
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	card_placement_reference = $"../CardPlacement" 
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

# fungsi dijalankan selama run (drag kartu)
func _process(delta: float) -> void:
	if not interaction_enabled:
		# bersihkan efek hover kalau kebetulan ada yang nyangkut
		if hovered_card != null and is_instance_valid(hovered_card):
			highlight_card(hovered_card, false)
			hovered_card = null
		return

	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		card_being_dragged.global_position = Vector2(clamp(mouse_position.x, 0, screen_size.x), clamp(mouse_position.y, 0, screen_size.y))
	else:
		var top_card = raycast_check_for_card()
		
		if top_card != hovered_card:
			if hovered_card != null and is_instance_valid(hovered_card):
				highlight_card(hovered_card, false)
			
			if top_card != null:
				highlight_card(top_card, true)
			
			hovered_card = top_card

# targeting waktu scroll
func activate_scroll_targeting(scroll_data: Scroll):
	active_scroll = scroll_data
	is_targeting_scroll = true
	if hovered_card != null and is_instance_valid(hovered_card):
		highlight_card(hovered_card, false)
	print("Mode Scroll Aktif! Klik kartu target.")

# lepas targeting
func cancel_scroll_targeting():
	active_scroll = null
	is_targeting_scroll = false
	print("Mode Scroll dibatalkan.")

func _input(event):
	if not interaction_enabled:
		return

	# klik kiri
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				# kalau ada scroll active
				if is_targeting_scroll and active_scroll != null:
					
					var success = active_scroll.apply_to_card(card)
					
					emit_signal("scroll_used", success)
					cancel_scroll_targeting()
					
					return 
				start_drag(card)
		else:
			# saat tombol kiri dilepas
			stop_drag()
	# klik kanan buat batalin pemakaian
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and is_targeting_scroll:
			emit_signal("scroll_used", false)
			cancel_scroll_targeting()

# fungsi buat konek signal efek hovered
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

# fungsi efek hovered on
func on_hovered_over_card(card):
	if !is_hovereng_on_card:
		is_hovereng_on_card = true
		highlight_card(card, true)

# fungsi efek hovered off
func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovereng_on_card = false

# nge-higlight kartu yang kena hovered
func highlight_card(card, hovered):
	if not is_instance_valid(card): 
		return

	if card.has_meta("hover_tween"):
		var old_tween = card.get_meta("hover_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()
			
	var tween = card.create_tween().set_parallel(true)
	card.set_meta("hover_tween", tween)
	
	var anim_speed = 0.15 
	
	if hovered:
		card.z_index = 10 
		tween.tween_property(card, "scale", Vector2(1.2, 1.2), anim_speed)
		
		if card.in_hand:
			tween.tween_property(card, "rotation", 0.0, anim_speed)
			if card.has_meta("starting_position"):
				var hover_pos = card.get_meta("starting_position") + Vector2(0, -30)
				tween.tween_property(card, "position", hover_pos, anim_speed)
				#card.tooltip_text = "Card Type: " + str(card.card_type) + "\n" 
				##//+ "Card value: " + card.value
				
	else:
		card.z_index = 1 
		tween.tween_property(card, "scale", Vector2(1.0, 1.0), anim_speed)
		
		if card.in_hand:
			if card.has_meta("starting_rotation"):
				tween.tween_property(card, "rotation", card.get_meta("starting_rotation"), anim_speed)
			if card.has_meta("starting_position"):
				tween.tween_property(card, "position", card.get_meta("starting_position"), anim_speed)

# fungsi lepas klik kiri
func on_left_click_released():
	if card_being_dragged:
		stop_drag()

# fungsi untuk detek kartu dan ambil kartunya
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_top_card(result)
	return null
	
# fungsi untuk cek kartu khusus di area submit (board)
func raycast_check_for_board():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_BOARD
	var result = space_state.intersect_point(parameters)
	return result.size() > 0 

# fungsi drag kartu
func start_drag(card):
	card_being_dragged = card
	card_being_dragged.scale = Vector2(1, 1)
	
	# kalo kartu di meja, hapus kartunya dari meja
	if card_being_dragged.has_meta("on_board") and card_being_dragged.get_meta("on_board") == true:
		card_placement_reference.remove_card_from_board(card_being_dragged)
		card_being_dragged.set_meta("on_board", false)
		
	# Jika kartu diambil dari tangan, lepaskan dari tangan
	if card_being_dragged.in_hand:
		player_hand_reference.removed_card_from_hand(card_being_dragged)
		card_being_dragged.in_hand = false

# fungsi buat berhenti drag kartu (kartu dilepas)
func stop_drag():
	if card_being_dragged:
		card_being_dragged.scale = Vector2(1.0, 1.0)
		
		# Cek apakah kartu dilepas di area board
		var dropped_on_board = raycast_check_for_board()
		
		# either dimasukin ke board atau balik ke hand
		if dropped_on_board:
			card_placement_reference.add_card_to_board(card_being_dragged)
			card_being_dragged.set_meta("on_board", true)
			card_being_dragged.in_hand = false
		else:
			player_hand_reference.add_card_to_hand(card_being_dragged)
			card_being_dragged.in_hand = true
			card_being_dragged.set_meta("on_board", false)
			
		card_being_dragged = null

# fungsi buat cek posisi kartu tertinggi, dan ambil kartunya
func get_top_card(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
