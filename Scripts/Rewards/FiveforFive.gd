extends Variant 
class_name FiveforFive

func _init():
	nama_variant = "Five for Five"
	deskripsi = "+5 Score for using 5"
	icon = preload("res://grafik/5for5.png")
	price = 7

func apply_effect(ctx):
	for card in ctx.cards:
		if card.card_type == "number" and int(card.value) == 5:
			ctx.base += 5
