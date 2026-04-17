extends Variant 
class_name LuckySeven

func _init():
	nama_variant = "Lucky Seven"
	deskripsi = "+0.5 Score for Using 7"
	icon = preload("res://grafik/luckyseven.png")

func apply_effect(ctx):
	for card in ctx.cards:
		if card.card_type == "number" and int(card.value) == 7:
			ctx.base += 0.5
