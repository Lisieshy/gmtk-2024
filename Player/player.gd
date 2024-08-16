extends Node2D

var timer = Timer.new()

var max_energy: int = 500

var projectile_force: int = 0
var energy: int = 500

@export var charge_rate: Curve

@onready var texture_progress_bar: TextureProgressBar = $Node2D/CanvasLayer/MarginContainer/VBoxContainer/TextureProgressBar
@onready var gun: Sprite2D = $Gun
@onready var icon: Sprite2D = $Icon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.connect("timeout", consume_energy)
	timer.wait_time = 0.05
	add_child(timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	texture_progress_bar.value = energy
	var mousepos = get_global_mouse_position()
	gun.look_at(mousepos)
	if mousepos.x > position.x:
		icon.flip_h = 0
		gun.flip_v = 0
	if mousepos.x < position.x:
		icon.flip_h = 1
		gun.flip_v = 1

func consume_energy():
	timer.wait_time += charge_rate.sample(timer.wait_time)
	if energy > 0:
		energy -= 1
		projectile_force += 1

func _input(event):
	if event.is_action_pressed("lmb"):
		timer.wait_time = 0.05
		timer.start()
	if event.is_action_released("lmb"):
		timer.stop()
		print(projectile_force)
		projectile_force = 0
		
