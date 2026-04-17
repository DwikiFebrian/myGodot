extends Variant 
class_name EvenPrime

func _init():
	nama_variant = "Evens Prime"
	deskripsi = "+5 Base Score untuk tiap angka genap"
	icon = preload("res://grafik/evenprime.png")

func apply_effect(ctx):
	for card in ctx.cards:
		if card.card_type == "number" and int(card.value) % 2 == 0:
			ctx.base += 5
