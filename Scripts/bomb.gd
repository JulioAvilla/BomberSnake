extends Node2D

@onready var timer = $Timer

@export var world = 0
@export var tile_map = 0

@onready var animation = $AnimationPlayer


func _on_center_area_entered(_area):
	explode()


func _on_corner_area_entered(_area):
	animation.play("explosion")
	timer.start()


func explode():
	var tile: Vector2i = tile_map.local_to_map(global_position)
	
	create_boom(tile.x, tile.y)
	create_boom(tile.x+1, tile.y)
	create_boom(tile.x-1, tile.y)
	create_boom(tile.x, tile.y+1)
	create_boom(tile.x, tile.y-1)
	create_boom(tile.x+1, tile.y+1)
	create_boom(tile.x+1, tile.y-1)
	create_boom(tile.x-1, tile.y-1)
	create_boom(tile.x-1, tile.y+1)
	
	queue_free()


func create_boom(x, y):
	var boom = preload("res://Scenes/explosion.tscn").instantiate()
	boom.global_position = tile_map.map_to_local(Vector2i(x, y))
	call_deferred("_add_booms", boom)
func _add_booms(b):
	world.add_child(b)


func _on_timer_timeout():
	explode()
