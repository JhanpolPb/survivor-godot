extends Node2D
## Clase base de las armas. Cada arma es hija del jugador y dispara sola.
##
## Cada arma concreta define:
##   const WEAPON_NAME: String
##   const LEVEL_DESCRIPTIONS: Array  -> [0] = descripción al obtenerla, [n] = qué da el nivel n+1
## y sobreescribe _apply_level() para aplicar cada mejora.

var level := 1
var player


func _ready() -> void:
	player = get_parent()


func upgrade() -> void:
	level += 1
	_apply_level(level)


func _apply_level(_new_level: int) -> void:
	pass


func world() -> Node:
	return get_tree().get_first_node_in_group("world")


func _nearest_enemy(max_range: float):
	var best = null
	var best_dist := max_range * max_range
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var dist := global_position.distance_squared_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			best = enemy
	return best
