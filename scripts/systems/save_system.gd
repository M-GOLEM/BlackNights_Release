extends Node

const SAVE_PATH := "user://black_nights.cfg"

signal settings_changed

var _cfg := ConfigFile.new()


func _ready() -> void:
	_cfg.load(SAVE_PATH)
	if is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func get_value(section: String, key: String, default_value: Variant = null) -> Variant:
	return _cfg.get_value(section, key, default_value)


func set_value(section: String, key: String, value: Variant) -> void:
	_cfg.set_value(section, key, value)
	_cfg.save(SAVE_PATH)


func highest_chapter() -> int:
	return int(get_value("progress", "highest_chapter", 0))


func current_chapter() -> int:
	return int(get_value("progress", "current_chapter", 1))


func enter_chapter(index: int) -> void:
	set_value("progress", "current_chapter", index)
	if index > highest_chapter():
		set_value("progress", "highest_chapter", index)


func complete_chapter(index: int) -> void:
	if index >= highest_chapter():
		set_value("progress", "highest_chapter", index + 1)


func has_progress() -> bool:
	return highest_chapter() > 0


func reset_progress() -> void:
	_cfg.set_value("progress", "highest_chapter", 0)
	_cfg.set_value("progress", "current_chapter", 1)
	_cfg.save(SAVE_PATH)


func volume(bus_name: String) -> float:
	return float(get_value("settings", "volume_" + bus_name.to_lower(), 0.8))


func set_volume(bus_name: String, value: float) -> void:
	set_value("settings", "volume_" + bus_name.to_lower(), clampf(value, 0.0, 1.0))
	settings_changed.emit()


func is_fullscreen() -> bool:
	return bool(get_value("settings", "fullscreen", false))


func set_fullscreen(enabled: bool) -> void:
	set_value("settings", "fullscreen", enabled)
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	)
