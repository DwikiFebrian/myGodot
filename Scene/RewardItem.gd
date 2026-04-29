extends Button

signal selected(item_data)
var item_data 

# bikin referensi ke wrapper-nya
@onready var visual_wrapper = $VisualWrapper

func _ready():
	self.pressed.connect(_on_button_diklik)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	visual_wrapper.pivot_offset = self.custom_minimum_size / 2.0

func setup(item):
	item_data = item
	
	var vbox = $VisualWrapper/VBoxContainer
	
	# cek apakah dia punya variabel "nama_variant"
	if "nama_variant" in item: 
		vbox.get_node("TextureRect").texture = item.icon
		vbox.get_node("Label").text = item.nama_variant
		vbox.get_node("LabelDesk").text = item.deskripsi
		vbox.get_node("LabelPrice").text = "Price: " + str(item.price)
		
	# cek apakah dia punya variabel "scroll_name"
	elif "scroll_name" in item: 
		vbox.get_node("TextureRect").texture = item.icon
		vbox.get_node("Label").text = item.scroll_name
		vbox.get_node("LabelDesk").text = item.description
		vbox.get_node("LabelPrice").text = "Price: " + str(item.price)

# fungsi cek harga
func check_affordability(player_money):
	var is_affordable = player_money >= item_data.price
	
	# disable tombol kalau nggak kebeli
	self.disabled = not is_affordable
	
	var price_label = $VisualWrapper/VBoxContainer/LabelPrice
	
	if is_affordable:
		# warna normal kalau bisa beli
		price_label.add_theme_color_override("font_color", Color.WHITE)
		visual_wrapper.modulate = Color(1, 1, 1, 1) 
	else:
		# warna merah dan agak gelap kalau miskin
		price_label.add_theme_color_override("font_color", Color.RED)
		visual_wrapper.modulate = Color(0.5, 0.5, 0.5, 1)

func _on_button_diklik():
	emit_signal("selected", item_data)

func _on_mouse_entered():
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(visual_wrapper, "scale", Vector2(1.08, 1.08), 0.12)

func _on_mouse_exited():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(visual_wrapper, "scale", Vector2(1, 1), 0.1)
