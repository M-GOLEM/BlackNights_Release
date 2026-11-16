extends LevelBase


func _build() -> void:
	LevelKit.build_sky(self, pal)
	LevelKit.add_stars(self, 7)
	LevelKit.add_moon(self, Vector2(1390, 250), Color("#ccd6ea"), 220.0)
	LevelKit.add_parallax_city(self, pal, 11, 0.16, 700.0, 300, 540, false, false, -18)
	LevelKit.add_parallax_city(self, pal, 23, 0.42, 720.0, 400, 640, true, false, -16)
	LevelKit.add_scroll_strip(self, pal, 676, 0.8, 26, 5, 6)
	LevelKit.add_ground(self, 0, level_width, 620, pal, 900, 3)
	LevelKit.add_platform(self, Rect2(1180, 536, 220, 84), pal)
	LevelKit.add_platform(self, Rect2(2320, 514, 220, 106), pal)

	var props := LevelKit.Batch.new()
	props.z_index = -1
	add_child(props)
	_dead_tree(props, 705, 620, 250)
	_dead_tree(props, 1760, 620, 200)
	_dead_tree(props, 2760, 620, 280)
	props.rect(Rect2(880, 606, 160, 14), pal["detail"])
	props.rect(Rect2(900, 596, 40, 10), pal["detail"])
	props.rect(Rect2(2560, 592, 44, 28), pal["detail"])
	props.rect(Rect2(2540, 606, 84, 14), pal["detail"])
	props.flush()

	LevelKit.add_lamp(self, Vector2(820, 620), pal, 230)
	LevelKit.add_lamp(self, Vector2(1900, 620), pal, 250)
	LevelKit.add_lamp(self, Vector2(2940, 620), pal, 220)
	LevelKit.add_fog(self, Vector2(1100, 470), Vector2(1500, 280), Color("#7486a6"), 0.07, -10)
	LevelKit.add_fog(self, Vector2(2400, 540), Vector2(1300, 240), Color("#5d6d8c"), 0.06, -10)
	LevelKit.add_checkpoint(self, Vector2(1600, 604), pal)
	add_finish_marker()
	LevelKit.add_post_fx(self, pal, 0.62, 0.05)
	LevelKit.add_dust($Camera2D, Color(0.75, 0.8, 0.95, 0.2), 42)


func _dead_tree(batch: LevelKit.Batch, x: float, base_y: float, height: float) -> void:
	var trunk: Color = pal["detail"]
	batch.rect(Rect2(x - 5, base_y - height, 10, height), trunk)
	batch.poly(PackedVector2Array([
		Vector2(x - 4, base_y - height * 0.62), Vector2(x - 58, base_y - height * 0.86),
		Vector2(x - 56, base_y - height * 0.8), Vector2(x - 4, base_y - height * 0.54),
	]), trunk)
	batch.poly(PackedVector2Array([
		Vector2(x + 4, base_y - height * 0.74), Vector2(x + 52, base_y - height * 0.95),
		Vector2(x + 50, base_y - height * 0.89), Vector2(x + 4, base_y - height * 0.66),
	]), trunk)
	batch.poly(PackedVector2Array([
		Vector2(x - 3, base_y - height * 0.9), Vector2(x - 30, base_y - height * 1.02),
		Vector2(x - 29, base_y - height * 0.97), Vector2(x - 3, base_y - height * 0.84),
	]), trunk)
