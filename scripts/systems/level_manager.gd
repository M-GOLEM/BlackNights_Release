extends Node

const UiTheme := preload("res://scripts/ui/ui_theme.gd")

@export var chapter_index := 1
@export var chapter_title_en := "CHAPTER I"
@export var chapter_title_ar := "الاستيقاظ"
@export var next_level_path := ""
@export var spawn_point := Vector2(400, 560)
@export var follow_vertical := false
@export var fall_limit := 1300.0
@export var is_finale := false

var _paused := false
var _finished := false
var _respawning := false
var _camera_dip := 0.0
var _pause_layer: CanvasLayer
var _pause_panel: VBoxContainer
var _controls_overlay: Control
var _settings_overlay: Control
var _fade_rect: ColorRect
var _fade_tween: Tween

@onready var level_root: Node2D = get_parent()
@onready var player: CharacterBody2D = level_root.get_node("CharacterRoot")
@onready var camera: Camera2D = level_root.get_node("Camera2D")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_fade()
	_build_pause_menu()
	_build_chapter_title()
	SaveSystem.enter_chapter(chapter_index)
	AudioManager.play_chapter_music(chapter_index)
	for area in get_tree().get_nodes_in_group("checkpoints"):
		area.body_entered.connect(_on_checkpoint_entered.bind(area))
	for area in get_tree().get_nodes_in_group("finish"):
		area.body_entered.connect(_on_finish_entered)
	_fade_from_black(1.2)


func _physics_process(delta: float) -> void:
	if _finished or _paused or _respawning:
		return
	var half_width := get_viewport().get_visible_rect().size.x * 0.5
	var half_height := get_viewport().get_visible_rect().size.y * 0.5
	var target_y := camera.position.y
	if follow_vertical:
		target_y = clampf(player.global_position.y - 140.0, camera.limit_top + half_height, camera.limit_bottom - half_height)
	var min_x := camera.limit_left + half_width
	var max_x := camera.limit_right - half_width
	var target_x := (camera.limit_left + camera.limit_right) * 0.5
	if max_x >= min_x:
		target_x = clampf(player.global_position.x, min_x, max_x)
	_camera_dip = move_toward(_camera_dip, 0.0, 95.0 * delta)
	camera.global_position = Vector2(target_x, target_y + _camera_dip)
	if player.global_position.y > fall_limit:
		kill_player()


func add_camera_dip(amount: float) -> void:
	_camera_dip = maxf(_camera_dip, amount)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not _finished:
		if _controls_overlay.visible or _settings_overlay.visible:
			_close_pause_overlay()
		else:
			_set_paused(not _paused)


func _on_checkpoint_entered(body: Node2D, area: Area2D) -> void:
	if body == player:
		spawn_point = area.global_position + Vector2(0, 40)
		AudioManager.play_sfx("checkpoint", -5.0)
		var flash := create_tween()
		flash.tween_property(area, "modulate", Color(1.8, 1.8, 1.8, 1.0), 0.1)
		flash.tween_property(area, "modulate", Color.WHITE, 0.35)


func _on_finish_entered(body: Node2D) -> void:
	if _finished or body != player:
		return
	_finished = true
	SaveSystem.complete_chapter(chapter_index)
	AudioManager.play_sfx("finish", -3.0)
	await _fade_to_black(1.5)
	if next_level_path != "" and ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	elif is_finale:
		_run_ending()
	else:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")


