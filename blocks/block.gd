class_name Block
extends Node2D

var arrow_mode_textures : Array[Texture2D] = [preload("res://blocks/arrow_passive.png"), preload("res://blocks/arrow_input.png"), preload("res://blocks/arrow_output.png")]

var grid_position : Vector2i
var in_grid : bool = false

var properties : Dictionary

var ports : Array[Port]
var neighbours : Array[Block] = [null, null, null, null]

@onready
var arrows : Array[Sprite2D] = [$Arrow1 as Sprite2D, $Arrow2 as Sprite2D, $Arrow3 as Sprite2D, $Arrow4 as Sprite2D]

var recursion_depth = 0

func initialize() -> void:
	properties = get_property_map()
	
	var default_property = PropertyValue.new('', PropertyValue.Type.NUMBER, 0, Port.Mode.INPUT | Port.Mode.OUTPUT, Color.WHITE)
	if not properties.is_empty():
		default_property = properties.values()[0]
	else:
		properties['default'] = default_property
	
	for i in properties:
		properties[i].name = i.capitalize()
		properties[i].connect("property_changed", _property_changed)

	_setup_ports(default_property)


func _setup_ports(default_property : PropertyValue):
	ports = []
	for i in range(4):
		var new_port = Port.new(default_property)
		new_port.connect("port_modified", _port_modified.bind(new_port, i))
		ports.append(new_port)


func _ready() -> void:
	initialize()
	for i in range(4):
		_port_modified(ports[i], i)


func get_property_map() -> Dictionary:
	return {}


func update_neighbour(direction : Enums.Direction, neighbour : Block):
	neighbours[direction] = neighbour
	ports[direction].adjacent_port = neighbour.ports[Enums.flip(direction)] if neighbour else null


func _port_modified(port : Port, direction : Enums.Direction):
	var arrow = arrows[direction]
	arrow.texture = arrow_mode_textures[port.mode]
	arrow.modulate = port.property.color


func _property_changed(property : PropertyValue):
	queue_redraw()


func propagate(direction : Enums.Direction = Enums.Direction.NONE, recursion_limit = 1):
	if recursion_depth > recursion_limit:
		print('Infinite recursion @ Block ', grid_position)
		return

	_execute()

	recursion_depth += 1
	var source_side = Enums.flip(direction)
	for i in range(4):
		if i != source_side and ports[i].chained and neighbours[i]:
			neighbours[i].propagate(i, recursion_limit)
	
	recursion_depth -= 1

func _execute() -> void:
	pass
