extends Variant 
class_name PlusDisaster

func _init():
	nama_variant = "Plus Disaster"
	deskripsi = "+0.5 Mult for using +"
	icon = preload("res://grafik/plusdisaster.png")
	price = 8

func apply_effect(ctx):
	for card in ctx.cards:
		if card.card_type == "operator" and str(card.value) == "+":
			ctx.mult += 0.5
