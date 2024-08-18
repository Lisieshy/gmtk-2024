extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var area_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var rectangle_shape_2d: RectangleShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rectangle_shape_2d = RectangleShape2D.new()
	rectangle_shape_2d.size = Vector2(16, 16)
	collision_shape_2d.shape = rectangle_shape_2d
	area_collision_shape_2d.shape = rectangle_shape_2d

func grow_ladder() -> void:
	sprite.region_rect = sprite.region_rect.grow_individual(0, 128, 0, 0)
	sprite.position.y -= 8
	var old_size: Vector2 = collision_shape_2d.shape.get("size")
	var new_size: Vector2 = old_size + Vector2(0, 16.0)
	collision_shape_2d.shape.set("size", new_size)
	collision_shape_2d.position.y -= 8
	area_collision_shape_2d.shape.set("size", new_size)
	area_collision_shape_2d.position.y -= 8

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
