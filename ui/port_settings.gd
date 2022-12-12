class_name PortOptions
extends Panel

const MODE_NAMES = ['P', 'I', 'O']

var block : Block
var port : Port

const MODE_ICONS : Array[Texture2D] = [preload("res://ui/passive.svg"), preload("res://ui/input.svg"), preload("res://ui/output.svg")]
const MODE_ICON_COLORS : Array[Color] = [Color.WHITE, Color.DARK_TURQUOISE, Color.ORANGE]
const CHAINED_ICON : Texture2D = preload("res://ui/link.svg")
const UNCHAINED_ICON : Texture2D = preload("res://ui/unlink.svg")

var property_switch : Button
var mode_switch : Button
var chained_switch : Button

func initialize(port : Port, block : Block):
	property_switch = $MarginContainer/PropertySwitch
	mode_switch = $MarginContainer/HBoxContainer/ModeSwitch
	chained_switch = $MarginContainer/HBoxContainer/ChainedSwitch

	self.port = port
	self.block = block
	port.connect("port_modified", _port_modified)
	
	if port is LinkPort or len(block.properties.values()) <= 1 and port.property.allowed_modes == 0:
		mode_switch.visible = false
		$MarginContainer.remove_child(property_switch)
		$MarginContainer/HBoxContainer.add_child(property_switch, false, Node.INTERNAL_MODE_FRONT)
		(property_switch as Button).add_theme_font_size_override('font_size', 28)
		#property_switch.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
		#chained_switch.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT, PRESET_MODE_KEEP_SIZE)

func _port_modified():
	mode_switch.visible = port.property.allowed_modes > 0
	property_switch.visible = len(block.properties) > 1
	
	property_switch.text = port.property.alias
	
	mode_switch.icon = MODE_ICONS[port.mode]
	mode_switch.modulate = MODE_ICON_COLORS[port.mode]
	
	(chained_switch as Button).icon = CHAINED_ICON if port.chained else UNCHAINED_ICON
	(chained_switch as Button).modulate = Color.WHITE if port.chained else Color.GRAY

func _on_property_switch_pressed() -> void:
	# ugly-ass line... that works
	var property_index = (block.properties.values().find(port.property) + 1) % len(block.properties)
	port.property = block.properties.values()[property_index]
	if port.mode != Port.Mode.PASSIVE and not port.mode & port.property.allowed_modes:
		_on_mode_switch_pressed()

func _on_mode_switch_pressed() -> void:
	var mode = port.mode
	while true:
		mode = (mode + 1) % len(Port.Mode)
		if mode == Port.Mode.PASSIVE or mode & port.property.allowed_modes: break
	
	port.mode = mode

func _on_chained_switch_pressed() -> void:
	port.chained = not port.chained
