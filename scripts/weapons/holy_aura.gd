extends "res://scripts/weapons/weapon.gd"
## Aura sagrada: daña periódicamente a todos los enemigos dentro del círculo.

const Util := preload("res://scripts/util.gd")
const WEAPON_NAME := "Aura sagrada"
const LEVEL_DESCRIPTIONS := [
	"Daña a los enemigos cercanos",
	"+25% radio",
	"+50% daño",
	"+25% radio",
	"Golpea 30% más seguido",
]

var radius := 65.0
var damage := 5.0
var tick := 0.6

var _area: Area2D
var _shape: CollisionShape2D
var _timer := 0.0
var _pulse := 0.0


func _ready() -> void:
	super()
	z_index = -1  # debajo del jugador
	_area = Area2D.new()
	_area.collision_layer = 0
	_area.collision_mask = 2
	_shape = Util.add_circle_shape(_area, radius)
	add_child(_area)


func _physics_process(delta: float) -> void:
	_pulse = maxf(_pulse - delta * 3.0, 0.0)
	_timer -= delta
	if _timer <= 0.0:
		_timer = tick * player.cooldown_mult
		_pulse = 1.0
		for body in _area.get_overlapping_bodies():
			if body.is_in_group("enemies"):
				body.take_damage(damage * player.damage_mult)
	queue_redraw()


func _apply_level(new_level: int) -> void:
	match new_level:
		2, 4:
			radius *= 1.25
			(_shape.shape as CircleShape2D).radius = radius
		3:
			damage *= 1.5
		5:
			tick *= 0.7


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.9, 0.4, 0.08 + _pulse * 0.10))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(1.0, 0.9, 0.4, 0.35), 2.0)
