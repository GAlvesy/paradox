extends Area2D

var direction = Vector2.ZERO
var speed = 300
var damage = 1

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta


func _on_body_entered(body):
	if !body.has_method("take_damage"):
		return

	# calcula direção do knockback (igual seu player espera)
	var knockback_dir = (body.global_position - global_position).normalized()

	body.take_damage(damage, knockback_dir)

	queue_free()
