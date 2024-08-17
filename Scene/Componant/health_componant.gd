extends Node2D

class_name HealthComponant

@export var max_health: int = 50:
	set(new_max):
		if max_health < new_max:
			health += new_max - max_health
		if max_health > new_max:
			health = clamp(health, 0, new_max)
		max_health = new_max
@export var health: int = 50

signal damage_taken
signal dead

func damage(damage_value: int) -> void:
	health -= damage_value
	if health > 0:
		damage_taken.emit()
	if health <= 0:
		dead.emit()
