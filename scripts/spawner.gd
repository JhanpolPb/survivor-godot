extends Node
## Genera oleadas de enemigos alrededor del jugador. La dificultad sube con el tiempo.

signal enemy_spawned(enemy)
signal boss_spawned

const Enemy := preload("res://scripts/enemy.gd")

## Tipos de enemigo. Para agregar uno nuevo basta con añadirlo aquí y en _pick_kind().
const KINDS := {
	"basic": {"health": 12.0, "speed": 85.0, "damage": 10.0, "xp": 1, "radius": 12.0, "color": Color(0.85, 0.3, 0.35)},
	"fast": {"health": 7.0, "speed": 150.0, "damage": 6.0, "xp": 1, "radius": 9.0, "color": Color(0.95, 0.7, 0.25)},
	"tank": {"health": 70.0, "speed": 55.0, "damage": 20.0, "xp": 5, "radius": 20.0, "color": Color(0.6, 0.35, 0.85)},
	"boss": {"health": 800.0, "speed": 75.0, "damage": 35.0, "xp": 60, "radius": 36.0, "color": Color(0.75, 0.1, 0.15)},
}
const SPAWN_DISTANCE := 760.0  # justo fuera de la pantalla
const MAX_ENEMIES := 350
const BOSS_EVERY := 180.0  # segundos

var player
var world: Node2D
var elapsed := 0.0

var _spawn_timer := 1.0
var _next_boss := BOSS_EVERY


func _physics_process(delta: float) -> void:
	elapsed += delta
	_spawn_timer -= delta

	if _spawn_timer <= 0.0:
		_spawn_timer = maxf(0.18, 1.1 - elapsed * 0.006)
		var batch := 1 + int(elapsed / 40.0)
		for i in batch:
			_spawn(_pick_kind())

	if elapsed >= _next_boss:
		_next_boss += BOSS_EVERY
		_spawn("boss")
		boss_spawned.emit()


## Escala de vida de los enemigos: x1 al inicio, x2 a los 2 minutos, etc.
func difficulty() -> float:
	return 1.0 + elapsed / 120.0


func _pick_kind() -> String:
	var roll := randf()
	if elapsed > 75.0 and roll < 0.12:
		return "tank"
	if elapsed > 30.0 and roll < 0.40:
		return "fast"
	return "basic"


func _spawn(kind_name: String) -> void:
	if kind_name != "boss" and get_tree().get_nodes_in_group("enemies").size() >= MAX_ENEMIES:
		return
	var enemy := Enemy.new()
	enemy.setup(KINDS[kind_name], difficulty())
	enemy.target = player
	enemy.position = player.global_position + Vector2.RIGHT.rotated(randf() * TAU) * SPAWN_DISTANCE
	world.add_child(enemy)
	enemy_spawned.emit(enemy)