func _run_ending() -> void:
	SaveSystem.set_value("progress", "completed", true)
	var layer := CanvasLayer.new()
	layer.layer = 30
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.03, 0.94)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var box := VBoxContainer.new()
	box.theme = UiTheme.build()
	box.position = Vector2(660, 380)
	box.add_theme_constant_override("separation", 22)
	layer.add_child(box)
	var title := Label.new()
	title.text = "THE END"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.95, 0.82, 0.62, 1))
	box.add_child(title)
	var ar := Label.new()
	ar.text = "النهاية"
	ar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ar.add_theme_font_size_override("font_size", 42)
	ar.add_theme_color_override("font_color", Color(0.75, 0.64, 0.52, 1))
	box.add_child(ar)
	var thanks := Label.new()
	thanks.text = "شكراً للعب"
	thanks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thanks.add_theme_font_size_override("font_size", 26)
	thanks.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6, 1))
	box.add_child(thanks)
	await get_tree().create_timer(4.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")


func kill_player() -> void:
	if _finished or _respawning:
		return
	_respawning = true
	AudioManager.play_sfx("hurt", -4.0)
	await _fade_to_black(0.28)
	player.global_position = spawn_point
	player.velocity = Vector2.ZERO
	if player.has_method("set_in_water"):
		player.set_in_water(false)
	camera.global_position = Vector2(spawn_point.x, camera.position.y)
	camera.reset_smoothing()
	_respawning = false
	_fade_from_black(0.4)


func _set_paused(value: bool) -> void:
	_paused = value
	_pause_layer.visible = value
	_pause_panel.visible = true
	_controls_overlay.visible = false
	_settings_overlay.visible = false
	get_tree().paused = value


func _build_fade() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 1)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade_rect)


func _fade_to_black(duration: float) -> void:
	if _fade_tween != null:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_fade_rect, "color:a", 1.0, duration)
	await _fade_tween.finished


func _fade_from_black(duration: float) -> void:
	if _fade_tween != null:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_fade_rect, "color:a", 0.0, duration)


func _build_chapter_title() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var box := VBoxContainer.new()
	box.position = Vector2(760, 130)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.modulate.a = 0.0
	box.theme = UiTheme.build()
	layer.add_child(box)
	var title_en := Label.new()
	title_en.text = chapter_title_en
	title_en.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_en.add_theme_font_size_override("font_size", 34)
	title_en.add_theme_color_override("font_color", Color(0.72, 0.72, 0.75, 1))
	box.add_child(title_en)
	var title_ar := Label.new()
	title_ar.text = chapter_title_ar
	title_ar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_ar.add_theme_font_size_override("font_size", 26)
	title_ar.add_theme_color_override("font_color", Color(0.45, 0.45, 0.48, 1))
	box.add_child(title_ar)
	var tween := create_tween()
	tween.tween_property(box, "modulate:a", 1.0, 1.0).set_delay(1.0)
	tween.tween_property(box, "modulate:a", 0.0, 1.5).set_delay(2.5)


func _build_pause_menu() -> void:
	_pause_layer = CanvasLayer.new()
	_pause_layer.layer = 10
	_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_layer.visible = false
	add_child(_pause_layer)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_layer.add_child(dim)

	_pause_panel = VBoxContainer.new()
	_pause_panel.theme = UiTheme.build()
	_pause_panel.position = Vector2(800, 300)
	_pause_panel.add_theme_constant_override("separation", 14)
	_pause_layer.add_child(_pause_panel)

	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.64, 1))
	_pause_panel.add_child(title)

	var chapter_label := Label.new()
	chapter_label.text = chapter_title_en + "  ·  " + chapter_title_ar
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_label.add_theme_font_size_override("font_size", 20)
	chapter_label.add_theme_color_override("font_color", Color(0.48, 0.48, 0.53, 1))
	_pause_panel.add_child(chapter_label)

	_pause_panel.add_child(_pause_button("RESUME", func() -> void: _set_paused(false)))
	_pause_panel.add_child(_pause_button("CONTROLS", _open_controls))
	_pause_panel.add_child(_pause_button("SETTINGS", _open_settings))
	_pause_panel.add_child(_pause_button("RESTART CHAPTER", _restart_level))
	_pause_panel.add_child(_pause_button("MAIN MENU", _go_to_menu))

	_controls_overlay = _build_controls_overlay()
	_settings_overlay = _build_settings_overlay()
	_pause_layer.add_child(_controls_overlay)
	_pause_layer.add_child(_settings_overlay)


