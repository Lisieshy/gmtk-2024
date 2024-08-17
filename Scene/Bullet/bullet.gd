extends Sprite2D

var size: int:
	set(new_size):
		size = new_size
		if size < 0:
			return
		if size > 2:
			return
		frame = size

var bullet_strenght: int = 0

var direction: Vector2

func _ready() -> void:
	$PointLight2D.color = material.get("shader_parameter/energy_color")
	
func _physics_process(delta: float) -> void:
	global_position += (direction * delta) 

func _on_hurt_box_componant_collision() -> void:
	queue_free()
