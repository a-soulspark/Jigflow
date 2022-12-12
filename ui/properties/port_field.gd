class_name PortField
extends Panel

func initialize(block : Block):
	var children = get_children()
	for direction in range(get_child_count()):
		var options = children[direction] as PortOptions
		options.initialize(block.ports[direction], block)
		options._port_modified()
