class_name ValueField
extends Panel

var property : PropertyValue
var value :
	set(new_value):
		property.set_value(new_value)
	get:
		return property.value

func initialize(property : PropertyValue) -> void:
	self.property = property
	property.connect("property_changed", _property_changed)
	_property_changed(property)

func _property_changed(property : PropertyValue):
	pass
