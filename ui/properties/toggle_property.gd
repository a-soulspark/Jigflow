class_name ToggleProperty
extends ValueField

func _property_changed(property : PropertyValue):
	($Toggle as CheckButton).button_pressed = property.value

func _on_toggle_toggled(button_pressed: bool) -> void:
	value = button_pressed
