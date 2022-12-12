extends GridContainer

signal block_selected(block : Block)

var selected_button : Button

func _ready() -> void:
	_on_button_pressed(get_child(0))
	
	for b in get_children():
		b.connect("pressed", _on_button_pressed.bind(b))

func _on_button_pressed(button : Button):
	selected_button = button
	queue_redraw()
	
	block_selected.emit(button.block_scene)

func _draw() -> void:
	if selected_button:
		draw_rect(Rect2(selected_button.position, selected_button.size), Color.ANTIQUE_WHITE, false, 2)
