extends Node2D
## Gema de experiencia que suelta un enemigo al morir.
## Cuando el jugador entra en su radio de recogida, vuela hacia él.

const COLLECT_DISTANCE := 18.0

var value := 1
var player

var _magnetized := false
var _speed := 0.0


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var to_player: Vector2 = player.global_position - global_position
	var distance := to_player.length()
	if distance < COLLECT_DISTANCE:
		player.add_xp(value)
		queue_free()
		return

	if _magnetized or distance < player.pickup_radius:
		_magnetized = true
		_speed = minf(_speed + 1400.0 * delta, 900.0)
		global_position += to_player.normalized() * _speed * delta


func _draw() -> void:
	var color := Color(0.35, 0.65, 1.0)
	var size := 5.0
	if value >= 50:
		color = Color(1.0, 0.3, 0.4)
		size = 9.0
	elif value >= 5:
		color = Color(0.4, 1.0, 0.5)
		size = 7.0
	var points := PackedVector2Array([
		Vector2(0, -size), Vector2(size * 0.7, 0), Vector2(0, size), Vector2(-size * 0.7, 0),
	])
	draw_colored_polygon(points, color)
