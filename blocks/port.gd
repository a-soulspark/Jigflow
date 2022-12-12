class_name Port

signal port_modified()

# LIST OF ISSUES:
## changing the property of a port does not cause an active input
## changing the port of an adjacent block does not cause an active input
## FIXED: if two adjacent ports are chained, an infinite recursion crash happens
## FIXED: chained execution doesn't work at all
## Chains can cause a BUNCH of infinite recursions. jeez. fix those, please.
### Go HypeHype-way? (check for infinite recursions...)

enum Mode { PASSIVE, INPUT, OUTPUT }

# The Property that this Port is linked to
var property : PropertyValue :
	set(new_property):
		if property: property.ports.erase(self)
		property = new_property
		property.ports.append(self)
		_port_modified()
	get:
		return property

# The Mode (PASSIVE/INPUT/OUTPUT) of the Port
var mode : Mode :
	set(new_mode):
		mode = new_mode
		_port_modified()
		if mode == Mode.INPUT and adjacent_port:
			adjacent_port.request()
	get:
		return mode

func _set_mode(new_mode : Mode):
	mode = new_mode

var chained : bool :
	set(new_chained):
		chained = new_chained
		_port_modified()
	get:
		return chained

var adjacent_port : Port

func _init(property : PropertyValue) -> void:
	self.property = property
	mode = Mode.PASSIVE

func _port_modified():
	port_modified.emit()

# cause a value to be sent from the adjacent port to this one
func request():
	send(property.value)

# send a value to the adjacent port
func send(value):
	if not adjacent_port: return
	
	if mode == Mode.PASSIVE:
		adjacent_port.recv(value, false)
	elif mode == Mode.OUTPUT:
		adjacent_port.recv(value, true)

# receive a value from the adjacent port
func recv(value, active : bool):
	if mode == Mode.OUTPUT or (mode == Mode.PASSIVE and not active): return
	property.set_value(value, self)
