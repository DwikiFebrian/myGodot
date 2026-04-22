extends Button

var data_scroll: Scroll
@onready var tombol_use = get_tree().get_root().find_child("Scroll", true, false)

func _ready():
	self.pressed.connect(_on_logo_pressed)

func setup(scroll_baru: Scroll):
	data_scroll = scroll_baru
	
	self.icon = data_scroll.icon 
	
	# bikin tooltip hover
	self.tooltip_text = data_scroll.scroll_name + "\n" + data_scroll.description

# kalau logo scroll dipencet, use bisa dipake
func _on_logo_pressed():
	if is_instance_valid(tombol_use):
		tombol_use.aktifkan_scroll(data_scroll, self)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
