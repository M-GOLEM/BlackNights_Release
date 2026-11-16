extends Area2D

var door_path: NodePath
var _used := false
var _glow: Sprite2D
var _player_inside := false
var _interact_was_down := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_glow = get_meta("glow", null)


func _physics_process(_delta: float) -> void:
	var down := Input.is_action_pressed("interact")
	if not _used and _player_inside and down and not _interact_was_down:
		_activate()
	_interact_was_down = down


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if _glow != null:
			_glow.modulate.a = 0.55


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if _glow != null and not _used:
			_glow.modulate.a = 0.3


func _activate() -> void:
	_used = true
	var door := get_node_or_null(door_path)
	if door != null and door.has_method("open"):
		door.open()
	if _glow != null:
		_glow.modulate = Color(0.55, 1.0, 0.72, 0.5)
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("switch")
