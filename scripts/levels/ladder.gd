extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.has_method("set_on_ladder"):
		body.set_on_ladder(true)


func _on_body_exited(body: Node) -> void:
	if not body.has_method("set_on_ladder"):
		return
	# Stacked ladders overlap at the same x, so leaving one zone must not
	# cancel a climb that another ladder still holds.
	for _i in 2:
		await get_tree().physics_frame
	for ladder in get_tree().get_nodes_in_group("ladders"):
		var other := ladder as Area2D
		if other == null or other == self:
			continue
		if body in other.get_overlapping_bodies():
			return
	body.set_on_ladder(false)
