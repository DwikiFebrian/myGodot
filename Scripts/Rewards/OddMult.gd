extends Variant 
class_name OddMult

func _init():
	nama_variant = "Odd Mult"
	deskripsi = "+0.5 Mult for Odd Numbers"
	icon = preload("res://grafik/oddmult.png")

func apply_effect(ctx):
	for card in ctx.cards:
		if card.card_type == "number" and int(card.value) % 2 != 0:
			ctx.mult += 0.5
