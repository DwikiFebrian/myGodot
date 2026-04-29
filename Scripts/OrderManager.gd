extends Node

var total_score = 0
var current_order = 0
var current_phase = 0

var money = 0
signal money_changed(new_amount)

var variants = []
var inventory_scroll: Array[Scroll] = []

# jumlah bag untuk slot
var max_scroll_slot: int = 4

var active_variants: Array[Variant] = [] 
var is_transitioning = false

signal scroll_dihapus(scroll_data)
signal game_won
signal game_over
signal phase_changed
signal reward_needed
signal variant_baru_ditambahkan(variant_data)
signal scroll_baru_ditambahkan(scroll_data)

func _ready():
	pass

var ORDERS = [
	{
		"name":"The First Order",
		"phase":[
			{"name":"Trial", "target":40, "galat":12, "interval":[12,36], "boss":false},
			{"name":"Proof", "target":80, "galat":10, "interval":[14,34], "boss":false},
			{"name":"Final Truth", "target":120, "galat":8, "interval":[16,32], "boss":true}
		]
	},
	
	{
		"name":"The Reminiscence",
		"phase":[
			{"name":"Trial", "target":160, "galat":10, "interval":[14,34], "boss":false},
			{"name":"Proof", "target":280, "galat":8, "interval":[16,32], "boss":false},
			{"name":"Final Truth", "target":260, "galat":6, "interval":[18,30], "boss":true}
		]
	},
	
	{
		"name":"The Hollow",
		"phase":[
			{"name":"Trial", "target":400, "galat":8, "interval":[16,32], "boss":false},
			{"name":"Proof", "target":600, "galat":6, "interval":[18,30], "boss":false},
			{"name":"Final Truth", "target":850, "galat":4, "interval":[20,28], "boss":true}
		]
	},
	
		{
		"name":"The Resistance",
		"phase":[
			{"name":"Trial", "target":1400, "galat":8, "interval":[16,32], "boss":false},
			{"name":"Proof", "target":2200, "galat":6, "interval":[18,30], "boss":false},
			{"name":"Final Truth", "target":3500, "galat":4, "interval":[20,28], "boss":true}
		]
	},
	
		{
		"name":"The Pinnacle",
		"phase":[
			{"name":"Trial", "target":6000, "galat":8, "interval":[16,32], "boss":false},
			{"name":"Proof", "target":10000, "galat":6, "interval":[18,30], "boss":false},
			{"name":"Final Truth", "target":24000, "galat":4, "interval":[20,28], "boss":true}
		]
	}
]

func is_valid_score(result):
	var phase = get_current_phase()
	var galat = phase["galat"]
	
	return abs(result - 24) <= galat

# fungsi buat increment phase
func next_phase():
	
	is_transitioning = true
	
	var board = get_node("../CardPlacement")
	if board.has_method("player_money"):
		board.player_money()
	
	current_phase += 1
	
	if current_phase >= ORDERS[current_order]["phase"].size():
		current_phase = 0
		current_order += 1
		
		# kondisi tamat
		if current_order >= ORDERS.size():
			current_order = ORDERS.size() - 1
			emit_signal("game_won")
			return
			
	emit_signal("reward_needed")
	#emit_signal("phase_changed")

# reset game
func reset_run():
	total_score = 0
	current_order = 0
	current_phase = 0
	
	# hapus semua variant/variant yang terkumpul
	active_variants.clear() 
	
	# emit signal supaya UI score dan phase terupdate ke awal
	emit_signal("phase_changed") 

# fungsi numbah duit player
func add_money(amount: int):
	money += amount
	emit_signal("money_changed", money)
	print("Uang bertambah! Total sekarang: ", money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		emit_signal("money_changed", money)
		return true
	
	return false

# nambah varint
func add_variant(new_variant: Variant):
	active_variants.append(new_variant)
	print("Variant baru aktif: ", new_variant.nama_variant)
	
	emit_signal("variant_baru_ditambahkan", new_variant)

# ngambil phase sekarang
func get_current_phase():
	return ORDERS[current_order]["phase"][current_phase]

# ngambil nama order
func get_current_order_name():
	if current_order < ORDERS.size():
		return ORDERS[current_order]["name"]
	return "Unknown Order"

# jumlahin score
func add_score(value):
	total_score += value

# fungsi penalty
func calculate_penalty():
	var phase = get_current_phase()
	return int(phase["target"] * 0.20)

# fungsi hitung score akhir
func process_result(cards, result):
	if is_valid_score(result):
		var score = calculate_score(cards, result)
		add_score(score)
		check_phase_progress()
		return {"success": true, "value": score}
	else:
		var penalty = calculate_penalty()
		total_score -= penalty
		
		# biar ga minus terlalu brutal
		#total_score = max(0, total_score)
		
		return {"success": false, "value": penalty}

func calculate_score(cards, result):
	var ctx = {
		"base": 0,
		"mult": 1.0,
		"result": result,
		"cards": cards
	}
	
	apply_card_base(ctx)
	apply_operator_mult(ctx)
	apply_proximity(ctx)
	# variant effect
	apply_variants(ctx)
	
	return int(ctx.base * ctx.mult)

# ngatur score kartu angka
func apply_card_base(ctx):
	for card in ctx.cards:
		if card.card_type == "number":
			ctx.base += card.value

# ngatus base mult kartu operator
func apply_operator_mult(ctx):
	for card in ctx.cards:
		if card.card_type == "operator":
			match str(card.value):
				"+": ctx.mult += 0.4
				"*": ctx.mult += 0.6
				"-": ctx.mult += 0.8
				"/": ctx.mult += 1.0

# ngitung seberapa presisi terhadap 24
func apply_proximity(ctx):
	var diff = abs(ctx.result - 24)
	var proximity = max(0.0, 1.0 - (diff * 0.05))
	ctx.mult *= proximity

# aktifin efek dari variant
func apply_variants(ctx):
	for variant in active_variants:
		variant.apply_effect(ctx)

# cek kondisi apakah dah bisa naik phase
func check_phase_progress():
	var phase = get_current_phase()
	
	if total_score >= phase["target"]:
		next_phase()

# nambahin scroll
func add_scroll(new_scroll: Scroll):
	if inventory_scroll.size() < max_scroll_slot:
		inventory_scroll.append(new_scroll)
		emit_signal("scroll_baru_ditambahkan", new_scroll)
	else:
		print("Inventory Scroll Penuh!")

# fungsi pakai scroll
func consume_scroll(used_scroll: Scroll):
	if used_scroll in inventory_scroll:
		inventory_scroll.erase(used_scroll)
		emit_signal("scroll_dihapus", used_scroll)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
