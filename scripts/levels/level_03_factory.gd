extends LevelBase


func _build() -> void:
	LevelKit.build_sky(self, pal)
	LevelKit.add_parallax_city(self, pal, 61, 0.14, 900.0, 380, 560, false, false, -18)
	LevelKit.add_parallax_city(self, pal, 83, 0.4, 940.0, 440, 690, true, false, -16)
	LevelKit.add_scroll_strip(self, pal, 905.0, 0.8, 34, 12, 6)
	LevelKit.add_ground(self, 0, 1500, 660, pal, 900, 3)
	LevelKit.add_ground(self, 1900, 2500, 660, pal, 900, 4)
	LevelKit.add_ground(self, 2900, level_width, 660, pal, 900, 5)
	LevelKit.add_moving_platform(self, Vector2(1560, 700), Vector2(200, 34), Vector2(310, 0), 3.6, pal)
	LevelKit.add_moving_platform(self, Vector2(2570, 700), Vector2(200, 34), Vector2(290, 0), 3.0, pal)
	LevelKit.add_crusher(self, Vector2(2180, 380), Vector2(220, 190), 235, pal)
	var door := LevelKit.add_door(self, Rect2(3210, 420, 90, 240), pal)
	LevelKit.add_switch(self, Vector2(3020, 660), door, pal)

	var props := LevelKit.Batch.new()
	props.z_index = -1
	add_child(props)
	props.rect(Rect2(300, 470, 26, 190), pal["detail"])
	props.rect(Rect2(260, 448, 110, 26), pal["detail"])
	props.rect(Rect2(262, 380, 20, 74), pal["detail"])
	props.rect(Rect2(352, 400, 18, 54), pal["detail"])
	props.rect(Rect2(700, 366, 46, 294), pal["detail"])
	props.rect(Rect2(676, 352, 94, 20), pal["detail"])
	props.rect(Rect2(1060, 520, 190, 18), pal["detail"])
	props.rect(Rect2(1080, 538, 14, 122), pal["detail"])
	props.rect(Rect2(1216, 538, 14, 122), pal["detail"])
	props.rect(Rect2(2060, 460, 60, 200), pal["detail"])
	props.rect(Rect2(2300, 500, 20, 160), pal["detail"])
	props.rect(Rect2(2960, 430, 70, 230), pal["detail"])
	props.rect(Rect2(2940, 414, 110, 22), pal["detail"])
	props.flush()

	for i in 3:
		var fx := 560.0 + i * 780.0
		LevelKit.add_glow(self, Vector2(fx, 600), Color("#ff7a2e"), 1.5, 0.22, 0)
	LevelKit.add_glow(self, Vector2(1800, 470), Color("#ffb066"), 2.0, 0.18, -13)
	LevelKit.add_lamp(self, Vector2(980, 660), pal, 240)
	LevelKit.add_lamp(self, Vector2(2380, 660), pal, 220)
	LevelKit.add_checkpoint(self, Vector2(1100, 644), pal)
	LevelKit.add_checkpoint(self, Vector2(2760, 644), pal)
	add_finish_marker()
	LevelKit.add_post_fx(self, pal, 0.64, 0.055, Color(0.06, 0.02, 0.0, 0.12))
	LevelKit.add_embers($Camera2D, Color(1.0, 0.6, 0.22, 0.55), 85)
	LevelKit.add_dust($Camera2D, Color(0.95, 0.75, 0.55, 0.14), 30)
