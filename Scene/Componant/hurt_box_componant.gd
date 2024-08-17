extends Area2D

class_name HurtBoxComponant

@export var damage: int = 10

signal collision

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponant:
		var attack = Attack.new()
		attack.damage = 10
		area.damage(attack)
	collision.emit()


func _on_body_entered(body: Node2D) -> void:
	if body is HitboxComponant:
		var attack = Attack.new()
		attack.damage = 10
		body.damage(attack)
	collision.emit()
