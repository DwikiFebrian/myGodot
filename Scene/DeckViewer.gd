extends Control

const CARD_UI = preload("res://Scene/CardUI.tscn")
@onready var deck = get_node("/root/Main/Deck")
@onready var card_list = $Panel/ScrollContainer/GridContainer

func _ready() -> void:
	$Panel/Button.pressed.connect(_on_button_pressed)
	deck.deck_changed.connect(_on_deck_changed)
	visible = false

func show_cards(number_cards, operator_cards):
	clear_cards()

	var sorted_nums = number_cards.duplicate()
	var sorted_ops = operator_cards.duplicate()

	sorted_nums.sort()
	sorted_ops.sort() 

	for c in sorted_nums:
		add_card(c, "num")

	for c in sorted_ops:
		add_card(c, "ops")

func open_deck_viewer():
	show_cards(deck.player_num_deck, deck.player_operator_deck)
	visible = true

func add_card(value, type):
	var card = CARD_UI.instantiate()
	card_list.add_child(card)
	card.set_value(value)

	if type == "ops":
		card.modulate = Color(0.8, 0.9, 1)

func clear_cards():
	for child in card_list.get_children():
		child.queue_free()

func _on_button_pressed() -> void:
	visible = false

func _on_deck_changed():
	show_cards(deck.player_num_deck, deck.player_operator_deck)
