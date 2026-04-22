extends CanvasLayer

const REWARD_SCENE = preload("res://Scene/RewardItem.tscn")

# masukin variant baru ke sini
var variant_pool = [
	EvenPrime, OddMult, LuckySeven, TwoforTwo, 
	ThreeforThree, FiveforFive, SevenforSeven, PlusDisaster
]

# masukin scrol ke sini
var scroll_pool = [
	preload("res://Resource/Scroll/scroll_3.tres"), 
	preload("res://Resource/Scroll/scroll_plus.tres"),
	preload("res://Resource/Scroll/scroll_2.tres")
]

# mau munculin berapa reward (harus ubah juga di hbox kayaknya)
var num_base_rewards = 3
@onready var container = $HBoxContainer 
var is_processing_selection = false

func _ready():
	get_node("../OrderManager").reward_needed.connect(show_reward_options)
	self.hide()

# nampilin dari reward
func show_reward_options():
	is_processing_selection = false
	self.show()
	for child in container.get_children(): child.queue_free()
	
	# tempat buat habungin scroll dan variant
	var filtered_pool = []
	var rules = get_node("../OrderManager")
	
	for joker_class in variant_pool:
		var in_pocket = false
		for active_joker in rules.active_variants:
			if active_joker.get_script() == joker_class:
				in_pocket = true
				break
		if not in_pocket: filtered_pool.append(joker_class)
			
	if rules.inventory_scroll.size() < rules.max_scroll_slot:
		var random_scroll = scroll_pool.pick_random()
		filtered_pool.append(random_scroll)
	
	if filtered_pool.size() == 0:
		self.hide()
		rules.emit_signal("phase_changed")
		return
	
	filtered_pool.shuffle()
	# kondisi kalau misal poolnya dah mau abis (buat tahap pengembangan doang)
	var jumlah_tampil = min(num_base_rewards, filtered_pool.size())
	
	for i in range(jumlah_tampil):
		var item_data
		if filtered_pool[i] is Script: 
			item_data = filtered_pool[i].new()
		elif filtered_pool[i] is Scroll: 
			item_data = filtered_pool[i].duplicate()    
		
		var reward_node = REWARD_SCENE.instantiate()
		reward_node.setup(item_data)
		reward_node.connect("selected", _on_item_selected, CONNECT_ONE_SHOT)
		
		await get_tree().create_timer(i * 0.1).timeout
		container.add_child(reward_node)
		
		reward_node.scale = Vector2(0.8, 0.8)
		reward_node.modulate.a = 0.0
		reward_node.position.y += 30 
		var tween = create_tween().set_parallel(true)
		tween.tween_property(reward_node, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(reward_node, "modulate:a", 1.0, 0.25)
		tween.tween_property(reward_node, "position:y", reward_node.position.y - 30, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

# fungsi sehabis milih reward, nanti dipisahin lokasinya
func _on_item_selected(chosen_item):
	if is_processing_selection: return
	is_processing_selection = true
	
	var rules = get_node("../OrderManager")
	
	if "nama_variant" in chosen_item: 
		rules.add_variant(chosen_item)
	elif "scroll_name" in chosen_item: 
		rules.add_scroll(chosen_item)
	
	var chosen_node = null
	for child in container.get_children():
		if child.item_data == chosen_item:
			chosen_node = child
			break
			
	for child in container.get_children():
		var tween = create_tween().set_parallel(true)
		if child == chosen_node:
			tween.tween_property(child, "scale", Vector2(1.3, 1.3), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(child, "position:y", child.position.y - 50, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		else:
			tween.tween_property(child, "scale", Vector2(0.6, 0.6), 0.25)
			tween.tween_property(child, "modulate:a", 0.0, 0.25)
			tween.tween_property(child, "position:y", child.position.y + 80, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	await get_tree().create_timer(0.35).timeout
	self.hide()
	rules.emit_signal("phase_changed")
