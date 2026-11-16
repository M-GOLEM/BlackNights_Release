extends StaticBody2D

var _open := false
var _start_y := 0.0


func _ready() -> void:
	_start_y = position.y


func open() -> void:
	if _open:
		return
	_open = true
	var shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape != null:
		shape.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(self, "position:y", _start_y - 210.0, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("door")
