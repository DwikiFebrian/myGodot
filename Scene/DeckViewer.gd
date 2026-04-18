extends Control

const CARD_UI = preload("res://Scene/CardUI.tscn")
@onready var deck = get_node("/root/Main/Deck")
@onready var card_list = $Panel/ScrollContainer/GridContainer

var panel_tween: Tween
var card_tween: Tween

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
	
	await get_tree().process_frame
	animate_cards()

func open_deck_viewer():
	visible = true
	
	if panel_tween and panel_tween.is_valid():
		panel_tween.kill()
	panel_tween = create_tween()
	panel_tween.tween_property(self, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE)
	
	show_cards(deck.player_num_deck, deck.player_operator_deck)

func add_card(value, type):
	var card = CARD_UI.instantiate()
	card_list.add_child(card)
	card.set_value(value)

	card.scale = Vector2.ZERO
	card.modulate.a = 0.0

	if type == "ops":
		card.modulate = Color(0.9, 0.9, 1, 0.0)

func animate_cards():
	if card_tween and card_tween.is_valid():
		card_tween.kill()
	card_tween = create_tween()

	var delay = 0.0
	for card in card_list.get_children():
		card.pivot_offset = Vector2(90, 120) 

		var target_a = 1.0
		
		card_tween.parallel().tween_property(card, "scale", Vector2.ONE, 0.3).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_tween.parallel().tween_property(card, "modulate:a", target_a, 0.2).set_delay(delay)
		
		delay += 0.03
		
func clear_cards():
	for child in card_list.get_children():
		child.queue_free()

func _on_button_pressed() -> void:
	if panel_tween and panel_tween.is_valid():
		panel_tween.kill()
	panel_tween = create_tween()
	panel_tween.tween_property(self, "modulate:a", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
	
	panel_tween.tween_callback(func(): visible = false)

func _on_deck_changed():
	if visible:
		show_cards(deck.player_num_deck, deck.player_operator_deck)
