extends Variant 
class_name SevenforSeven

func _init():
	nama_variant = "Seven for Seven"
	deskripsi = "+7 Score for using 7"
	icon = preload("res://grafik/7for7.png")
	price = 8

func apply_effect(ctx):
	for card in ctx.cards:
		if card.card_type == "number" and int(card.value) == 7:
			ctx.base += 7
