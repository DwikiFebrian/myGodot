extends Button
signal selected(item_data)
var item_data 

func _ready():
	self.pressed.connect(_on_button_diklik)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(item):
	item_data = item
	
	# cek apakah dia punya variabel "nama_variant"
	if "nama_variant" in item: 
		$VBoxContainer/TextureRect.texture = item.icon
		$VBoxContainer/Label.text = item.nama_variant
		$VBoxContainer/LabelDesk.text = item.deskripsi
		
	# cek apakah dia punya variabel "scroll_name"
	elif "scroll_name" in item: 
		$VBoxContainer/TextureRect.texture = item.icon
		$VBoxContainer/Label.text = item.scroll_name
		$VBoxContainer/LabelDesk.text = item.description

func _on_button_diklik():
	emit_signal("selected", item_data)

func _on_mouse_entered():
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12)

func _on_mouse_exited():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
