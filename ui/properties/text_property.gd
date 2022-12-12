class_name TextProperty
extends ValueField

var detecting_changes = true

func _property_changed(property : PropertyValue):
	if detecting_changes:
		($Text as LineEdit).text = str(value)

func _on_text_changed(new_text: String) -> void:
	detecting_changes = false
	value = new_text
	detecting_changes = true
