extends Node2D

signal block_selected(block : Block)

const CELL_SIZE_PX = 64
const CELL_SIZE = Vector2.ONE * CELL_SIZE_PX
const GRID_SIZE = Vector2(30, 30)
const GRID_RECT = Rect2i(0, 0, GRID_SIZE.x, GRID_SIZE.y)

@export
var block_to_place : PackedScene

var grid : Array = []
var selected_block : Block

var draw_overlay_enabled = false

const BLOCK_TYPE_MAP = {
	&"NumberBlock": preload("res://blocks/number_block.tscn"),
	&"MathBlock": preload("res://blocks/math_block.tscn"),
	&"LinkBlock": preload("res://blocks/link_block.tscn"),
	&"ButtonBlock": preload("res://blocks/button_block.tscn"),
	&"ConditionBlock": preload("res://blocks/condition_block.tscn"),
}

func _ready() -> void:
	initialize_grid()
	select_block(null)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_copy"):
		draw_overlay_enabled = not draw_overlay_enabled
		queue_redraw()


func initialize_grid() -> void:
	for i in range(GRID_SIZE.y):
		var row = []
		row.resize(GRID_SIZE.x)
		grid.append(row)


func get_block_at(position : Vector2i) -> Block:
	if GRID_RECT.has_point(position): return grid[position.y][position.x]
	return null


func set_block_at(position : Vector2i, block : Block) -> void:
	var update_neighbour = func(direction):
		var neighbour = get_block_at(position + Enums.vector(direction))
		if neighbour:
			neighbour.update_neighbour(Enums.flip(direction), block)
			if block: block.update_neighbour(direction, neighbour)
	
	grid[position.y][position.x] = block
	update_neighbour.call(Enums.Direction.TOP)
	update_neighbour.call(Enums.Direction.LEFT)
	update_neighbour.call(Enums.Direction.BOTTOM)
	update_neighbour.call(Enums.Direction.RIGHT)


func _draw() -> void:
	z_index = -1
	
	for x in range(GRID_SIZE.x + 1):
		draw_line(Vector2(x, 0) * CELL_SIZE, Vector2(x, GRID_SIZE.y) * CELL_SIZE, Color.BLACK * 0.4, 1)
	for y in range(GRID_SIZE.y + 1):
		draw_line(Vector2(0, y) * CELL_SIZE, Vector2(GRID_SIZE.x, y) * CELL_SIZE, Color.BLACK * 0.4, 1)
	
	draw_rect(Rect2(Vector2.ZERO, GRID_SIZE * CELL_SIZE), Color.BLACK, false, 1)
	
	if selected_block:
		draw_rect(Rect2(selected_block.position + Vector2(2, 2), CELL_SIZE -  + Vector2(4, 4)), Color.WHITE, false, 4.0)
	
	if draw_overlay_enabled:
		draw_overlay()

func draw_overlay():
	for row in grid:
		for block in row:
			if not block: continue
			for dir in range(4):
				var port = block.ports[dir]
				if port.chained:
					draw_line(block.position + CELL_SIZE / 2, block.position + CELL_SIZE / 2 + Vector2(Enums.vector(dir)) * CELL_SIZE_PX, Color.MEDIUM_SPRING_GREEN, 2)

## SAVE / LOAD ##

func serialize_block(block : Block, properties : Array):
	if not block: return {}
	
	# Line that resets the properties input
	properties = []
	
	var block_properties = []
	for prop in block.properties.values():
		var index = properties.find(prop)
		if index == -1:
			index = len(properties)
			properties.append(prop)
		block_properties.append(index)
	
	var ports = block.ports.map(func(p): return {
		"property": block.properties.find_key(p.property),
		"mode": p.mode,
		"chained": p.chained,
	})
	
	var block_type = str(block.name)
	var start = block_type.find('@') + 1
	if start != -1:
		block_type = block_type.substr(start, block_type.rfind('@') - start)
	
	var property_values = {}
	for p in block.properties:
		property_values[p] = block.properties[p].value
	
	return {
		"type": block_type,
		"ports": ports,
		"property_values": property_values
		#"properties": properties
	}


