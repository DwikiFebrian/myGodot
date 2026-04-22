extends CanvasLayer 

const SCROLL_BTN_SCENE = preload("res://Scene/ScrollHUDButton.tscn") 

@onready var order_manager = get_node("/root/Main/OrderManager")
@onready var slot_label = $SlotLabel
	
func _ready():
	order_manager.connect("scroll_baru_ditambahkan", _on_scroll_masuk_tas)
	order_manager.connect("scroll_dihapus", _on_scroll_keluar_tas)
	update_slot_label()

func _on_scroll_masuk_tas(new_scroll: Scroll):
	var btn = SCROLL_BTN_SCENE.instantiate()
	
	$HBoxContainer.add_child(btn) 
	btn.setup(new_scroll)
	btn.scale = Vector2(0.1, 0.1)
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", Vector2(1, 1), 0.3)
	
	update_slot_label()

# update label sisa slot
func update_slot_label():
	var current = order_manager.inventory_scroll.size()
	var max = order_manager.max_scroll_slot
	slot_label.text = str(current) + " / " + str(max)

func _on_scroll_keluar_tas(scroll):
	update_slot_label()
