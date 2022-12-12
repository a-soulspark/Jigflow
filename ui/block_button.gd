extends Button

@export
var block_scene : PackedScene

func _ready() -> void:
	var block_icon = block_scene.instantiate()
	block_icon.scale = Vector2.ONE * 0.75
	# 64, 64 -> 48, 48
	# 60 - 48 = 12 / 2 = 6
	block_icon.position = Vector2(6, 6)
	block_icon.show_behind_parent = false
	add_child(block_icon)
