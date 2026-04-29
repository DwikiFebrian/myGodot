extends Variant 
class_name ThreeforThree

func _init():
	nama_variant = "Three for Three"
	deskripsi = "+3 Score for using 3"
	icon = preload("res://grafik/3for3.png")
	price = 6

func apply_effect(ctx):
	for card in ctx.cards:
		if card.card_type == "number" and int(card.value) == 3:
			ctx.base += 3
