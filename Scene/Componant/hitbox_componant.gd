extends Area2D

class_name HitboxComponant

@export var health_componant: HealthComponant

func damage(attack: Attack) -> void:
	if health_componant:
		health_componant.damage(attack.damage)
