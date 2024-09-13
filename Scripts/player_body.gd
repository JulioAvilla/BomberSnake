extends Node2D

@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer


@export var tile_map = 0
@export var skin = "res://Sprites/playersheet2.png"
@export var spawn_point: Vector2i = Vector2i(1, 1)
@export var prev_part = 0
@export var world = 0
@export var speed = 1


var side = 1
var is_moving = false
var active = true
var last = true
signal moved
signal grow
signal die_army


func _ready():
	sprite.texture = load(skin)
	prev_part.connect("moved", move_body)
	prev_part.connect("grow", grow_army)
	prev_part.connect("die_army", die)
	init_player()


func init_player():
	active = true
	self.show()


func grow_army():
	if not last:
		emit_signal("grow")
	else:
		create_body(global_position)


func create_body(current_tile):
	var player_body = preload("res://Scenes/player_body.tscn").instantiate()
	player_body.tile_map = tile_map
	player_body.global_position = tile_map.map_to_local(current_tile)
	player_body.prev_part = self
	player_body.world = world
	player_body.speed = speed
	player_body.skin = skin
	last = false
	call_deferred("_add_player_body", player_body)
	#_add_player_body(player_body)
func _add_player_body(player_body):
	world.add_child(player_body)


func move_body(target_tile, p_side):
	
	side = p_side
	
	if side == 4:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	
	emit_signal("moved", current_tile, side)
	
	is_moving = true
	global_position = tile_map.map_to_local(target_tile)
	sprite.global_position = tile_map.map_to_local(current_tile)


func _physics_process(_delta):
	if not active:
		return

	if side == 3:
		animation.play("walk_down")
	elif side == 1 or side == 4:
		animation.play("walk_right")
	elif side == 2:
		animation.play("walk_up")
	
	sprite.global_position = sprite.global_position.move_toward(global_position, speed)
	
	if global_position == sprite.global_position:
		is_moving = false


func die():
	active = false
	animation.play("death")
	emit_signal("die_army")
