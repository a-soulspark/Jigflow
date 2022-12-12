class_name NumericalProperty
extends ValueField

var detecting_changes = true

func _property_changed(property : PropertyValue):
	if detecting_changes:
		($Number as LineEdit).text = str(value)

func _on_number_text_changed(new_text: String) -> void:
	if float(new_text) != 0 or new_text.is_valid_float():
		detecting_changes = false
		value = float(new_text)
		detecting_changes = true
