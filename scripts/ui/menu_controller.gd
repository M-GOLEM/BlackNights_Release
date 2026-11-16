extends Control

const UiTheme := preload("res://scripts/ui/ui_theme.gd")

const LEVELS: Array[String] = [
	"res://scenes/levels/Level_01_Wake.tscn",
	"res://scenes/levels/Level_02_Flooded.tscn",
	"res://scenes/levels/Level_03_Factory.tscn",
	"res://scenes/levels/Level_04_Tunnels.tscn",
	"res://scenes/levels/Level_05_Tower.tscn",
	"res://scenes/levels/Level_06_Lab.tscn",
	"res://scenes/levels/Level_07_FalseDawn.tscn",
]

@onready var fade: ColorRect = $Fade


func _ready() -> void:
	theme = UiTheme.build()
	_bind_main_menu()
	_bind_settings()
	_wire_button_sounds(self)
	fade.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)
	AudioManager.play_menu_music()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and name == "Settings":
		_back_to_menu()


func _bind_main_menu() -> void:
	var continue_button := get_node_or_null("Title/ContinueButton") as Button
	if continue_button == null:
		return
	continue_button.disabled = not SaveSystem.has_progress()
	continue_button.pressed.connect(_on_continue)
	(get_node("Title/NewGameButton") as Button).pressed.connect(_on_new_game)
	(get_node("Title/SettingsButton") as Button).pressed.connect(_open_settings)
	(get_node("Title/QuitButton") as Button).pressed.connect(_on_quit)


func _bind_settings() -> void:
	var master := get_node_or_null("Panel/Grid/MasterSlider") as HSlider
	if master == null:
		return
	master.value = SaveSystem.volume("Master")
	(get_node("Panel/Grid/MusicSlider") as HSlider).value = SaveSystem.volume("Music")
	(get_node("Panel/Grid/SfxSlider") as HSlider).value = SaveSystem.volume("SFX")
	(get_node("Panel/Grid/FullscreenCheck") as CheckButton).button_pressed = SaveSystem.is_fullscreen()

	master.value_changed.connect(func(v: float) -> void: SaveSystem.set_volume("Master", v))
	(get_node("Panel/Grid/MusicSlider") as HSlider).value_changed.connect(
		func(v: float) -> void: SaveSystem.set_volume("Music", v)
	)
	(get_node("Panel/Grid/SfxSlider") as HSlider).value_changed.connect(
		func(v: float) -> void: SaveSystem.set_volume("SFX", v)
	)
	(get_node("Panel/Grid/FullscreenCheck") as CheckButton).toggled.connect(SaveSystem.set_fullscreen)
	(get_node("Panel/BackButton") as Button).pressed.connect(_back_to_menu)


func _wire_button_sounds(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			(child as Button).pressed.connect(func() -> void: AudioManager.play_sfx("ui_click", -7.0))
		_wire_button_sounds(child)


func _on_continue() -> void:
	var index := clampi(SaveSystem.highest_chapter() - 1, 0, LEVELS.size() - 1)
	_start_level(index)


func _on_new_game() -> void:
	SaveSystem.reset_progress()
	_start_level(0)


func _open_settings() -> void:
	_transition_to("res://scenes/ui/Settings.tscn")


func _back_to_menu() -> void:
	_transition_to("res://scenes/ui/MainMenu.tscn")


func _on_quit() -> void:
	get_tree().quit()


func _start_level(index: int) -> void:
	_transition_to(LEVELS[index])


func _transition_to(path: String) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.6)
	tween.tween_callback(get_tree().change_scene_to_file.bind(path))
