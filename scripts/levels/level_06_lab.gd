extends LevelBase


func _build() -> void:
	LevelKit.build_sky(self, pal)

	var backdrop := LevelKit.Batch.new()
	backdrop.z_index = -17
	add_child(backdrop)
	backdrop.rect(Rect2(-300, 80, level_width + 600, 1000), Color("#050f0c"))
	for i in int(level_width / 160.0) + 1:
		backdrop.rect(Rect2(i * 160.0, 300, 2, 360), Color(1, 1, 1, 0.045))
	for i in int(level_width / 420.0) + 1:
		backdrop.rect(Rect2(i * 420.0 + 90, 220, 240, 70), Color(0, 0, 0, 0.28))
		backdrop.rect(Rect2(i * 420.0 + 100, 232, 220, 46), Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.04))
	backdrop.flush()

	LevelKit.add_ground(self, 0, level_width, 660, pal, 900, 3)
	LevelKit.add_wall(self, Rect2(-260, 120, 260, 1000), pal)
	LevelKit.add_wall(self, Rect2(level_width, 120, 260, 1000), pal)

	var ceiling := LevelKit.Batch.new()
	ceiling.z_index = -3
	add_child(ceiling)
	ceiling.rect(Rect2(0, 150, level_width, 80), pal["detail"])
	ceiling.rect(Rect2(0, 230, level_width, 5), pal["edge"])
	for i in int(level_width / 240.0):
		ceiling.rect(Rect2(i * 240.0 + 40, 236, 90, 12), Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.35))
	ceiling.flush()

	var props := LevelKit.Batch.new()
	props.z_index = -1
	add_child(props)
	props.rect(Rect2(430, 500, 200, 160), pal["detail"])
	props.rect(Rect2(430, 500, 200, 4), pal["edge"])
	props.rect(Rect2(430, 580, 200, 3), Color(1, 1, 1, 0.08))
	props.rect(Rect2(2250, 470, 170, 190), pal["detail"])
	props.rect(Rect2(2250, 470, 170, 4), pal["edge"])
	props.rect(Rect2(2280, 500, 110, 60), Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.12))
	props.rect(Rect2(2900, 540, 160, 120), pal["detail"])
	props.rect(Rect2(2900, 540, 160, 4), pal["edge"])
	props.flush()

	LevelKit.add_spikes(self, Vector2(800, 660), 160, pal)
	LevelKit.add_laser(self, Vector2(1120, 300), Vector2(1120, 656), Color("#ff4d5e"), 2.4, 0.0)
	LevelKit.add_laser(self, Vector2(1520, 300), Vector2(1520, 656), Color("#ff4d5e"), 2.4, 0.8)
	LevelKit.add_laser(self, Vector2(1920, 300), Vector2(1920, 656), Color("#ff4d5e"), 2.4, 1.6)
	LevelKit.add_laser(self, Vector2(2150, 520), Vector2(2520, 520), Color("#ff7a7a"), 2.1, 0.5)

	var door := LevelKit.add_door(self, Rect2(2760, 420, 90, 240), pal)
	LevelKit.add_switch(self, Vector2(2600, 660), door, pal)

	for i in 7:
		LevelKit.add_ceiling_light(self, Vector2(260.0 + i * 460.0, 240), Color(pal["accent"]), 120)
		_floor_light(260.0 + i * 460.0)
	LevelKit.add_checkpoint(self, Vector2(1680, 604), pal)
	LevelKit.add_checkpoint(self, Vector2(2420, 604), pal)
	add_finish_marker()
	LevelKit.add_post_fx(self, pal, 0.6, 0.045, Color(0.0, 0.04, 0.02, 0.12))
	LevelKit.add_dust($Camera2D, Color(0.6, 1.0, 0.8, 0.16), 40)


func _floor_light(x: float) -> void:
	var light := PointLight2D.new()
	light.texture = LevelKit.radial_texture()
	light.color = Color(pal["accent"].r, pal["accent"].g, pal["accent"].b)
	light.energy = 0.5
	light.texture_scale = 1.3
	light.position = Vector2(x, 280)
	add_child(light)
