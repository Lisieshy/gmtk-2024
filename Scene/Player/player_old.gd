class_name BlobThePlayerOld

extends Node2D

var jump_sound = preload("res://Assets/audio/jump.wav")
var shoot_sound = preload("res://Assets/audio/shoot.wav")

@onready var timer: Timer = $Timer

const BULLET = preload("res://Scene/Bullet/bullet.tscn")
const MAX_ENERGY: int = 300
var projectile_force: int = 0
var energy: int = 300:
	set(new_energy):
		energy = clamp(new_energy, 0, 300)
		if energy_bar:
			energy_bar.value = energy
	get:
		return energy

@onready var player_rb2d: RigidBody2D = $"."
@onready var energy_bar: TextureProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/TextureProgressBar
@onready var player: Sprite2D = $Player
@onready var gun: Sprite2D = $Gun
@onready var camera_2d: Camera2D = $Camera2D

@onready var gun_firing: AudioStreamPlayer2D = $GunFiring
@onready var bounce: AudioStreamPlayer2D = $Bounce

@onready var energy_effect: Sprite2D = $Gun/EnergyEffect
@export var color_progression: Gradient
@onready var point_light_2d: PointLight2D = $Gun/PointLight2D

var camera_zoom_delta: float = 0.05

func _ready() -> void:
	energy_bar.max_value = MAX_ENERGY
	bounce.stream = jump_sound
	gun_firing.stream = shoot_sound
	

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("Shooting") and energy > 0:
		var angle_to_mouse = get_angle_to(get_global_mouse_position())
		var calc_x: float = -50 * cos(angle_to_mouse)
		var calc_y: float = -50 * sin(angle_to_mouse)
		var tween = get_tree().create_tween()
		tween.tween_property(camera_2d, "position", Vector2(calc_x, calc_y), 0.1).set_trans(Tween.TRANS_EXPO)

	if Input.is_action_just_pressed("Shooting") and energy > 0:
		timer.wait_time = 0.012
		timer.start()

		energy_effect.visible = true
		point_light_2d.visible = true
		energy_effect.frame = 0
		point_light_2d.scale = Vector2.ONE * timer.wait_time / 4
		energy_effect.material.set("shader_parameter/energy_color", color_progression.sample(timer.wait_time))
		point_light_2d.color = color_progression.sample(timer.wait_time)
		
	if Input.is_action_just_released("Shooting"):
		timer.stop()
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(camera_2d, "zoom", Vector2.ONE * 2.0, 0.4).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(camera_2d, "position", Vector2(0,0), 0.2).set_trans(Tween.TRANS_ELASTIC)
		energy_effect.visible = false
		point_light_2d.visible = false
		var angle = gun.rotation
		player_rb2d.apply_impulse(Vector2(cos(angle), sin(angle)) * projectile_force * -30)
		
		if projectile_force > 0:
			var new_bullet = BULLET.instantiate()
			new_bullet.frame = energy_effect.frame
			new_bullet.material.set("shader_parameter/energy_color", color_progression.sample(timer.wait_time))
			new_bullet.direction = Vector2(cos(angle), sin(angle)) * projectile_force * 30
			new_bullet.global_position = $Gun/Bullet_Spawn.global_position
			
			get_parent().add_child(new_bullet)
			play_gun_sound()

		projectile_force = 0

	if Input.is_key_label_pressed(KEY_R):
		energy = 500

func _on_timer_timeout() -> void:
	if timer.wait_time < 1 and energy > 0:
		
		if timer.wait_time < 0.33:
				energy_effect.frame = 0
		if timer.wait_time >= 0.33 and timer.wait_time < 0.66:
				energy_effect.frame = 1
		if timer.wait_time >= 0.66:
				energy_effect.frame = 2

		var tween = get_tree().create_tween()

		var zoom_progression = Vector2.ONE * lerp(camera_2d.zoom.x, 1.5, timer.wait_time)
		tween.tween_property(camera_2d, "zoom", Vector2.ONE * zoom_progression, 0.2).set_trans(Tween.TRANS_EXPO)

		energy_effect.material.set("shader_parameter/energy_color", color_progression.sample(timer.wait_time))
		point_light_2d.color = color_progression.sample(timer.wait_time)
		point_light_2d.scale = Vector2.ONE * timer.wait_time / 4
		timer.wait_time *= 1.2
		energy -= 1
		projectile_force += 1
	else:
		timer.stop()



func play_gun_sound() -> void:
	var pitch = lerp(1.0, 0.2, timer.wait_time)
	var dupe: AudioStreamPlayer2D = gun_firing.duplicate()
	add_child(dupe)
	dupe.pitch_scale = pitch
	dupe.play()
	await dupe.finished


func play_sound(stream: AudioStreamPlayer2D) -> void:
	var dupe: AudioStreamPlayer2D = stream.duplicate()
	add_child(dupe)
	dupe.play()
	await dupe.finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mousepos = get_global_mouse_position()
	gun.look_at(mousepos)
	gun.rotation_degrees = wrap(gun.rotation_degrees, 0, 360)
	if mousepos.x > position.x:
		player.flip_h = 0
		gun.flip_v = 0
	if mousepos.x < position.x:
		player.flip_h = 1
		gun.flip_v = 1


func _on_body_entered(body: Node) -> void:
	play_sound(bounce)


func _on_health_componant_dead() -> void:
	call_deferred("reload_level")
	
func reload_level():
	if get_tree():
		get_tree().reload_current_scene()
