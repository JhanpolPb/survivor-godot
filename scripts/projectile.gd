extends Area2D
## Proyectil que avanza en línea recta y daña a los enemigos que toca.

const Util := preload("res://scripts/util.gd")

var velocity := Vector2.ZERO
var damage := 10.0
var pierce := 1  # cuántos enemigos puede golpear antes de desaparecer
var lifetime := 2.0
var radius := 5.0
var color := Color(0.55, 0.8, 1.0)


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # enemigos
	Util.add_circle_shape(self, radius)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if pierce <= 0 or not body.is_in_group("enemies"):
		return
	body.take_damage(damage, velocity.normalized())
	pierce -= 1
	if pierce <= 0:
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius + 3.0, Color(color, 0.3))
	draw_circle(Vector2.ZERO, radius, color)
