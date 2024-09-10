extends Area2D

@export var tile_map = 0

signal eat


func _on_area_entered(area):
	if area.get_collision_layer() == 8:
		#var tile: Vector2i = tile_map.local_to_map(global_position)
		emit_signal("eat")
		queue_free()
