class_name LinkPort
extends Port

func recv(value, active : bool):
	if property.name == "None": return
	
	var new_mode = Mode.OUTPUT if active else Mode.PASSIVE
	for port in property.ports:
		port._set_mode(new_mode)
	
	#if mode == Mode.OUTPUT or (mode == Mode.PASSIVE and not active): return
	property.set_value(value, self)
