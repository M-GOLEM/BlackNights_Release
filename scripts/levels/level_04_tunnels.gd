extends LevelBase


func _build() -> void:
	LevelKit.build_sky(self, pal)

	var backdrop := LevelKit.Batch.new()
	backdrop.z_index = -17
	add_child(backdrop)
	backdrop.rect(Rect2(-200, 140, level_width + 400, 1060), Color("#07070b"))
	for i in int(level_width / 220.0) + 1:
		backdrop.rect(Rect2(i * 220.0, 160, 3, 520), Color(1, 1, 1, 0.035))
	for i in int(level_width / 380.0) + 1:
		backdrop.rect(Rect2(i * 380.0 + 60, 240, 120, 46), Color(0, 0, 0, 0.25))
	backdrop.flush()

	LevelKit.add_ground(self, 0, level_width, 660, pal, 900, 3)
	LevelKit.add_wall(self, Rect2(-260, 120, 260, 1000), pal)
	LevelKit.add_wall(self, Rect2(level_width, 120, 260, 1000), pal)

	var ceiling := LevelKit.Batch.new()
	ceiling.z_index = -3
	add_child(ceiling)
	ceiling.rect(Rect2(0, 100, level_width, 90), pal["detail"])
	ceiling.rect(Rect2(0, 190, level_width, 6), pal["edge"])
	for i in int(level_width / 110.0):
		ceiling.rect(Rect2(i * 110.0 + 30, 196, 16, 26), Color(0, 0, 0, 0.4))
	ceiling.rect(Rect2(0, 90, level_width, 6), Color(pal["edge"].r, pal["edge"].g, pal["edge"].b, 0.5))
	ceiling.flush()

	var props := LevelKit.Batch.new()
	props.z_index = -1
	add_child(props)
	props.rect(Rect2(420, 535, 240, 125), pal["detail"])
	props.rect(Rect2(420, 535, 240, 4), pal["edge"])
	props.rect(Rect2(1480, 570, 220, 90), pal["detail"])
	props.rect(Rect2(1480, 570, 220, 4), pal["edge"])
	props.rect(Rect2(2210, 520, 120, 140), pal["detail"])
	props.rect(Rect2(2210, 520, 120, 4), pal["edge"])
	for i in 8:
		props.rect(Rect2(180 + i * 350.0, 196, 10, 26), pal["detail"])
	props.flush()

	LevelKit.add_spikes(self, Vector2(980, 660), 180, pal)
	LevelKit.add_spikes(self, Vector2(1960, 660), 150, pal)
	LevelKit.add_spikes(self, Vector2(2520, 660), 190, pal)

	for i in 6:
		var lx := 300.0 + i * 470.0
		var warm := Color(1.0, 0.78, 0.52)
		LevelKit.add_ceiling_light(self, Vector2(lx, 196), warm, 96)
		_ceiling_lamp(lx, 214, warm)
	_red_lamp(1080, 300)
	_red_lamp(2080, 300)
	_red_lamp(2820, 300)

	var dark := CanvasModulate.new()
	dark.color = Color(0.42, 0.43, 0.52)
	add_child(dark)
	LevelKit.add_lantern($CharacterRoot)

	LevelKit.add_checkpoint(self, Vector2(1650, 604), pal)
	add_finish_marker()
	LevelKit.add_post_fx(self, pal, 0.72, 0.06, Color(0.0, 0.005, 0.02, 0.28))
	LevelKit.add_dust($Camera2D, Color(0.7, 0.72, 0.85, 0.22), 50)


func _ceiling_lamp(x: float, y: float, color: Color) -> void:
	var light := PointLight2D.new()
	light.texture = LevelKit.radial_texture()
	light.color = color
	light.energy = 0.5
	light.texture_scale = 0.85
	light.position = Vector2(x, y)
	add_child(light)


func _red_lamp(x: float, y: float) -> void:
	var light := PointLight2D.new()
	light.texture = LevelKit.radial_texture()
	light.color = Color(1.0, 0.22, 0.18)
	light.energy = 0.5
	light.texture_scale = 0.55
	light.position = Vector2(x, y)
	add_child(light)
	LevelKit.add_glow(self, Vector2(x, y), Color(1.0, 0.28, 0.22), 0.42, 0.38)
