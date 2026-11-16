extends AnimatableBody2D

var travel := Vector2(0, -180)
var duration := 3.2
var wait_time := 0.7


func _ready() -> void:
	sync_to_physics = true
	var start := position
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position", start + travel, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(wait_time)
	tween.tween_property(self, "position", start, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(wait_time)
