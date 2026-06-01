extends Area2D





func _on_body_entered(body):

	if body.is_in_group("player"):

		body.is_dead = true
		body.velocity = Vector2.ZERO
		body.modulate = Color(0,0,0)

		await get_tree().create_timer(0.5).timeout
		body.die()
