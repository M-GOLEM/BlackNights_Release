extends Area2D

var _period := 2.4
var _on_time := 1.3
var _phase := 0.0
var _t := 0.0
var _glow: Sprite2D


func _ready() -> void:
	_period = float(get_meta("period", 2.4))
	_phase = float(get_meta("phase", 0.0))
	_on_time = _period * 0.55
	_t = _phase
	_glow = get_meta("glow", null)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	# Advance in game time: Movie Maker renders far below real time, so a
	# wall-clock cycle would blink out of sync with the player during capture.
	_t = fmod(_t + delta, _period)
	var active := _t < _on_time
	if active == visible:
		return
	visible = active
	monitoring = active
	set_deferred("monitorable", active)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var level := get_tree().current_scene
	if level == null:
		return
	var manager := level.get_node_or_null("LevelManager")
	if manager != null and manager.has_method("kill_player"):
		manager.kill_player()
