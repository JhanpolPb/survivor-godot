extends Node2D
## Escena principal: arma el mundo, conecta señales y controla el estado del juego
## (subidas de nivel, pausa, game over y reinicio).

const Player := preload("res://scripts/player.gd")
const Spawner := preload("res://scripts/spawner.gd")
const XpGem := preload("res://scripts/xp_gem.gd")
const Background := preload("res://scripts/background.gd")
const Hud := preload("res://scripts/ui/hud.gd")
const UpgradeMenu := preload("res://scripts/ui/upgrade_menu.gd")
const Upgrades := preload("res://scripts/upgrades.gd")
const MagicBolt := preload("res://scripts/weapons/magic_bolt.gd")

var world: Node2D
var player
var spawner
var hud
var upgrade_menu

var kills := 0
var _pending_levels := 0
var _game_over := false


func _ready() -> void:
	# Main sigue procesando en pausa (para leer Esc / R); el mundo sí se pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input()

	world = Node2D.new()
	world.name = "World"
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	world.add_to_group("world")
	add_child(world)

	var background := Background.new()
	world.add_child(background)

	player = Player.new()
	player.name = "Player"
	world.add_child(player)
	player.add_weapon(MagicBolt)
	background.target = player

	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)

	spawner = Spawner.new()
	spawner.player = player
	spawner.world = world
	world.add_child(spawner)
	spawner.enemy_spawned.connect(_on_enemy_spawned)

	hud = Hud.new()
	add_child(hud)
	spawner.boss_spawned.connect(func(): hud.show_message("¡Se acerca un JEFE!"))

	upgrade_menu = UpgradeMenu.new()
	add_child(upgrade_menu)
	upgrade_menu.option_chosen.connect(_on_option_chosen)

	player.health_changed.connect(hud.set_health)
	player.xp_changed.connect(hud.set_xp)
	player.leveled_up.connect(_on_player_leveled_up)
	player.died.connect(_on_player_died)
	player.emit_stats()


func _process(_delta: float) -> void:
	if not _game_over:
		hud.set_time(spawner.elapsed)
		hud.set_kills(kills)


func _unhandled_input(event: InputEvent) -> void:
	if _game_over:
		if event.is_action_pressed("restart"):
			get_tree().paused = false
			get_tree().reload_current_scene()
		return

	if event.is_action_pressed("pause") and not upgrade_menu.visible:
		get_tree().paused = not get_tree().paused
		hud.set_paused(get_tree().paused)


# --- Señales -----------------------------------------------------------------

func _on_enemy_spawned(enemy) -> void:
	enemy.died.connect(_on_enemy_died)


func _on_enemy_died(enemy) -> void:
	kills += 1
	var gem := XpGem.new()
	gem.value = enemy.xp_value
	gem.player = player
	gem.position = enemy.global_position
	# Diferido: puede ocurrir dentro de un callback de física.
	world.call_deferred("add_child", gem)


func _on_player_leveled_up(_new_level: int) -> void:
	_pending_levels += 1
	if not upgrade_menu.visible:
		_open_upgrade_menu()


func _open_upgrade_menu() -> void:
	get_tree().paused = true
	upgrade_menu.show_options(Upgrades.get_options(player, 3))


func _on_option_chosen() -> void:
	_pending_levels -= 1
	if _pending_levels > 0:
		_open_upgrade_menu()
	else:
		get_tree().paused = false


func _on_player_died() -> void:
	_game_over = true
	get_tree().paused = true
	hud.show_game_over(spawner.elapsed, player.level, kills)


# --- Controles -----------------------------------------------------------------

## Registra las acciones de teclado por código, así no dependemos del Input Map del editor.
func _setup_input() -> void:
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"pause": [KEY_ESCAPE, KEY_P],
		"restart": [KEY_R],
	}
	for action in bindings:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
