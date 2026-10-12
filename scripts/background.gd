extends Node2D
## Dibuja una cuadrícula infinita alrededor del objetivo para que se note el movimiento.

const CELL := 64.0
const HALF_VIEW := Vector2(720, 420)
const LINE_COLOR := Color(1, 1, 1, 0.04)

var target: Node2D


func _ready() -> void:
	z_index = -10


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if target == null:
		return
	var center := target.global_position
	var start := ((center - HALF_VIEW) / CELL).floor() * CELL
	var end := center + HALF_VIEW

	var x := start.x
	while x < end.x:
		draw_line(Vector2(x, start.y), Vector2(x, end.y), LINE_COLOR, 1.0)
		x += CELL
	var y := start.y
	while y < end.y:
		draw_line(Vector2(start.x, y), Vector2(end.x, y), LINE_COLOR, 1.0)
		y += CELL
