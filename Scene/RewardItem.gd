extends Button
signal selected(variant_data)
var variant_data

func _ready():
	self.pressed.connect(_on_button_diklik)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(variant):
	variant_data = variant
	$VBoxContainer/TextureRect.texture = variant.icon
	$VBoxContainer/Label.text = variant.nama_variant
	$VBoxContainer/LabelDesk.text = variant.deskripsi

func _on_button_diklik():
	emit_signal("selected", variant_data)

func _on_mouse_entered():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12)

func _on_mouse_exited():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
