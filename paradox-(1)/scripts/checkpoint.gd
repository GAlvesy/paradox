extends Area2D

func _on_body_entered(body):

	if body.is_in_group("player"):

		body.checkpoint_position = global_position

		print(body.name, " salvou checkpoint")
