extends Node2D

@onready var tile_map = $TileMap
@onready var score_label = $TimerSprite/Label
@onready var spawner = $Spawner

signal grow_head
signal grow_reverse
var rng = RandomNumberGenerator.new()
var score = 0
var bomb_active: bool

func _ready():
	#start_game()
	return

func start_game():
	
	score = 0
	
	for child in spawner.get_children():
		child.queue_free()
	
	var player_head = preload("res://Scenes/player.tscn").instantiate()
	player_head.tile_map = tile_map
	player_head.world = self
	player_head.global_position = tile_map.map_to_local(Vector2i(5, 9))
	add_child(player_head)
	
	var reverse_player = preload("res://Scenes/player.tscn").instantiate()
	reverse_player.tile_map = tile_map
	reverse_player.reverse = true
	reverse_player.skin = "res://Sprites/playersheet1.png"
	reverse_player.world = self
	reverse_player.global_position = tile_map.map_to_local(Vector2i(13, 9))
	add_child(reverse_player)
	
	
	create_apple(Vector2i(7, 9))
	create_apple(Vector2i(6, 8))
	create_apple(Vector2i(6, 10))


func apple_eaten():
	
	emit_signal("grow_head")
	emit_signal("grow_reverse")
	
	var x = rng.randi_range(1,17)
	var y = rng.randi_range(1,17)
	
	if bomb_active:
		create_bomb(Vector2i(x, y))
		x -= 1
		y -= 1
		create_bomb(Vector2i(17 - x, 17 - y))
		
		x = rng.randi_range(1,17)
		y = rng.randi_range(1,17)
	
	score += 1
	create_apple(Vector2i(x, y))
	
	print("Score: ", score)

func create_apple(spawn: Vector2i):
	var apple = preload("res://Scenes/apple.tscn").instantiate()
	apple.global_position = tile_map.map_to_local(spawn)
	apple.connect("eat", apple_eaten)
	call_deferred("_add_new_apple", apple)
func _add_new_apple(apple):
	spawner.add_child(apple)

func create_bomb(spawn):
	var bomb = preload("res://Scenes/bomb.tscn").instantiate()
	bomb.global_position = tile_map.map_to_local(spawn)
	bomb.tile_map = tile_map
	bomb.world = self
	call_deferred("_add_new_bomb", bomb)
func _add_new_bomb(bomb):
	spawner.add_child(bomb)


func _process(_delta):
	score_label.text = str(score)
