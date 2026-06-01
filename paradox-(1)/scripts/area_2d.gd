extends Area2D


@export var next_level: PackedScene





func _on_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://scenes/fase-final.tscn")
	
	print("Encostou",body.name)
	
	if body.is_in_group("Player"):
		
		if next_level:
			get_tree().call_deferred(
				"change_scene_to_packed", next_level
			)
		else:
			print("Cena nao definida")
	pass # Replace with function body.
