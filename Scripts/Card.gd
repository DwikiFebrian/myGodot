extends Node2D

signal hovered
signal hovered_off

var starting_position
var current_slot = null
var in_hand = true
var saved_hand_index = 0
var card_type
var value = ""
var is_selected: bool = false

@onready var label = $Area2D/Label

# fungsi buat inisiasi di awal
func _ready() -> void:
	get_parent().connect_card_signals(self)
	update_visual()

func toggle_selection():
	is_selected = !is_selected

# hovered buat efek ketika mouse di atas card
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)

# assign value ke kartu
func set_value(v):
	value = v
	update_visual()

# update visual kartu pakai value
func update_visual():
	$Area2D/Label.text = str(value)

# fungsi buat ngubah kartu (dipake di scroll)
func transform_card(new_type: String, new_value) -> void: 
	card_type = new_type
	set_value(new_value)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
