extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var level := get_tree().current_scene
	if level == null:
		return
	var manager := level.get_node_or_null("LevelManager")
	if manager != null and manager.has_method("kill_player"):
		manager.kill_player()
