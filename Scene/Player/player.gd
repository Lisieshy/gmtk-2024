extends Node2D

@onready var timer: Timer = $Timer

var projectile_force: int = 0
var energy: int = 100:
	set(new_energy):
		energy = new_energy
		if energy_bar:
			energy_bar.value = new_energy
	get:
		return energy

@onready var energy_bar: TextureProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/TextureProgressBar
@onready var player: Sprite2D = $Player
@onready var gun: Sprite2D = $Gun


@onready var energy_effect: Sprite2D = $Gun/EnergyEffect
@export var color_progression: Gradient
@onready var point_light_2d: PointLight2D = $Gun/PointLight2D

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Shooting"):
		energy_effect.visible = true
		point_light_2d.visible = true
		energy_effect.frame = 0
		timer.wait_time = 0.1
		point_light_2d.scale = Vector2.ONE * timer.wait_time / 4
		energy_effect.material.set("shader_parameter/energy_color", color_progression.sample(timer.wait_time))
		point_light_2d.color = color_progression.sample(timer.wait_time)
		timer.start()
		
	if Input.is_action_just_released("Shooting"):
		timer.stop()
		energy_effect.visible = false
		point_light_2d.visible = false
		projectile_force = 0

func _on_timer_timeout() -> void:
	if timer.wait_time < 1 and energy > 0:
		
		if timer.wait_time < 0.33:
				energy_effect.frame = 0
		if timer.wait_time >= 0.33 and timer.wait_time < 0.66:
				energy_effect.frame = 1
		if timer.wait_time >= 0.66:
				energy_effect.frame = 2
		
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
	if mousepos.x > position.x:
		player.flip_h = 0
		gun.flip_v = 0
	if mousepos.x < position.x:
		player.flip_h = 1
		gun.flip_v = 1
