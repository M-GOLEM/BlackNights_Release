extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.has_method("set_in_water"):
		body.set_in_water(true)
		if AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("splash", -6.0)


func _on_body_exited(body: Node) -> void:
	if body.has_method("set_in_water"):
		body.set_in_water(false)