func load_grid(data : Dictionary):
	select_block(null)
	
	var blocks = data.blocks
	#var properties = data.properties
	
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var old_block = grid[y][x]
			if old_block:
				old_block.queue_free()
			
			var block_data : Dictionary = blocks[y][x]
			if block_data.is_empty():
				set_block_at(Vector2i(x, y), null)
				continue
			
			var new_block = _spawn_block_at(Vector2i(x, y), BLOCK_TYPE_MAP[block_data.type])
			
			for prop_name in block_data.property_values:
				new_block.properties[prop_name].value = block_data.property_values[prop_name]
			
			for i in range(4):
				var port = block_data.ports[i]
				new_block.ports[i].property = new_block.properties[port.property]
				new_block.ports[i].chained = port.chained
				new_block.ports[i].mode = port.mode
			

func serialize_grid() -> Dictionary:
	var serialized_grid = []
	var properties = []
	
	for y in range(GRID_SIZE.y):
		var row = []
		for x in range(GRID_SIZE.x):
			row.append(serialize_block(grid[y][x], properties))
		serialized_grid.append(row)
	
	var property_data = properties.map(func(prop : PropertyValue): return {
		"value": prop.value
	})
	
	return {
		"blocks": serialized_grid,
		#"properties": property_data
	}

## INPUT ##

func select_block(block : Block) -> void:
	selected_block = block
	block_selected.emit(block)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if selected_block:
		var movement_x = int(event.is_action_pressed("right")) - int(event.is_action_pressed("left"))
		var movement_y = int(event.is_action_pressed("down")) - int(event.is_action_pressed("up"))
		
		if movement_x != 0 or movement_y != 0:
			var select_position = selected_block.grid_position + Vector2i(movement_x, movement_y)
			var block_to_select = get_block_at(select_position)
			if block_to_select: select_block(block_to_select)
	
	if event.is_action_pressed("ui_cancel"):
		select_block(null)

	if event.is_action_pressed("menu_new"):
		select_block(null)
		
		for y in range(GRID_SIZE.y):
			for x in range(GRID_SIZE.x):
				var block = grid[y][x]
				if block:
					block.queue_free()
				
				set_block_at(Vector2i(x, y), null)
	
	if event.is_action_pressed("menu_save"):
		var data = serialize_grid()
		
		$SaveFileDialog.popup()
		$SaveFileDialog.connect("file_selected", func(path): 
			var file = FileAccess.open(path, FileAccess.WRITE_READ)
			file.store_string(JSON.stringify(data, "  "))
		, CONNECT_ONE_SHOT)
	
	elif event.is_action_pressed("menu_load"):
		$LoadFileDialog.popup()
		$LoadFileDialog.connect("file_selected", func(path): 
			var file = FileAccess.open(path, FileAccess.READ)
			var data = JSON.parse_string(file.get_as_text())
			load_grid(data)
		, CONNECT_ONE_SHOT)

	if event.is_action_pressed("click"):
		var pos = (get_global_mouse_position() - CELL_SIZE / 2).snapped(CELL_SIZE)
		var grid_pos = Vector2i(pos / CELL_SIZE_PX)
		
		if not GRID_RECT.has_point(grid_pos): return
		
		var grid_block = get_block_at(grid_pos)
		# if there is a grid block at this position already
		if grid_block:
			select_block(grid_block)
			return
		
		# create new block
		var new_block = _spawn_block_at(grid_pos, block_to_place)
		select_block(new_block)


func _spawn_block_at(position : Vector2i, block_to_place : PackedScene):
	var new_block : Node2D = block_to_place.instantiate()
	new_block.position = CELL_SIZE * Vector2(position)
	new_block.grid_position = position
	new_block.in_grid = true
	add_child(new_block)

	set_block_at(position, new_block)
	return new_block

func _set_block_to_place(block) -> void:
	block_to_place = block


func _on_delete_button_pressed() -> void:
	set_block_at(selected_block.grid_position, null)
	selected_block.queue_free()
	select_block(null)

func _on_execute_button_pressed() -> void:
	if selected_block:
		selected_block.propagate()
