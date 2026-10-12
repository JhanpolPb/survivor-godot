extends "res://scripts/weapons/weapon.gd"
## Rayo mágico: dispara proyectiles al enemigo más cercano.

const Projectile := preload("res://scripts/projectile.gd")
const WEAPON_NAME := "Rayo mágico"
const LEVEL_DESCRIPTIONS := [
	"Dispara al enemigo más cercano",
	"+1 proyectil",
	"+50% daño",
	"+1 proyectil y atraviesa 1 enemigo más",
	"-30% tiempo de recarga",
	"+1 proyectil y +50% daño",
]
const RANGE := 550.0
const SPREAD := 0.15  # radianes entre proyectiles

var cooldown := 0.9
var damage := 10.0
var projectile_count := 1
var pierce := 1
var projectile_speed := 500.0

var _timer := 0.0


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	var target = _nearest_enemy(RANGE)
	if target == null:
		return

	_timer = cooldown * player.cooldown_mult
	var direction: Vector2 = (target.global_position - global_position).normalized()
	for i in projectile_count:
		var offset := (i - (projectile_count - 1) / 2.0) * SPREAD
		_fire(direction.rotated(offset))


func _fire(direction: Vector2) -> void:
	var projectile := Projectile.new()
	projectile.position = global_position  # el mundo está en el origen
	projectile.velocity = direction * projectile_speed
	projectile.damage = damage * player.damage_mult
	projectile.pierce = pierce
	world().add_child(projectile)


func _apply_level(new_level: int) -> void:
	match new_level:
		2:
			projectile_count += 1
		3:
			damage *= 1.5
		4:
			projectile_count += 1
			pierce += 1
		5:
			cooldown *= 0.7
		6:
			projectile_count += 1
			damage *= 1.5
