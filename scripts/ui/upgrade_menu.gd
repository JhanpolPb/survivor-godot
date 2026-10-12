extends CanvasLayer
## Menú que aparece al subir de nivel. Pausa el juego y muestra 3 mejoras.
## Se elige con clic, con las teclas 1-3 o con flechas + Enter.

signal option_chosen

var _buttons: VBoxContainer
var _options: Array = []


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS  # funciona con el juego en pausa
	visible = false

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.13, 0.18)
	style.border_color = Color(0.35, 0.6, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	panel.add_child(layout)

	var title := Label.new()
	title.text = "¡Subiste de nivel! Elige una mejora"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	layout.add_child(title)

	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 10)
	layout.add_child(_buttons)


func show_options(options: Array) -> void:
	_options = options
	for child in _buttons.get_children():
		_buttons.remove_child(child)
		child.queue_free()

	for i in options.size():
		var option: Dictionary = options[i]
		var button := Button.new()
		button.text = "%d.  %s\n%s" % [i + 1, option["title"], option["desc"]]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(460, 70)
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_choose.bind(i))
		_buttons.add_child(button)

	visible = true
	if _buttons.get_child_count() > 0:
		(_buttons.get_child(0) as Button).grab_focus.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var index: int = event.physical_keycode - KEY_1
		if index >= 0 and index < _options.size():
			get_viewport().set_input_as_handled()
			_choose(index)


func _choose(index: int) -> void:
	if not visible:
		return
	visible = false
	_options[index]["apply"].call()
	option_chosen.emit()
