extends CharacterBody2D
## Jugador: movimiento, vida, experiencia, estadísticas y armas.

signal health_changed(current: float, maximum: float)
signal xp_changed(current: int, needed: int, level: int)
signal leveled_up(new_level: int)
signal died

const Util := preload("res://scripts/util.gd")
const RADIUS := 14.0
const BODY_COLOR := Color(0.55, 0.85, 1.0)
const HURT_COLOR := Color(1.0, 0.35, 0.35)

# Estadísticas (las mejoras las modifican con apply_stat)
var max_health := 100.0
var health := 100.0
var speed := 220.0
var pickup_radius := 90.0
var armor := 0.0
var regen := 0.0
var damage_mult := 1.0
var cooldown_mult := 1.0

# Progresión
var level := 1
var xp := 0
var xp_to_next := 5

var weapons: Array = []
var facing := Vector2.RIGHT

var _hurtbox: Area2D
var _hurt_flash := 0.0
var _dead := false


func _ready() -> void:
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 1
	collision_mask = 0
	Util.add_circle_shape(self, RADIUS)

	# Área que detecta a los enemigos que nos tocan (capa 2 = enemigos)
	_hurtbox = Area2D.new()
	_hurtbox.collision_layer = 0
	_hurtbox.collision_mask = 2
	Util.add_circle_shape(_hurtbox, RADIUS + 2.0)
	add_child(_hurtbox)


func _physics_process(delta: float) -> void:
	if _dead:
		return

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input != Vector2.ZERO:
		facing = input.normalized()
	velocity = input * speed
	move_and_slide()

	# Daño por contacto: cada enemigo que nos toca aporta su "daño por segundo".
	var incoming := 0.0
	for body in _hurtbox.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			incoming += body.damage
	if incoming > 0.0:
		# La armadura resta daño fijo, pero siempre entra al menos el 20 %.
		take_damage(maxf(incoming - armor, incoming * 0.2) * delta)
	elif regen > 0.0 and health < max_health:
		heal(regen * delta)

	_hurt_flash = maxf(_hurt_flash - delta, 0.0)
	queue_redraw()


func take_damage(amount: float) -> void:
	if _dead:
		return
	health -= amount
	_hurt_flash = 0.12
	if health <= 0.0:
		health = 0.0
		_dead = true
		health_changed.emit(health, max_health)
		died.emit()
		return
	health_changed.emit(health, max_health)


func heal(amount: float) -> void:
	health = minf(health + amount, max_health)
	health_changed.emit(health, max_health)


func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = _xp_needed_for(level)
		leveled_up.emit(level)
	xp_changed.emit(xp, xp_to_next, level)


func _xp_needed_for(lv: int) -> int:
	return int(round(5.0 + pow(lv, 1.6) * 3.0))


func emit_stats() -> void:
	health_changed.emit(health, max_health)
	xp_changed.emit(xp, xp_to_next, level)


# --- Armas y mejoras -----------------------------------------------------------

func add_weapon(weapon_script: Script) -> void:
	var weapon = weapon_script.new()
	add_child(weapon)
	weapons.append(weapon)


func get_weapon(weapon_script: Script):
	for weapon in weapons:
		if weapon.get_script() == weapon_script:
			return weapon
	return null


func apply_stat(stat: String, amount: float) -> void:
	match stat:
		"max_health":
			max_health += amount
			heal(amount)
		"heal":
			heal(amount)
		"speed":
			speed *= 1.0 + amount
		"damage":
			damage_mult += amount
		"cooldown":
			cooldown_mult *= 1.0 - amount
		"pickup":
			pickup_radius *= 1.0 + amount
		"regen":
			regen += amount
		"armor":
			armor += amount


# --- Dibujo (sin sprites: todo con formas) -------------------------------------

func _draw() -> void:
	draw_arc(Vector2.ZERO, pickup_radius, 0.0, TAU, 48, Color(1, 1, 1, 0.05), 1.0)
	var color := HURT_COLOR if _hurt_flash > 0.0 else BODY_COLOR
	draw_circle(Vector2.ZERO, RADIUS, color)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 32, color.darkened(0.45), 2.0)
	# Ojos que miran hacia donde te mueves
	var eye := facing * 5.0
	var side := facing.orthogonal() * 4.5
	draw_circle(eye + side, 2.5, Color.BLACK)
	draw_circle(eye - side, 2.5, Color.BLACK)
