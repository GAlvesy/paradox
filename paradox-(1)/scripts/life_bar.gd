extends CanvasLayer

@export var player1: CharacterBody2D
@export var player2: CharacterBody2D

@onready var hp1 = $Control/HPBarP1
@onready var hp2 = $Control/HPBarP2


func _process(delta):

	if player1:
		hp1.value = player1.hp

	if player2:
		hp2.value = player2.hp
