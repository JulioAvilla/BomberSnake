extends Control

@onready var game = $"../Game"

func _ready():
	GameManager.lobby = self

func _on_start_pressed():
	self.hide()
	game.start_game()

func _on_config_pressed():
	print("Trollei!")

func _on_quit_pressed():
	get_tree().quit()

func _process(_delta):
	if Input.is_action_pressed("start") and not GameManager.game_started:
		_on_start_pressed()
		GameManager.game_started = true
