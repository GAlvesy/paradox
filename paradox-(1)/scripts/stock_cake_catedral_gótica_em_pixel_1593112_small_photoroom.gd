extends Area2D


@export var next_level: PackedScene

func _on_area_entered(area: Area2D) -> void:
	
	print("Encostou na área: ", area.name)
	
	
	if area.get_parent().is_in_group("Player"):
		if next_level:
			get_tree().call_deferred("change_scene_to_packed", next_level)
		else:
			print("Cena não definida no Inspetor!")
	
	
	pass
