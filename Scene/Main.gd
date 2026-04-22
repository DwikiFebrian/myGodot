extends Node2D

@onready var active_variant_placed = $ActiveVariantContainer

@onready var game_over_panel = $CanvasLayer2/GameOverPanel
@onready var game_won_panel = $CanvasLayer2/GameWonPanel
@onready var submit_button = $HBoxContainer/SubmitButton   
@onready var craft_button = $HBoxContainer/CraftButton    
@onready var phase_presentation_ui = $PhasePresentation/Panel

# siapin yang dibutuhin game (kebanyakan UI)
func _ready() -> void:
	var orderrule = $OrderManager 
	if orderrule:
		orderrule.variant_baru_ditambahkan.connect(display_icon_variant) 
		
		orderrule.game_won.connect(_on_game_won)
		orderrule.game_over.connect(_on_game_over)
		orderrule.phase_changed.connect(_on_phase_changed)

	if game_over_panel:
		game_over_panel.hide()
	if game_won_panel:
		game_won_panel.hide()
	if phase_presentation_ui:
		phase_presentation_ui.show_presentation()

# fungsi atur ui tiap variant
func display_icon_variant(variant_data: Variant):
	var icon_baru = TextureRect.new()

	icon_baru.texture = variant_data.icon
	
	icon_baru.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_baru.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_baru.custom_minimum_size = Vector2(80, 80)
	
	icon_baru.tooltip_text = variant_data.nama_variant + "\n" + variant_data.deskripsi
	
	active_variant_placed.add_child(icon_baru)

func _process(delta: float) -> void:
	pass

# fungsi pas tombol "Submit" diklik pemain
func _on_submit_button_pressed() -> void:
	$CardPlacement.submit_placed_cards()

# fungsi pas tombol "Craft" diklik pemain
func _on_craft_button_pressed() -> void:
	$CardPlacement.craft_cards()

# fungsi ui kalo dah menang
func _on_game_won() -> void:
	print("Menjalankan UI Menang!")
	# tampilin layar menang
	if game_won_panel:
		game_won_panel.show()
	
	# matiin interaksi tombol agar pemain tidak bisa submit lagi
	if submit_button: submit_button.disabled = true
	if craft_button: craft_button.disabled = true

# fungsi ui kalo kalah
func _on_game_over() -> void:
	print("Menjalankan UI Kalah!")
	# Tampilkan layar game over
	if game_over_panel:
		game_over_panel.show()
	
	# Matikan interaksi tombol agar pemain tidak bisa submit lagi
	if submit_button: submit_button.disabled = true
	if craft_button: craft_button.disabled = true

# fungsi kalo phase berubah
func _on_phase_changed() -> void:
	if phase_presentation_ui:
		print("Fase Berganti! Memunculkan layar info fase...")
		phase_presentation_ui.show_presentation()
		
#TODO func _on_restart_button_pressed() -> void:
	## Sembunyikan kembali UI
	#if game_over_panel: game_over_panel.hide()
	#if game_won_panel: game_won_panel.hide()
	#
	## Nyalakan kembali tombol (akan otomatis diatur oleh update_all_ui nanti)
	#if submit_button: submit_button.disabled = false
	#if craft_button: craft_button.disabled = false
	#
	## Reset game via OrderManager
	#$OrderManager.reset_run()
	#
	## Hapus ikon varian yang lama dari UI
	#for child in active_variant_placed.get_children():
		#child.queue_free()
		#
	## Panggil reset deck (sesuaikan dengan caramu mereset deck/hand)
	#$Deck.reset_deck_for_new_phase()
	#$CardPlacement.update_all_ui()
