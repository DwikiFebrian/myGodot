extends Control

@onready var label = $Panel/Label

var value

func set_value(v):
	value = v
	label.text = str(v)
