extends AnimatableBody2D

var travel := Vector2(0, 260)
var slam_time := 0.32
var lift_time := 1.6
var rest_time := 1.6


func _ready() -> void:
	sync_to_physics = true
	var start := position
	var tween := create_tween().set_loops()
	tween.tween_interval(rest_time)
	tween.tween_property(self, "position", start + travel, slam_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_interval(rest_time * 0.55)
	tween.tween_property(self, "position", start, lift_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
