extends Variant 
class_name TwoforTwo

func _init():
	nama_variant = "Two for Two"
	deskripsi = "+2 Score for using 2"
	icon = preload("res://grafik/2for2.png")
	price = 5

func apply_effect(ctx):
	for card in ctx.cards:
		if card.card_type == "number" and int(card.value) == 2:
			ctx.base += 2
