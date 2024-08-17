class_name BlobThePlayer

extends Node2D

@onready var timer: Timer = $Timer

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

@onready var energy_effect: Sprite2D = $Gun/EnergyEffect
@export var color_progression: Gradient
@onready var point_light_2d: PointLight2D = $Gun/PointLight2D

var camera_zoom_delta: float = 0.05

func _ready() -> void:
	energy_bar.max_value = MAX_ENERGY

func _physics_process(_delta: float) -> void:
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
		tween.tween_property(camera_2d, "zoom", Vector2.ONE * 3.0, 0.2).set_trans(Tween.TRANS_EXPO)
		energy_effect.visible = false
		point_light_2d.visible = false
		var angle = gun.rotation
		player_rb2d.apply_impulse(Vector2(cos(angle), sin(angle)) * projectile_force * -30)
		projectile_force = 0

func _on_timer_timeout() -> void:
	if timer.wait_time < 1 and energy > 0:
		
		if timer.wait_time < 0.33:
				energy_effect.frame = 0
		if timer.wait_time >= 0.33 and timer.wait_time < 0.66:
				energy_effect.frame = 1
		if timer.wait_time >= 0.66:
				energy_effect.frame = 2

		var target_zoom = Vector2.ONE * lerp(camera_2d.zoom.x, 2.0, timer.wait_time)
		camera_2d.zoom = target_zoom

		energy_effect.material.set("shader_parameter/energy_color", color_progression.sample(timer.wait_time))
		point_light_2d.color = color_progression.sample(timer.wait_time)
		point_light_2d.scale = Vector2.ONE * timer.wait_time / 4
		timer.wait_time *= 1.2
		energy -= 1
		projectile_force += 1
	else:
		timer.stop()







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
