extends Panel

@export
var property_scene : PackedScene
@export
var port_field_scene : PackedScene
var property_map

@onready
var properties_list = $ScrollContainer/Properties as Control

func _on_grid_chart_block_selected(block : Block) -> void:
	for p in properties_list.get_children(): p.queue_free()
	
	if not block:
		$Toolbar.hide()
		return
	
	$Toolbar.show()
	
	var port_field = port_field_scene.instantiate() as PortField
	port_field.initialize(block)
	properties_list.add_child(port_field)
	
	for p in block.properties:
		var property = block.properties[p]
		var new_field = property_scene.instantiate() as PropertyField
		new_field.initialize(property, block)
		properties_list.add_child(new_field)
