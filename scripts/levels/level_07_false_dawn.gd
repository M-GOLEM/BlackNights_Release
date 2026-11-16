extends LevelBase


func _build() -> void:
	LevelKit.build_sky(self, pal)
	LevelKit.add_sun(self, Vector2(3560, 260), Color("#ffcf8a"), 900.0)
	LevelKit.add_glow(self, Vector2(3560, 260), Color("#ffb264"), 6.0, 0.16, -15)
	LevelKit.add_parallax_city(self, pal, 131, 0.12, 900.0, 320, 500, false, false, -18)
	LevelKit.add_parallax_city(self, pal, 147, 0.36, 940.0, 420, 620, true, false, -16)
	LevelKit.add_scroll_strip(self, pal, 892.0, 0.78, 30, 17, 6)

	LevelKit.add_ground(self, 0, 1800, 660, pal, 900, 3)
	LevelKit.add_ground(self, 2000, 3000, 660, pal, 900, 4)
	LevelKit.add_ground(self, 3200, level_width, 660, pal, 900, 5)
	LevelKit.add_platform(self, Rect2(1840, 596, 66, 26), pal)
	LevelKit.add_platform(self, Rect2(3040, 596, 66, 26), pal)

	var ruins := LevelKit.Batch.new()
	ruins.z_index = -1
	add_child(ruins)
	ruins.rect(Rect2(520, 430, 40, 230), pal["detail"])
	ruins.rect(Rect2(504, 416, 72, 18), pal["detail"])
	ruins.rect(Rect2(1080, 520, 300, 14), pal["detail"])
	ruins.rect(Rect2(1100, 534, 18, 126), pal["detail"])
	ruins.rect(Rect2(1350, 534, 18, 126), pal["detail"])
	ruins.rect(Rect2(2280, 380, 60, 280), pal["detail"])
	ruins.rect(Rect2(2256, 364, 108, 20), pal["detail"])
	ruins.rect(Rect2(3060, 470, 34, 190), pal["detail"])
	ruins.rect(Rect2(3350, 540, 180, 10), pal["detail"])
	ruins.rect(Rect2(3490, 420, 26, 240), pal["detail"])
	ruins.flush()

	for i in 4:
		LevelKit.add_glow(self, Vector2(900.0 + i * 860.0, 560.0), Color("#ffb066"), 1.6, 0.14, 0)
	var birds := LevelKit.Batch.new()
	birds.z_index = -14
	add_child(birds)
	var bird_spots := [Vector2(1500, 200), Vector2(1580, 170), Vector2(1650, 210)]
	for spot in bird_spots:
		birds.poly(PackedVector2Array([spot + Vector2(-14, 0), spot + Vector2(-4, -8), spot + Vector2(0, -2)]), Color(0.15, 0.08, 0.1, 0.7))
		birds.poly(PackedVector2Array([spot + Vector2(0, -2), spot + Vector2(4, -8), spot + Vector2(14, 0)]), Color(0.15, 0.08, 0.1, 0.7))
	birds.flush()

	LevelKit.add_fog(self, Vector2(1400, 520), Vector2(1600, 300), Color("#e08a5e"), 0.1, -10)
	LevelKit.add_fog(self, Vector2(3200, 480), Vector2(1500, 320), Color("#ffb87a"), 0.12, -10)
	LevelKit.add_checkpoint(self, Vector2(2200, 604), pal)
	LevelKit.add_checkpoint(self, Vector2(3450, 604), pal)
	add_finish_marker()
	LevelKit.add_post_fx(self, pal, 0.5, 0.05, Color(0.08, 0.03, 0.0, 0.08))
	LevelKit.add_dust($Camera2D, Color(1.0, 0.86, 0.66, 0.24), 60)
