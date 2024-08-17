class_name BlobThePlayer

extends Node2D

var jump_sound = preload("res://Assets/audio/jump.wav")
var ladder = preload("res://Scene/Ladder/Ladder.tscn")

@onready var timer: Timer = $Timer

const MAX_MATERIAL: int = 50

var build_materials: int = MAX_MATERIAL:
	set(new_build_materials):
		build_materials = clamp(new_build_materials, 0, MAX_MATERIAL)
		if materials_bar:
			materials_bar.value = build_materials
	get:
		return build_materials

@onready var player_rb2d: RigidBody2D = $"."
@onready var materials_bar: TextureProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/TextureProgressBar
@onready var player: Sprite2D = $Player
@onready var gun: Sprite2D = $Gun
@onready var camera_2d: Camera2D = $Camera2D
@onready var marker_2d: Marker2D = $Marker2D

@onready var bounce: AudioStreamPlayer2D = $Bounce

var camera_zoom_delta: float = 0.05
var iladder: RigidBody2D

func _ready() -> void:
	materials_bar.max_value = MAX_MATERIAL
	bounce.stream = jump_sound

#func change_parent(new_parent):
	#call_deferred("_reparent", new_parent, self, get_global_transform())

#func _reparent

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Shooting") and build_materials > 0:
		timer.wait_time = 0.5
		timer.start()
		iladder = ladder.instantiate()
		iladder.freeze = true
		marker_2d.add_child(iladder)
		var offset = Vector2(8.0 + cos(marker_2d.rotation), 0.0)
		iladder.position = offset
		iladder.rotate(deg_to_rad(90))

	if Input.is_action_just_released("Shooting"):
		timer.stop()
		iladder.freeze = false
		iladder.reparent(get_tree().root, true)

	if Input.is_key_label_pressed(KEY_R):
		build_materials = MAX_MATERIAL

func _on_timer_timeout() -> void:
	iladder.call("grow_ladder")

func play_sound(stream: AudioStreamPlayer2D) -> void:
	var dupe: AudioStreamPlayer2D = stream.duplicate()
	add_child(dupe)
	dupe.play()
	await dupe.finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mousepos = get_global_mouse_position()
	marker_2d.look_at(mousepos)
	marker_2d.rotation_degrees = wrap(marker_2d.rotation_degrees, 0, 360)
	if mousepos.x > position.x:
		player.flip_h = 0
	if mousepos.x < position.x:
		player.flip_h = 1

func _on_body_entered(body: Node) -> void:
	play_sound(bounce)


func _on_health_componant_dead() -> void:
	call_deferred("reload_level")
	
func reload_level():
	if get_tree():
		get_tree().reload_current_scene()
