extends Node

@export var player1: CharacterBody2D
@export var player2: CharacterBody2D

var game_over = false


func _process(delta):

	if game_over:
		return

	if player1.is_dead and player2.is_dead:

		game_over = true

		print("GAME OVER")

		await get_tree().create_timer(2.0).timeout

		get_tree().reload_current_scene()
