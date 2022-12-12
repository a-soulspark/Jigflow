class_name PropertyValue

signal property_changed(property)
enum Type { NUMBER, TEXT, TOGGLE }

var name : StringName
var alias : String
var type : Type

var value
var recursion_depth = 0

func set_value(new_value, port : Port = null):
	if recursion_depth:
		print('Infinite recursion @ Property ', name)
		return
	recursion_depth += 1
	
	value = new_value
	for p in ports:
		if p != port: p.send(value)
	property_changed.emit(self)
	recursion_depth -= 1

var allowed_modes : Port.Mode
var color : Color

var ports : Array[Port] = []

func _init(alias : String, type : Type, value, allowed_modes : Port.Mode, color : Color):
	self.alias = alias
	self.type = type
	self.value = value
	self.allowed_modes = allowed_modes
	self.color = color
