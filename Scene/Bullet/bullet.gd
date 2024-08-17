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


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
