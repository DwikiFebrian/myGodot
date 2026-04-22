extends Panel

@onready var phase_boxes = [
	$MarginContainer/VBoxContainer/HBoxContainer/PhaseBox1,
	$MarginContainer/VBoxContainer/HBoxContainer/PhaseBox2,
	$MarginContainer/VBoxContainer/HBoxContainer/PhaseBox3
]

@onready var order_title_label = $MarginContainer/VBoxContainer/TitleLabel

const ANIMATION_OFFSET = Vector2(0, 50)
const ANIMATION_DURATION = 0.5
const CASCADE_DELAY = 0.15

func _ready():
	self.hide()

func update_phase_presentation():
	var om = get_node_or_null("/root/Main/OrderManager")
	
	var current_order_idx = om.current_order
	var current_phase_idx = om.current_phase
	
	# ambil judul order
	order_title_label.text = om.get_current_order_name()
	
	# ambil array berisi 3 fase (Trial, Proof, Final Truth) dari order saat ini
	var phases_list = om.ORDERS[current_order_idx]["phase"]
	
	var tween = create_tween().set_parallel(true)
	
	for i in range(3):
		var box = phase_boxes[i]
		var phase_info = phases_list[i]

		var target_y = box.position.y
		box.position.y = target_y + ANIMATION_OFFSET.y
		box.modulate.a = 0.0 

		var name_label = box.find_child("NameLabel", true, false)
		var target_label = box.find_child("TargetLabel", true, false)
		var status_label = box.find_child("StatusLabel", true, false)
		
		if not name_label or not target_label or not status_label:
			print("ERROR: Ada label yang hilang di ", box.name)
			continue
			
		name_label.text = phase_info["name"]
		target_label.text = "Target: " + str(phase_info["target"])
		
		# logika pewarnaan status
		if i < current_phase_idx:
			status_label.text = "CLEARED"
			status_label.add_theme_color_override("font_color", Color.GREEN)
			box.self_modulate = Color(0.4, 0.4, 0.4)
		elif i == current_phase_idx:
			status_label.text = "NEXT ROUND"
			status_label.add_theme_color_override("font_color", Color.YELLOW)
			box.self_modulate = Color(1, 1, 1)
		else:
			status_label.text = "LOCKED"
			status_label.add_theme_color_override("font_color", Color.DARK_GRAY)
			box.self_modulate = Color(0.2, 0.2, 0.2)
			

		if phase_info.get("boss", false):
			name_label.add_theme_color_override("font_color", Color.RED)
		else:
			name_label.add_theme_color_override("font_color", Color.WHITE)

		# biar ada efek masuk satu-satu
		var delay = i * CASCADE_DELAY

		# masukkan animasi ke dalam satu tween utama
		tween.tween_property(box, "position:y", target_y, ANIMATION_DURATION)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)\
			.set_delay(delay)
			
		tween.tween_property(box, "modulate:a", 1.0, ANIMATION_DURATION)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)\
			.set_delay(delay)

# tombol begin
func _on_button_pressed() -> void:
	var tween = create_tween().set_parallel(true)

	tween.tween_property(self, "modulate:a", 0.0, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "position:y", position.y + 50, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	tween.set_parallel(false)
	tween.tween_callback(hide_and_unlock)

# nutup ui dan lanjutin main
func hide_and_unlock():
	self.hide()
	var cm = get_node_or_null("/root/Main/CardManager")
	if cm:
		cm.interaction_enabled = true
	var om = get_node_or_null("/root/Main/OrderManager")
	if om:
		om.is_transitioning = false
	var ph = get_node_or_null("/root/Main/PlayerHand")
	if ph:
		ph.refill_hand()

# nampilin phase
func show_presentation():
	self.modulate.a = 1.0
	self.position.y = 0 
	self.show()
	
	var ph = get_node_or_null("/root/Main/PlayerHand")
	if ph:
		ph.clear_all_cards()
	
	update_phase_presentation()
	
	var cm = get_node_or_null("/root/Main/CardManager")
	if cm:
		cm.interaction_enabled = false
