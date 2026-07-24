extends CanvasLayer

const REWARD_SCENE = preload("res://Scene/RewardItem.tscn")

# daftar semua variant
var master_pool = [
	EvenPrime,
	OddMult,
	LuckySeven,
	TwoforTwo,
	ThreeforThree,
	FiveforFive,
	SevenforSeven,
	PlusDisaster
]

var num_base_rewards = 3
@onready var container = $HBoxContainer 
var is_processing_selection = false

func _ready():
	get_node("../OrderManager").reward_needed.connect(show_reward_options)
	self.hide()

func show_reward_options():
	is_processing_selection = false
	self.show()
	
	for child in container.get_children():
		child.queue_free()
	
	var filtered_pool = []
	var rules = get_node("../OrderManager")
	
	for joker_class in master_pool:
		var in_pocket = false
		
		# cek ke dalam OrderManager
		for active_joker in rules.active_variants:
			# bandingin joker yang sama
			if active_joker.get_script() == joker_class:
				in_pocket = true
				break
		
		# jika belum punya, masukkan ke daftar yang boleh muncul
		if not in_pocket:
			filtered_pool.append(joker_class)
	
	# kondisi kalo variant dah dipake semua
	if filtered_pool.size() == 0:
		print("Semua Joker sudah dimiliki!")
		self.hide()
		rules.next_phase() 
		return
	
	# suffle sisa
	filtered_pool.shuffle()
	
	var jumlah_tampil = min(num_base_rewards, filtered_pool.size())
	
	for i in range(jumlah_tampil):
		var v = filtered_pool[i].new()
		
		var reward_node = REWARD_SCENE.instantiate()
		reward_node.setup(v)
		reward_node.connect("selected", _on_variant_selected, CONNECT_ONE_SHOT)
		
		await get_tree().create_timer(i * 0.1).timeout
		container.add_child(reward_node)
		
		reward_node.scale = Vector2(0.8, 0.8)
		reward_node.modulate.a = 0.0
		reward_node.position.y += 30  # mulai agak bawah

		var tween = create_tween()
		tween.set_parallel(true)

		tween.tween_property(reward_node, "scale", Vector2(1, 1), 0.3)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)

		tween.tween_property(reward_node, "modulate:a", 1.0, 0.25)

		tween.tween_property(reward_node, "position:y", reward_node.position.y - 30, 0.3)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)

func _on_variant_selected(chosen_variant: Variant):
	if is_processing_selection: return
	is_processing_selection = true
	
	get_node("../OrderManager").add_variant(chosen_variant)
	
	var chosen_node = null
	
	# cari node yang dipilih
	for child in container.get_children():
		if child.variant_data == chosen_variant:
			chosen_node = child
			break
	
	# animasi semua node
	for child in container.get_children():
		var tween = create_tween()
		tween.set_parallel(true)
		
		if child == chosen_node:
			tween.tween_property(child, "scale", Vector2(1.3, 1.3), 0.3)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)
			
			tween.tween_property(child, "position:y", child.position.y - 50, 0.3)\
				.set_trans(Tween.TRANS_CUBIC)\
				.set_ease(Tween.EASE_OUT)
			
		else:
			tween.tween_property(child, "scale", Vector2(0.6, 0.6), 0.25)
			tween.tween_property(child, "modulate:a", 0.0, 0.25)
			tween.tween_property(child, "position:y", child.position.y + 80, 0.25)\
				.set_trans(Tween.TRANS_CUBIC)\
				.set_ease(Tween.EASE_IN)

	await get_tree().create_timer(0.35).timeout
	
	self.hide()

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12)

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
