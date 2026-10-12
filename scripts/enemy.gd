extends CharacterBody2D
## Enemigo genérico que persigue al jugador. Sus valores vienen de Spawner.KINDS.

signal died(enemy)

const Util := preload("res://scripts/util.gd")
const DamageNumber := preload("res://scripts/fx/damage_number.gd")
## Si el enemigo queda más lejos que esto, reaparece del otro lado del jugador.
const RESPAWN_DISTANCE := 1400.0

var max_health := 10.0
var health := 10.0
var speed := 90.0
var damage := 10.0  # daño por segundo al tocar al jugador
var xp_value := 1
var radius := 12.0
var color := Color.RED
var target  # el jugador

var _flash := 0.0
var _knockback := Vector2.ZERO
var _dead := false
var _world: Node


## Se llama antes de agregarlo al árbol. `difficulty` escala con el tiempo de partida.
func setup(kind: Dictionary, difficulty: float) -> void:
	max_health = kind["health"] * difficulty
	health = max_health
	speed = kind["speed"]
	damage = kind["damage"] * (1.0 + (difficulty - 1.0) * 0.5)
	xp_value = kind["xp"]
	radius = kind["radius"]
	color = kind["color"]


func _ready() -> void:
	add_to_group("enemies")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 2
	collision_mask = 2  # chocan entre ellos para no amontonarse en un punto
	Util.add_circle_shape(self, radius)
	_world = get_tree().get_first_node_in_group("world")


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return

	var to_target: Vector2 = target.global_position - global_position
	if to_target.length() > RESPAWN_DISTANCE:
		global_position = target.global_position + to_target.normalized() * 700.0
		return

	velocity = to_target.normalized() * speed + _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, 900.0 * delta)
	move_and_slide()

	if _flash > 0.0:
		_flash -= delta
		if _flash <= 0.0:
			queue_redraw()


func take_damage(amount: float, knock_dir: Vector2 = Vector2.ZERO) -> void:
	if _dead:
		return
	health -= amount
	_flash = 0.08
	# Los enemigos grandes retroceden menos
	_knockback = (_knockback + knock_dir * 220.0 * (12.0 / radius)).limit_length(400.0)
	queue_redraw()
	_spawn_damage_number(amount)

	if health <= 0.0:
		_dead = true
		died.emit(self)
		queue_free()


func _spawn_damage_number(amount: float) -> void:
	if _world == null:
		return
	var number := DamageNumber.new()
	number.amount = amount
	number.position = global_position + Vector2(0, -radius)
	_world.add_child(number)


func _draw() -> void:
	var body_color := Color.WHITE if _flash > 0.0 else color
	draw_circle(Vector2.ZERO, radius, body_color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, color.darkened(0.5), 2.0)

	# Barra de vida solo si ya recibió daño
	if health < max_health:
		var width := radius * 2.0
		var top_left := Vector2(-radius, -radius - 8.0)
		draw_rect(Rect2(top_left, Vector2(width, 4)), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(top_left, Vector2(width * health / max_health, 4)), Color(0.9, 0.2, 0.2))
