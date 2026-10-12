extends Node2D
## Número de daño que sube y se desvanece.

const DURATION := 0.6

var amount := 0.0
var _life := DURATION


func _ready() -> void:
	z_index = 20
	position += Vector2(randf_range(-8.0, 8.0), 0.0)


func _process(delta: float) -> void:
	_life -= delta
	position.y -= 50.0 * delta
	modulate.a = clampf(_life / DURATION * 1.5, 0.0, 1.0)
	if _life <= 0.0:
		queue_free()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var text := str(maxi(1, roundi(amount)))
	var pos := Vector2(-20, 0)
	draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, 40, 15, 3, Color.BLACK)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, 40, 15, Color.WHITE)
