extends "res://scripts/weapons/weapon.gd"
## Espadas orbitales: giran alrededor del jugador y golpean lo que tocan.

const Util := preload("res://scripts/util.gd")
const WEAPON_NAME := "Espadas orbitales"
const LEVEL_DESCRIPTIONS := [
	"Espadas que giran a tu alrededor",
	"+1 espada",
	"+40% daño",
	"+1 espada y mayor radio",
	"Giran 40% más rápido",
	"+2 espadas",
]
const BLADE_LENGTH := 22.0

var blade_count := 2
var damage := 7.0
var orbit_radius := 70.0
var spin_speed := 3.0  # radianes por segundo
var hit_interval := 0.4  # tiempo mínimo entre golpes al mismo enemigo

var _angle := 0.0
var _blades: Array[Area2D] = []
var _last_hit := {}  # instance_id del enemigo -> segundo del último golpe
var _time := 0.0


func _ready() -> void:
	super()
	_rebuild_blades()


func _physics_process(delta: float) -> void:
	_time += delta
	_angle = fmod(_angle + spin_speed * delta, TAU)

	for i in _blades.size():
		var blade := _blades[i]
		var blade_angle := _angle + TAU * i / _blades.size()
		blade.position = Vector2.RIGHT.rotated(blade_angle) * orbit_radius
		for body in blade.get_overlapping_bodies():
			if not body.is_in_group("enemies"):
				continue
			var id := body.get_instance_id()
			if _time - _last_hit.get(id, -INF) >= hit_interval:
				_last_hit[id] = _time
				var knock: Vector2 = (body.global_position - global_position).normalized()
				body.take_damage(damage * player.damage_mult, knock)

	if _last_hit.size() > 500:
		_last_hit.clear()
	queue_redraw()


func _rebuild_blades() -> void:
	for blade in _blades:
		blade.queue_free()
	_blades.clear()
	for i in blade_count:
		var blade := Area2D.new()
		blade.collision_layer = 0
		blade.collision_mask = 2
		Util.add_circle_shape(blade, 11.0)
		add_child(blade)
		_blades.append(blade)


func _apply_level(new_level: int) -> void:
	match new_level:
		2:
			blade_count += 1
		3:
			damage *= 1.4
		4:
			blade_count += 1
			orbit_radius += 20.0
		5:
			spin_speed *= 1.4
		6:
			blade_count += 2
	_rebuild_blades()


func _draw() -> void:
	for blade in _blades:
		var dir := blade.position.normalized()
		var tangent := dir.orthogonal()
		var center := blade.position
		# Una "hoja" con forma de rombo alargado orientada en la dirección de giro
		var points := PackedVector2Array([
			center - tangent * BLADE_LENGTH * 0.5,
			center + dir * 5.0,
			center + tangent * BLADE_LENGTH * 0.5,
			center - dir * 5.0,
		])
		draw_colored_polygon(points, Color(0.85, 0.9, 1.0))
