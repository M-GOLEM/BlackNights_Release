extends LevelBase

var _flash: ColorRect


func _build() -> void:
	LevelKit.build_sky(self, pal)
	LevelKit.add_parallax_city(self, pal, 91, 0.1, 1400.0, 700, 1100, false, true, -18)
	LevelKit.add_parallax_city(self, pal, 113, 0.3, 1500.0, 900, 1400, true, false, -17)

	var facade := LevelKit.Batch.new()
	facade.z_index = -16
	add_child(facade)
	facade.rect(Rect2(-300, -200, 360, 3600), Color("#0d0917"))
	facade.rect(Rect2(1040, -200, 360, 3600), Color("#0d0917"))
	for i in 34:
		var wy := 40.0 + i * 96.0
		for j in 3:
			facade.rect(Rect2(-250 + j * 90.0, wy, 34, 44), Color(pal["windows"].r, pal["windows"].g, pal["windows"].b, 0.16 + 0.05 * ((i + j) % 3)))
			facade.rect(Rect2(1090 + j * 90.0, wy, 34, 44), Color(pal["windows"].r, pal["windows"].g, pal["windows"].b, 0.14 + 0.05 * ((i + j) % 4)))
	facade.flush()

	var ground_batch := LevelKit.Batch.new()
	ground_batch.z_index = -2
	add_child(ground_batch)
	ground_batch.rect(Rect2(0, 3220, 1400, 400), pal["ground"])
	ground_batch.rect(Rect2(0, 3220, 1400, 3), pal["edge"])
	ground_batch.flush()

	var body := StaticBody2D.new()
	add_child(body)
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(1400, 400)
	shape.shape = r
	shape.position = Vector2(700, 3420)
	body.add_child(shape)
	var wall_shape := CollisionShape2D.new()
	var wr := RectangleShape2D.new()
	wr.size = Vector2(60, 3600)
	wall_shape.shape = wr
	wall_shape.position = Vector2(-30, 1600)
	body.add_child(wall_shape)
	var wall_shape_r := CollisionShape2D.new()
	wall_shape_r.shape = wr
	wall_shape_r.position = Vector2(1430, 1600)
	body.add_child(wall_shape_r)

	var ledges := [2860.0, 2500.0, 2140.0, 1780.0, 1420.0, 1060.0, 700.0]
	for i in ledges.size():
		var top: float = ledges[i]
		if i % 2 == 0:
			LevelKit.add_platform(self, Rect2(0, top, 680, 60), pal)
		else:
			LevelKit.add_platform(self, Rect2(760, top, 640, 60), pal)

	# A continuous 80px shaft runs between x=680 and x=760; the ladders live
	# inside it, so a climb never runs into the underside of a ledge.
	var ladders := [
		Rect2(690, 2770, 60, 450),
		Rect2(690, 2410, 60, 450),
		Rect2(690, 2050, 60, 450),
		Rect2(690, 1690, 60, 450),
		Rect2(690, 1330, 60, 450),
		Rect2(690, 970, 60, 450),
		Rect2(690, 610, 60, 450),
	]
	for ladder in ladders:
		LevelKit.add_ladder(self, ladder, pal)

	var props := LevelKit.Batch.new()
	props.z_index = -1
	add_child(props)
	props.rect(Rect2(120, 2920, 18, 300), pal["detail"])
	props.rect(Rect2(1262, 2920, 18, 300), pal["detail"])
	props.rect(Rect2(120, 2380, 18, 120), pal["detail"])
	props.rect(Rect2(1262, 2380, 18, 120), pal["detail"])
	props.rect(Rect2(120, 1550, 18, 230), pal["detail"])
	props.rect(Rect2(1262, 1550, 18, 230), pal["detail"])
	props.rect(Rect2(120, 830, 18, 230), pal["detail"])
	props.rect(Rect2(1262, 830, 18, 230), pal["detail"])
	props.flush()

	LevelKit.add_glow(self, Vector2(700, 2560), Color("#a98ce6"), 2.2, 0.1, -14)
	LevelKit.add_glow(self, Vector2(700, 1600), Color("#a98ce6"), 2.0, 0.08, -14)
	LevelKit.add_fog(self, Vector2(700, 2900), Vector2(1300, 500), Color("#514184"), 0.1, -10)
	LevelKit.add_fog(self, Vector2(700, 1900), Vector2(1200, 500), Color("#453a70"), 0.09, -10)
	LevelKit.add_fog(self, Vector2(700, 900), Vector2(1200, 500), Color("#453a70"), 0.08, -10)
	LevelKit.add_checkpoint(self, Vector2(300, 2800), pal)
	LevelKit.add_checkpoint(self, Vector2(1100, 1720), pal)
	add_finish_marker()
	LevelKit.add_post_fx(self, pal, 0.64, 0.055, Color(0.03, 0.01, 0.06, 0.16))
	LevelKit.add_dust($Camera2D, Color(0.75, 0.7, 0.95, 0.2), 55)
	_build_lightning()


func _build_lightning() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 13
	add_child(layer)
	_flash = ColorRect.new()
	_flash.color = Color(0.75, 0.8, 1.0, 0.0)
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_flash)
	var timer := Timer.new()
	timer.wait_time = 7.5
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_strike)


func _strike() -> void:
	var tween := create_tween()
	tween.tween_property(_flash, "color:a", 0.28, 0.05)
	tween.tween_property(_flash, "color:a", 0.02, 0.09)
	tween.tween_property(_flash, "color:a", 0.18, 0.05)
	tween.tween_property(_flash, "color:a", 0.0, 0.3)
