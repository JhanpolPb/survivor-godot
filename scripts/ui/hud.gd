extends CanvasLayer
## Interfaz en pantalla: vida, experiencia, tiempo, muertes, avisos, pausa y game over.

var _hp_bar: ProgressBar
var _xp_bar: ProgressBar
var _level_label: Label
var _time_label: Label
var _kills_label: Label
var _message_label: Label
var _pause_overlay: Control
var _game_over_overlay: Control
var _game_over_label: Label


func _ready() -> void:
	layer = 5

	_xp_bar = _make_bar(Color(0.35, 0.6, 1.0))
	_xp_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_xp_bar.offset_bottom = 12
	add_child(_xp_bar)

	_hp_bar = _make_bar(Color(0.9, 0.25, 0.3))
	_hp_bar.position = Vector2(16, 24)
	_hp_bar.size = Vector2(240, 18)
	add_child(_hp_bar)

	_level_label = _make_label(18)
	_level_label.position = Vector2(16, 46)
	add_child(_level_label)

	_time_label = _make_label(28)
	_time_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_time_label.offset_top = 18
	_time_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(_time_label)

	_kills_label = _make_label(18)
	_kills_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_kills_label.offset_top = 22
	_kills_label.offset_left = -200
	_kills_label.offset_right = -16
	_kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_kills_label)

	_message_label = _make_label(32)
	_message_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_message_label.offset_top = 90
	_message_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_message_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	_message_label.modulate.a = 0.0
	add_child(_message_label)

	_pause_overlay = _make_overlay("PAUSA\n\nEsc / P para continuar", 40)
	add_child(_pause_overlay)

	_game_over_overlay = _make_overlay("", 36)
	_game_over_label = _game_over_overlay.get_child(1) as Label
	add_child(_game_over_overlay)


# --- API pública ---------------------------------------------------------------

func set_health(current: float, maximum: float) -> void:
	_hp_bar.max_value = maximum
	_hp_bar.value = current


func set_xp(current: int, needed: int, level: int) -> void:
	_xp_bar.max_value = needed
	_xp_bar.value = current
	_level_label.text = "Nivel %d" % level


func set_time(seconds: float) -> void:
	_time_label.text = _format_time(seconds)


func set_kills(kills: int) -> void:
	_kills_label.text = "Enemigos: %d" % kills


func set_paused(paused: bool) -> void:
	_pause_overlay.visible = paused


func show_message(text: String) -> void:
	_message_label.text = text
	var tween := create_tween()
	tween.tween_property(_message_label, "modulate:a", 1.0, 0.2)
	tween.tween_interval(2.0)
	tween.tween_property(_message_label, "modulate:a", 0.0, 0.6)


func show_game_over(seconds: float, level: int, kills: int) -> void:
	_game_over_label.text = "HAS MUERTO\n\nSobreviviste %s\nNivel %d  ·  %d enemigos\n\nPulsa R para reiniciar" % [
		_format_time(seconds), level, kills,
	]
	_game_over_overlay.visible = true


# --- Construcción de la UI ------------------------------------------------------

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%02d:%02d" % [total / 60, total % 60]


func _make_bar(fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0, 0, 0, 0.55)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	return bar


func _make_label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	return label


## Capa a pantalla completa: fondo oscuro (hijo 0) + texto centrado (hijo 1).
func _make_overlay(text: String, font_size: int) -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)

	var label := _make_label(font_size)
	label.text = text
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay.add_child(label)
	return overlay
