class_name PropertyField
extends HBoxContainer

const numerical_property : PackedScene = preload("res://ui/properties/numerical_property.tscn")
const text_property : PackedScene = preload("res://ui/properties/text_property.tscn")
const toggle_property : PackedScene = preload("res://ui/properties/toggle_property.tscn")

func initialize(property_value : PropertyValue, block):
	var value_field : ValueField
	match property_value.type:
		PropertyValue.Type.NUMBER: value_field = numerical_property.instantiate()
		PropertyValue.Type.TEXT: value_field = text_property.instantiate()
		PropertyValue.Type.TOGGLE: value_field = toggle_property.instantiate()
	
	value_field.initialize(property_value)
	#value_field.connect("property_changed", block._property_changed)
	
	($Name as Label).text = property_value.name
	$ValueContainer.add_child(value_field)
