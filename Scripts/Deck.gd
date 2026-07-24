extends Node2D

const DECK_Y_POSITION = 1200
const CARD_SCENE = preload("res://Scene/Card.tscn")

@onready var deck_viewer = $"../CanvasLayer3/DeckViewer"

# inisiasi array
var player_num_deck = []
var player_operator_deck = []
var number_discard = []
var operator_discard = []

# signal dipakai biar visual bisa nyesuain (ngehindarin race condition)
signal deck_ready
signal deck_changed

func _process(delta: float) -> void:
	pass

func _ready() -> void:
	randomize()
	create_decks()
	emit_signal("deck_ready")

# fungsi bikin deck angka
func create_number_deck():
	player_num_deck.clear()
	
	for i in range(5):
		player_num_deck.append(2)
		player_num_deck.append(3)
		player_num_deck.append(5)
		player_num_deck.append(7)
	
	player_num_deck.shuffle()

# fungsi bikin deck operator
func create_operator_deck():
	player_operator_deck.clear()
	for i in range(4): 
		player_operator_deck.append_array(["+", "*"])
	for i in range(1):
		player_operator_deck.append_array(["-", "/"])
	player_operator_deck.shuffle()

# eksekusi dua fungsi sebelumnya dalam satu fungsi
func create_decks():
	create_number_deck()
	create_operator_deck()

# fungsi untuk draw angka
func draw_number():
	if player_num_deck.size() == 0:
		reshuffle_number_deck()
	
	if player_num_deck.size() == 0:
		return null
	
	var val = player_num_deck.pop_front()
	deck_changed.emit()
	return val

# fungsi draw operator
func draw_operator():
	if player_operator_deck.size() == 0:
		reshuffle_operator_deck()
	
	if player_operator_deck.size() == 0:
		return null
	
	return player_operator_deck.pop_front()
	deck_changed.emit()

# fungsi reshuffle angka dan operator
func reshuffle_number_deck():
	player_num_deck = number_discard.duplicate()
	number_discard.clear()
	player_num_deck.shuffle()

func reshuffle_operator_deck():
	player_operator_deck = operator_discard.duplicate()
	operator_discard.clear()
	player_operator_deck.shuffle()

# nambahin kartu angka ke discard
func add_num_to_discard(value):
	number_discard.append(value)

# nambahin kartu operasi ke discard
func add_ops_to_discard(value):
	operator_discard.append(value)

func reset_deck_for_new_phase():
	number_discard.clear()
	operator_discard.clear()
	
	create_decks() 
	deck_changed.emit()
	print("Deck di-reset penuh untuk Phase baru!")

# buat nampilin deck, dipanggil dari deckviewer
func show_remaining_cards():
	if deck_viewer:
		deck_viewer.open_deck_viewer()
