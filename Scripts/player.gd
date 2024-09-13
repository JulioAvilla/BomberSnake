extends Node2D

@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer
@onready var collision = $Area2D/CollisionShape2D
@onready var timer = $Timer

@export var tile_map = 0
@export var skin = "res://Sprites/playersheet2.png"
@export var spawn_point: Vector2i = Vector2i(1, 1)
@export var reverse = false
@export var world = 0

var side = 0
var is_moving = false
var speed = 2
var active = true
signal moved
signal grow
signal die_army


func _ready():
	sprite.texture = load(skin)
	init_player()


func init_player():
	active = false
	world.connect("grow_head", grow_army)
	if not reverse:
		side = 1
		create_body(Vector2i(4, 9))
	else:
		side = 4
		sprite.flip_h = true
		create_body(Vector2i(14, 9))


func create_body(spawn):
	var player_body = preload("res://Scenes/player_body.tscn").instantiate()
	player_body.tile_map = tile_map
	player_body.global_position = tile_map.map_to_local(spawn)
	player_body.prev_part = self
	player_body.world = world
	player_body.skin = skin
	player_body.speed = speed
	world.add_child(player_body)


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

func _process(_delta):
	
	if Input.is_action_just_pressed("active"):
		active = !active
		timer.start()
	
	
	if not reverse:
		if Input.is_action_pressed("right") and side != 4:
			side = 1
		elif Input.is_action_pressed("up") and side != 3:
			side = 2
		elif Input.is_action_pressed("down") and side != 2:
			side = 3
		elif Input.is_action_pressed("left") and side != 1:
			side = 4
	else:
		if Input.is_action_pressed("right") and side != 1:
			side = 4
		elif Input.is_action_pressed("up") and side != 2:
			side = 3
		elif Input.is_action_pressed("down") and side != 3:
			side = 2
		elif Input.is_action_pressed("left") and side != 4:
			side = 1


func move(direction: Vector2):

	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var target_tile: Vector2i = Vector2i(current_tile.x + direction.x, current_tile.y + direction.y)
	var tile_data: TileData = tile_map.get_cell_tile_data(0, target_tile)
	
	emit_signal("moved", current_tile, side)
	
	if tile_data.get_custom_data("walkable") == false:
		die()
		return
	
	# Move Player
	is_moving = true
	global_position = tile_map.map_to_local(target_tile)
	sprite.global_position = tile_map.map_to_local(current_tile)

func grow_army():
	emit_signal("grow")

func die():
	active = false
	animation.play("death")
	emit_signal("die_army")


func _on_area_2d_area_entered(area):
	if area.get_collision_layer() == 2 or area.get_collision_layer() == 8:
		die()
	if area.get_collision_layer() == 3:
		return


func _on_timer_timeout():
	if not active:
		return
	
	if side == 1:
		sprite.flip_h = false
		move(Vector2.RIGHT)
	elif side == 2:
		sprite.flip_h = false
		move(Vector2.UP)
	elif side == 3:
		sprite.flip_h = false
		move(Vector2.DOWN)
	elif side == 4:
		sprite.flip_h = true
		move(Vector2.LEFT)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()
		GameManager.lobby.show()
