class_name BlobThePlayer

extends CharacterBody2D

var jump_sound = preload("res://Assets/audio/jump.wav")
var ladder = preload("res://Scene/Ladder/Ladder.tscn")

@onready var timer: Timer = $Timer
@onready var collided_timer: Timer = $CollidedTimer

const MAX_MATERIAL: int = 15

var build_materials: int = MAX_MATERIAL:
	set(new_build_materials):
		build_materials = clamp(new_build_materials, 0, MAX_MATERIAL)
		if materials_bar:
			materials_bar.value = build_materials
	get:
		return build_materials
var max_ladder_length: int = 5
var ladder_length: int = 0

var is_on_ladder: bool = false

@onready var materials_bar: TextureProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/TextureProgressBar
@onready var player: Sprite2D = $Player
@onready var camera_2d: Camera2D = $Camera2D
@onready var marker_2d: Marker2D = $Marker2D

@onready var bounce: AudioStreamPlayer2D = $Bounce

var camera_zoom_delta: float = 0.05
var iladder: RigidBody2D

func _ready() -> void:
	materials_bar.max_value = MAX_MATERIAL
	bounce.stream = jump_sound
	$CanvasLayer.visible = true

func _physics_process(delta: float) -> void:
	get_input()
	if Input.is_action_just_pressed("click") and build_materials > 0:
		timer.wait_time = 0.5
		timer.start()
		iladder = ladder.instantiate()
		iladder.freeze = true
		var offset = Vector2(16.0, 0.0)
		iladder.position = offset
		iladder.rotate(deg_to_rad(90))
		marker_2d.add_child(iladder)
		build_materials -= 1
		ladder_length += 1


	if Input.is_action_just_released("click"):
		timer.stop()
		if iladder.get_colliding_bodies().size() == 0:
			iladder.freeze = false
			iladder.reparent(get_parent(), true)
			ladder_length = 0
		else:
			collided_timer.wait_time = 0.1
			collided_timer.start()

	if Input.is_key_label_pressed(KEY_R):
		call_deferred("reload_level")

	var collision = move_and_collide(velocity * delta, true)
	var areas: Array[Area2D] = $LadderColliderTest.get_overlapping_areas()
	if areas.size() >= 1:
		is_on_ladder = areas.any(is_rb2d_sleeping)
	else:
		is_on_ladder = false

	if not is_on_ladder:
		velocity += get_gravity() * 2 * delta

	move_and_slide()

func is_rb2d_sleeping(area: Area2D):
	var rb2d: RigidBody2D = area.get_parent()
	if rb2d.sleeping:
		return true
	else:
		return false

func _on_timer_timeout() -> void:
	if ladder_length < max_ladder_length and build_materials > 0:
		iladder.call("grow_ladder")
		build_materials -= 1
		ladder_length += 1
		
func _on_collided_timer_timeout() -> void:
	if iladder.get_colliding_bodies().size() == 0:
		iladder.freeze = false
		iladder.reparent(get_tree().root, true)
		ladder_length = 0
		collided_timer.stop()


func play_sound(stream: AudioStreamPlayer2D) -> void:
	var dupe: AudioStreamPlayer2D = stream.duplicate()
	add_child(dupe)
	dupe.play()
	await dupe.finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mousepos = get_global_mouse_position()
	marker_2d.look_at(mousepos)
	if mousepos.x > position.x:
		player.flip_h = 0
	if mousepos.x < position.x:
		player.flip_h = 1

func get_input():
	velocity.x = 0
	var input_left_right: float = Input.get_axis("left", "right")
	velocity.x = input_left_right * 150.0
	if is_on_ladder:
		var input_up_down: float = Input.get_axis("up", "down")
		velocity.y = input_up_down * 150.0

#func _on_body_entered(body: Node) -> void:
	#play_sound(bounce)

func _on_health_componant_dead() -> void:
	call_deferred("reload_level")
	
func reload_level():
	if get_tree():
		get_tree().reload_current_scene()
