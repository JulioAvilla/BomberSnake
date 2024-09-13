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