func _pause_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(320, 56)
	button.pressed.connect(callback)
	button.pressed.connect(func() -> void: AudioManager.play_sfx("ui_click", -7.0))
	return button


func _build_controls_overlay() -> Control:
	var overlay := _pause_overlay_base()
	var box := VBoxContainer.new()
	box.theme = UiTheme.build()
	box.position = Vector2(700, 280)
	box.add_theme_constant_override("separation", 10)
	overlay.add_child(box)

	var title := Label.new()
	title.text = "CONTROLS"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.84, 1))
	box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "التحكم"
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6, 1))
	box.add_child(subtitle)

	_control_row(box, "A / D  ·  ← / →", "الحركة يميناً ويساراً")
	_control_row(box, "SPACE", "القفز")
	_control_row(box, "SHIFT", "الجري")
	_control_row(box, "W / S  ·  ↑ / ↓", "التسلق والسباحة")
	_control_row(box, "E", "التفاعل مع المفاتيح")
	_control_row(box, "ESC", "الإيقاف المؤقت")

	var back := _pause_button("BACK", func() -> void: _close_pause_overlay())
	back.custom_minimum_size = Vector2(240, 50)
	box.add_child(back)
	return overlay


func _control_row(box: VBoxContainer, keys: String, description: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 26)
	var key_label := Label.new()
	key_label.text = keys
	key_label.custom_minimum_size = Vector2(260, 0)
	key_label.add_theme_font_size_override("font_size", 22)
	key_label.add_theme_color_override("font_color", Color(0.84, 0.86, 0.92, 1))
	row.add_child(key_label)
	var desc_label := Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 22)
	desc_label.add_theme_color_override("font_color", Color(0.58, 0.6, 0.66, 1))
	row.add_child(desc_label)
	box.add_child(row)


func _build_settings_overlay() -> Control:
	var overlay := _pause_overlay_base()
	var box := VBoxContainer.new()
	box.theme = UiTheme.build()
	box.position = Vector2(700, 280)
	box.add_theme_constant_override("separation", 14)
	overlay.add_child(box)

	var title := Label.new()
	title.text = "SETTINGS"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.84, 1))
	box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "الإعدادات"
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6, 1))
	box.add_child(subtitle)

	_slider_row(box, "MASTER", "Master")
	_slider_row(box, "MUSIC", "Music")
	_slider_row(box, "SFX", "SFX")

	var fullscreen := CheckButton.new()
	fullscreen.text = "FULLSCREEN  —  ملء الشاشة"
	fullscreen.button_pressed = SaveSystem.is_fullscreen()
	fullscreen.toggled.connect(SaveSystem.set_fullscreen)
	box.add_child(fullscreen)

	var back := _pause_button("BACK", func() -> void: _close_pause_overlay())
	back.custom_minimum_size = Vector2(240, 50)
	box.add_child(back)
	return overlay


func _slider_row(box: VBoxContainer, label_text: String, bus_name: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(180, 0)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.78, 0.8, 0.86, 1))
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.custom_minimum_size = Vector2(300, 24)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value = SaveSystem.volume(bus_name)
	slider.value_changed.connect(func(v: float) -> void: SaveSystem.set_volume(bus_name, v))
	row.add_child(slider)
	box.add_child(row)


func _pause_overlay_base() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	var bg := ColorRect.new()
	bg.color = Color(0.015, 0.015, 0.025, 0.96)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(bg)
	return overlay


func _open_controls() -> void:
	_pause_panel.visible = false
	_settings_overlay.visible = false
	_controls_overlay.visible = true


func _open_settings() -> void:
	_pause_panel.visible = false
	_controls_overlay.visible = false
	_settings_overlay.visible = true


func _close_pause_overlay() -> void:
	_controls_overlay.visible = false
	_settings_overlay.visible = false
	_pause_panel.visible = true


func _restart_level() -> void:
	_set_paused(false)
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
