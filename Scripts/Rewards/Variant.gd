extends Resource
class_name Variant

@export var nama_variant: String = "Base Variant"
@export var deskripsi: String = "Tidak efek apa-apa"
@export var icon: Texture2D

# Fungsi ini yang bakal dimodif sama tiap-tiap Variant
func apply_effect(ctx):
	pass
