extends Resource
class_name Variant

@export var nama_variant: String = "Base Variant"
@export var deskripsi: String = "Tidak efek apa-apa"
@export var icon: Texture2D
@export var price: int = 0

# Fungsi ini yang bakal dimodif sama tiap-tiap Variant
func apply_effect(ctx):
	pass
