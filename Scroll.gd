extends Resource
class_name Scroll

@export var scroll_name: String = "Base Scroll"
@export var description: String = "Mengubah identitas kartu"
@export var icon: Texture2D

@export_enum("number", "operator") var target_type: String = "number"
@export var target_value: Variant 

func apply_to_card(target_card: Node2D) -> bool:
	if target_card.has_method("transform_card"):
		target_card.transform_card(target_type, target_value)
		return true
	return false
