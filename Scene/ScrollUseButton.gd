extends Button

var selected_scroll_data: Scroll = null
var selected_logo_node: Button = null

@onready var card_manager = get_tree().get_root().find_child("CardManager", true, false)
@onready var order_manager = get_tree().get_root().find_child("OrderManager", true, false)

func _ready():
	
	self.pressed.connect(_on_use_pressed)
	
	if card_manager != null:
		card_manager.connect("scroll_used", _on_scroll_resolved)
		
	self.disabled = true 

func aktifkan_scroll(scroll_data: Scroll, logo_node: Button):
	if selected_scroll_data == scroll_data:
		cancel_scroll_selection()
		return
	
	selected_scroll_data = scroll_data
	selected_logo_node = logo_node
	
	self.disabled = false 
	self.text = "USE " + scroll_data.scroll_name.to_upper()

func _on_use_pressed():
	if selected_scroll_data != null and card_manager != null:
		card_manager.activate_scroll_targeting(selected_scroll_data)
		self.modulate = Color(0.5, 1.5, 0.5) 

# fungsi handler setelah use
func _on_scroll_resolved(berhasil: bool):
	self.modulate = Color(1, 1, 1)
	
	if berhasil and selected_scroll_data != null:
		order_manager.consume_scroll(selected_scroll_data)
		
		if is_instance_valid(selected_logo_node):
			selected_logo_node.queue_free()
		
	selected_scroll_data = null
	selected_logo_node = null
	self.disabled = true
	self.text = "Use"

func cancel_scroll_selection():
	selected_scroll_data = null
	selected_logo_node = null
	self.disabled = true
	self.text = "Use"
	self.modulate = Color(1, 1, 1)
