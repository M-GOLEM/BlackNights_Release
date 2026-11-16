class_name LevelKit
extends RefCounted

const VIEW_W := 1920.0
const REPEAT_W := 1920.0

static var _radial: Texture2D
static var _streak: Texture2D
static var _dot: Texture2D


class Batch extends Node2D:
	var items: Array = []

	func rect(r: Rect2, c: Color) -> void:
		items.append([r, c])

	func poly(points: PackedVector2Array, c: Color) -> void:
		items.append([points, c])

	func flush() -> void:
		queue_redraw()

	func _draw() -> void:
		for item in items:
			var shape = item[0]
			if shape is Rect2:
				draw_rect(shape, item[1])
			else:
				draw_colored_polygon(shape, item[1])


static func palette(chapter: int) -> Dictionary:
	match chapter:
		1:
			return {
				"sky_top": Color("#05050a"), "sky_mid": Color("#14141d"), "sky_bottom": Color("#25252f"),
				"far": Color("#101017"), "mid": Color("#17171f"), "near": Color("#07070a"),
				"ground": Color("#1a1a20"), "edge": Color("#3d3d49"), "detail": Color("#232329"),
				"accent": Color("#9db4d8"), "accent2": Color("#4a5a75"), "windows": Color("#cfe0ff"),
				"ambient": Color(1, 1, 1, 1),
			}
		2:
			return {
				"sky_top": Color("#040d12"), "sky_mid": Color("#082027"), "sky_bottom": Color("#0e3038"),
				"far": Color("#0a1e24"), "mid": Color("#0d262d"), "near": Color("#040d10"),
				"ground": Color("#10262b"), "edge": Color("#2f6470"), "detail": Color("#173238"),
				"accent": Color("#63d9de"), "accent2": Color("#2c7c86"), "windows": Color("#8ff2f0"),
				"ambient": Color(1, 1, 1, 1),
			}
		3:
			return {
				"sky_top": Color("#0a0503"), "sky_mid": Color("#1d0e06"), "sky_bottom": Color("#3a1c0b"),
				"far": Color("#180d07"), "mid": Color("#23120a"), "near": Color("#0a0503"),
				"ground": Color("#1b100a"), "edge": Color("#75401d"), "detail": Color("#2a180d"),
				"accent": Color("#ff8a3d"), "accent2": Color("#a3491c"), "windows": Color("#ffbf6e"),
				"ambient": Color(1, 1, 1, 1),
			}
		4:
			return {
				"sky_top": Color("#020203"), "sky_mid": Color("#07070b"), "sky_bottom": Color("#0c0c12"),
				"far": Color("#08080c"), "mid": Color("#0b0b11"), "near": Color("#040406"),
				"ground": Color("#0d0d12"), "edge": Color("#2c2c36"), "detail": Color("#14141a"),
				"accent": Color("#ff4b4b"), "accent2": Color("#8d2a2a"), "windows": Color("#ffd9a8"),
				"ambient": Color(0.55, 0.58, 0.66, 1),
			}
		5:
			return {
				"sky_top": Color("#05030a"), "sky_mid": Color("#120c22"), "sky_bottom": Color("#241838"),
				"far": Color("#0e0a1a"), "mid": Color("#170f26"), "near": Color("#060409"),
				"ground": Color("#120e1d"), "edge": Color("#4d3c72"), "detail": Color("#1a1428"),
				"accent": Color("#a98ce6"), "accent2": Color("#5a4488"), "windows": Color("#d9c6ff"),
				"ambient": Color(1, 1, 1, 1),
			}
		6:
			return {
				"sky_top": Color("#03080a"), "sky_mid": Color("#081713"), "sky_bottom": Color("#0d211c"),
				"far": Color("#071411"), "mid": Color("#0a1d18"), "near": Color("#030a08"),
				"ground": Color("#0a1512"), "edge": Color("#2f7562"), "detail": Color("#10211c"),
				"accent": Color("#59ffc4"), "accent2": Color("#1f7a60"), "windows": Color("#b7ffe8"),
				"ambient": Color(1, 1, 1, 1),
			}
		_:
			return {
				"sky_top": Color("#241433"), "sky_mid": Color("#6b3550"), "sky_bottom": Color("#f09a63"),
				"far": Color("#3a2438"), "mid": Color("#4c2b3a"), "near": Color("#1b1020"),
				"ground": Color("#251821"), "edge": Color("#a8715c"), "detail": Color("#2f1e28"),
				"accent": Color("#ffd39b"), "accent2": Color("#e0784f"), "windows": Color("#ffe3b5"),
				"ambient": Color(1, 1, 1, 1),
			}


static func build_sky(level: Node, pal: Dictionary) -> void:
	var layer := CanvasLayer.new()
	layer.layer = -20
	level.add_child(layer)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.62, 1.0])
	gradient.colors = PackedColorArray([pal["sky_top"], pal["sky_mid"], pal["sky_bottom"]])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 4
	tex.height = 512
	var rect := TextureRect.new()
	rect.texture = tex
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)


static func add_moon(level: Node, pos: Vector2, color: Color, radius: float) -> void:
	var glow := Sprite2D.new()
	glow.texture = radial_texture()
	glow.position = pos
	glow.scale = Vector2.ONE * radius * 0.014
	glow.modulate = Color(color.r, color.g, color.b, 0.28)
	glow.material = _add_material()
	glow.z_index = -19
	level.add_child(glow)
	var core := Sprite2D.new()
	core.texture = radial_texture()
	core.position = pos
	core.scale = Vector2.ONE * radius * 0.0038
	core.modulate = color
	core.z_index = -19
	level.add_child(core)


static func add_sun(level: Node, pos: Vector2, color: Color, radius: float) -> void:
	add_moon(level, pos, color, radius)


static func add_parallax_city(level: Node, pal: Dictionary, seed_value: int, scroll: float, base_y: float, min_h: float, max_h: float, windows: bool, stars := false, z := -18) -> void:
	var parallax := Parallax2D.new()
	parallax.scroll_scale = Vector2(scroll, 0.0)
	parallax.repeat_size = Vector2(REPEAT_W, 0.0)
	parallax.z_index = z
	level.add_child(parallax)

	var batch := Batch.new()
	parallax.add_child(batch)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var color: Color = pal["far"] if scroll < 0.3 else (pal["mid"] if scroll < 0.6 else pal["near"])

	if stars:
		for i in 70:
			var sx := rng.randf_range(0, REPEAT_W)
			var sy := rng.randf_range(-620, -120)
			var s := rng.randf_range(1.0, 2.4)
			batch.rect(Rect2(sx, sy, s, s), Color(0.75, 0.8, 1.0, rng.randf_range(0.15, 0.65)))

	var x := 0.0
	while x < REPEAT_W:
		var w := rng.randf_range(90, 230)
		var h := rng.randf_range(min_h, max_h)
		var top := base_y - h
		batch.rect(Rect2(x, top, w, h), color)
		if rng.randf() < 0.4:
			var roof_w := w * rng.randf_range(0.2, 0.5)
			batch.rect(Rect2(x + w * 0.5 - roof_w * 0.5, top - rng.randf_range(14, 46), roof_w, 46), color)
		if rng.randf() < 0.25:
			batch.rect(Rect2(x + w * 0.7, top - rng.randf_range(40, 120), 3, 120), color)
		if windows:
			var win_color: Color = pal["windows"]
			var floors := int(h / 62.0)
			var cols := int(w / 46.0)
			for fy in floors:
				for fx in cols:
					if rng.randf() < 0.42:
						var wr := Rect2(x + 14 + fx * 46.0, top + 20 + fy * 62.0, 10, 16)
						if wr.position.y < base_y - 12:
							batch.rect(wr, Color(win_color.r, win_color.g, win_color.b, rng.randf_range(0.18, 0.75)))
		x += w + rng.randf_range(6, 30)
	batch.flush()


static func add_ground(level: Node, from_x: float, to_x: float, top_y: float, pal: Dictionary, thickness := 900.0, seed_value := 1) -> void:
	var batch := Batch.new()
	batch.name = "Ground"
	batch.z_index = -2
	level.add_child(batch)
	batch.rect(Rect2(from_x, top_y, to_x - from_x, thickness), pal["ground"])
	batch.rect(Rect2(from_x, top_y, to_x - from_x, 3.0), pal["edge"])
	batch.rect(Rect2(from_x, top_y + 3.0, to_x - from_x, 5.0), Color(pal["edge"].r, pal["edge"].g, pal["edge"].b, 0.18))
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var x := from_x
	while x < to_x:
		var gap := rng.randf_range(60, 180)
		batch.rect(Rect2(x, top_y + rng.randf_range(14, 24), gap * 0.7, 2), Color(1, 1, 1, 0.035))
		x += gap
	for i in int((to_x - from_x) / 90.0):
		var sx := rng.randf_range(from_x, to_x)
		var sy := top_y + rng.randf_range(30, 260)
		var sw := rng.randf_range(10, 44)
		batch.rect(Rect2(sx, sy, sw, rng.randf_range(2, 5)), Color(0, 0, 0, 0.16))
	batch.flush()

	var body := StaticBody2D.new()
	body.name = "GroundBody"
	level.add_child(body)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(to_x - from_x, thickness)
	shape.shape = rect
	shape.position = Vector2((from_x + to_x) * 0.5, top_y + thickness * 0.5)
	body.add_child(shape)


static func add_platform(level: Node, rect: Rect2, pal: Dictionary, single_way := false) -> void:
	var batch := Batch.new()
	level.add_child(batch)
	batch.z_index = -1
	batch.rect(rect, pal["ground"])
	batch.rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 3.0), pal["edge"])
	batch.rect(Rect2(rect.position.x + 4, rect.position.y + 3, rect.size.x - 8, 4), Color(0, 0, 0, 0.25))
	for i in int(rect.size.x / 54.0):
		batch.rect(Rect2(rect.position.x + 16 + i * 54.0, rect.position.y + 18, 3, rect.size.y - 24), Color(0, 0, 0, 0.18))
	batch.flush()

	var body := StaticBody2D.new()
	level.add_child(body)
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = rect.size
	shape.shape = r
	shape.position = rect.position + rect.size * 0.5
	shape.one_way_collision = single_way
	body.add_child(shape)


static func add_wall(level: Node, rect: Rect2, pal: Dictionary) -> void:
	var batch := Batch.new()
	level.add_child(batch)
	batch.rect(rect, pal["detail"])
	batch.rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 2), pal["edge"])
	for i in int(rect.size.y / 70.0):
		batch.rect(Rect2(rect.position.x, rect.position.y + i * 70.0, rect.size.x, 2), Color(0, 0, 0, 0.15))
	batch.flush()
	var body := StaticBody2D.new()
	level.add_child(body)
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = rect.size
	shape.shape = r
	shape.position = rect.position + rect.size * 0.5
	body.add_child(shape)


static func add_lamp(level: Node, pos: Vector2, pal: Dictionary, height := 210.0, glow_scale := 1.0, reflect := false) -> void:
	var batch := Batch.new()
	level.add_child(batch)
	batch.z_index = 1
	batch.rect(Rect2(pos.x - 3, pos.y - height, 6, height), pal["detail"])
	batch.rect(Rect2(pos.x - 22, pos.y - height, 44, 7), pal["edge"])
	batch.rect(Rect2(pos.x - 7, pos.y - height + 2, 14, 16), Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.85))
	batch.flush()
	var head := pos + Vector2(0, -height + 8)
	var base := Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.32)
	var cone := Sprite2D.new()
	cone.texture = radial_texture()
	cone.position = head + Vector2(0, height * 0.35)
	cone.scale = Vector2(2.6 * glow_scale, height * 0.011)
	cone.modulate = Color(base.r, base.g, base.b, 0.07)
	cone.material = _add_material()
	cone.z_index = 0
	level.add_child(cone)
	var glow := Sprite2D.new()
	glow.texture = radial_texture()
	glow.position = head
	glow.scale = Vector2.ONE * 0.9 * glow_scale
	glow.modulate = base
	glow.material = _add_material()
	glow.z_index = 1
	level.add_child(glow)
	var flicker := level.create_tween().set_loops()
	flicker.tween_callback(func() -> void:
		var a := randf_range(0.24, 0.38)
		glow.modulate = Color(base.r, base.g, base.b, a)
		cone.modulate = Color(base.r, base.g, base.b, a * 0.22))
	flicker.tween_interval(1.1)
	if reflect:
		var puddle := Sprite2D.new()
		puddle.texture = radial_texture()
		puddle.position = pos + Vector2(0, 16)
		puddle.scale = Vector2(1.5 * glow_scale, 7.2)
		puddle.modulate = Color(base.r, base.g, base.b, 0.16)
		puddle.material = _add_material()
		puddle.z_index = -1
		level.add_child(puddle)


static func add_glow(level: Node, pos: Vector2, color: Color, scale_size: float, alpha := 0.4, z := 1) -> Sprite2D:
	var glow := Sprite2D.new()
	glow.texture = radial_texture()
	glow.position = pos
	glow.scale = Vector2.ONE * scale_size
	glow.modulate = Color(color.r, color.g, color.b, alpha)
	glow.material = _add_material()
	glow.z_index = z
	level.add_child(glow)
	return glow


static func add_fog(level: Node, pos: Vector2, size: Vector2, color: Color, alpha: float, z := -15) -> void:
	var fog := Sprite2D.new()
	fog.texture = radial_texture()
	fog.position = pos
	fog.scale = Vector2(size.x * 0.011, size.y * 0.011)
	fog.modulate = Color(color.r, color.g, color.b, alpha)
	fog.z_index = z
	level.add_child(fog)


static func add_stars(level: Node, seed_value: int) -> void:
	var batch := Batch.new()
	batch.z_index = -19
	level.add_child(batch)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in 90:
		var s := rng.randf_range(1.0, 2.6)
		batch.rect(Rect2(rng.randf_range(0, REPEAT_W), rng.randf_range(-640, -90), s, s), Color(0.8, 0.85, 1.0, rng.randf_range(0.12, 0.7)))
	batch.flush()


static func add_checkpoint(level: Node, pos: Vector2, pal: Dictionary) -> void:
	var area := Area2D.new()
	area.position = pos
	area.add_to_group("checkpoints")
	area.collision_layer = 0
	area.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 52.0
	shape.shape = circle
	area.add_child(shape)
	var batch := Batch.new()
	area.add_child(batch)
	var c: Color = pal["accent"]
	batch.rect(Rect2(-2, -86, 4, 86), pal["detail"])
	batch.rect(Rect2(-12, -96, 24, 12), Color(c.r, c.g, c.b, 0.9))
	batch.flush()
	var glow := Sprite2D.new()
	glow.texture = radial_texture()
	glow.position = Vector2(0, -90)
	glow.scale = Vector2.ONE * 0.55
	glow.modulate = Color(c.r, c.g, c.b, 0.35)
	glow.material = _add_material()
	area.add_child(glow)
	var pulse := area.create_tween().set_loops()
	pulse.tween_property(glow, "modulate:a", 0.62, 0.9).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(glow, "modulate:a", 0.22, 0.9).set_trans(Tween.TRANS_SINE)
	level.add_child(area)


static func add_finish(level: Node, pos: Vector2, pal: Dictionary) -> void:
	var area := Area2D.new()
	area.position = pos
	area.add_to_group("finish")
	area.collision_layer = 0
	area.collision_mask = 1
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(90, 260)
	shape.shape = r
	shape.position = Vector2(0, -110)
	area.add_child(shape)

	var batch := Batch.new()
	area.add_child(batch)
	var c: Color = pal["accent"]
	batch.rect(Rect2(-55, -250, 110, 250), Color(c.r * 0.22, c.g * 0.22, c.b * 0.24, 1))
	batch.rect(Rect2(-55, -250, 6, 250), Color(c.r, c.g, c.b, 0.55))
	batch.rect(Rect2(49, -250, 6, 250), Color(c.r, c.g, c.b, 0.55))
	batch.rect(Rect2(-55, -250, 110, 5), Color(c.r, c.g, c.b, 0.55))
	batch.flush()
	var glow := Sprite2D.new()
	glow.texture = radial_texture()
	glow.position = Vector2(0, -120)
	glow.scale = Vector2(1.1, 1.7)
	glow.modulate = Color(c.r, c.g, c.b, 0.22)
	glow.material = _add_material()
	area.add_child(glow)
	var pulse := area.create_tween().set_loops()
	pulse.tween_property(glow, "modulate:a", 0.36, 1.3).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(glow, "modulate:a", 0.16, 1.3).set_trans(Tween.TRANS_SINE)
	level.add_child(area)


static func add_water(level: Node, rect: Rect2, pal: Dictionary) -> void:
	var area := Area2D.new()
	area.position = rect.position + rect.size * 0.5
	area.add_to_group("water")
	area.collision_layer = 0
	area.collision_mask = 1
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = rect.size
	shape.shape = r
	area.add_child(shape)
	area.set_script(load("res://scripts/levels/water_zone.gd"))

	var batch := Batch.new()
	area.add_child(batch)
	var w: Color = pal["accent2"]
	var top := -rect.size.y * 0.5
	var left := -rect.size.x * 0.5
	var strips := 26
	for i in strips:
		var t := float(i) / float(strips)
		var a := lerpf(0.46, 0.10, t)
		var c := Color(w.r * 0.45, w.g * 0.72, w.b * 0.85, a)
		batch.rect(Rect2(left, top + rect.size.y * t, rect.size.x, rect.size.y / strips + 1.5), c)
	batch.rect(Rect2(left, top, rect.size.x, 3), Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.85))
	batch.rect(Rect2(left, top + 3, rect.size.x, 2), Color(1, 1, 1, 0.30))
	for i in 9:
		var sx := left + (i + 0.5) * rect.size.x / 9.0
		var wob := 18.0 + float((i * 37) % 26)
		batch.rect(Rect2(sx - wob, top + 14 + (i % 4) * 26, wob * 2, 2), Color(1, 1, 1, 0.06))
	for i in 7:
		var sx2 := left + (i + 0.5) * rect.size.x / 7.0
		batch.rect(Rect2(sx2 - 22, top + 30 + i * 17, 44, 2), Color(w.r * 0.6, w.g * 0.9, w.b, 0.10))
	batch.flush()

	var bubbles := CPUParticles2D.new()
	bubbles.texture = dot_texture()
	bubbles.amount = 26
	bubbles.lifetime = 4.0
	bubbles.preprocess = 2.0
	bubbles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	bubbles.emission_rect_extents = Vector2(rect.size.x * 0.45, 30)
	bubbles.position = Vector2(0, rect.size.y * 0.5 - 40)
	bubbles.direction = Vector2(0, -1)
	bubbles.spread = 12.0
	bubbles.initial_velocity_min = 14.0
	bubbles.initial_velocity_max = 38.0
	bubbles.gravity = Vector2(0, -6)
	bubbles.scale_amount_min = 0.05
	bubbles.scale_amount_max = 0.14
	bubbles.color = Color(0.7, 0.95, 1.0, 0.35)
	bubbles.z_index = 2
	area.add_child(bubbles)
	level.add_child(area)


static func add_spikes(level: Node, pos: Vector2, width: float, pal: Dictionary, upward := true) -> void:
	var area := Area2D.new()
	area.position = pos
	area.add_to_group("hazards")
	area.collision_layer = 0
	area.collision_mask = 1
	area.set_script(load("res://scripts/levels/hazard.gd"))
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(width, 26)
	shape.shape = r
	shape.position = Vector2(0, -10 if upward else 10)
	area.add_child(shape)
	var batch := Batch.new()
	area.add_child(batch)
	var count := int(width / 22.0)
	var edge: Color = pal["edge"]
	for i in count:
		var sx := -width * 0.5 + i * 22.0
		var pts := PackedVector2Array()
		if upward:
			pts = PackedVector2Array([Vector2(sx, 2), Vector2(sx + 11, -24), Vector2(sx + 22, 2)])
		else:
			pts = PackedVector2Array([Vector2(sx, -2), Vector2(sx + 11, 24), Vector2(sx + 22, -2)])
		batch.poly(pts, Color(edge.r * 0.9, edge.g * 0.9, edge.b * 0.95, 1))
	batch.flush()
	level.add_child(area)


static func add_laser(level: Node, from: Vector2, to: Vector2, color: Color, period := 2.4, phase := 0.0) -> Area2D:
	var area := Area2D.new()
	area.add_to_group("hazards")
	area.collision_layer = 0
	area.collision_mask = 1
	area.set_script(load("res://scripts/levels/laser_gate.gd"))
	var mid := (from + to) * 0.5
	area.position = mid
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(absf(to.x - from.x) + 8.0, absf(to.y - from.y) + 8.0)
	shape.shape = r
	area.add_child(shape)
	var batch := Batch.new()
	area.add_child(batch)
	var vertical := r.size.y > r.size.x
	var beam := Rect2(-2.0, -r.size.y * 0.5, 4.0, r.size.y) if vertical else Rect2(-r.size.x * 0.5, -2.0, r.size.x, 4.0)
	batch.rect(beam, Color(color.r, color.g, color.b, 0.9))
	batch.flush()
	var glow := Sprite2D.new()
	glow.texture = radial_texture()
	if vertical:
		glow.scale = Vector2(0.22, r.size.y * 0.009)
	else:
		glow.scale = Vector2(r.size.x * 0.009, 0.22)
	glow.modulate = Color(color.r, color.g, color.b, 0.35)
	glow.material = _add_material()
	area.add_child(glow)
	area.set_meta("period", period)
	area.set_meta("phase", phase)
	area.set_meta("glow", glow)
	level.add_child(area)
	return area


static func add_rain(camera: Node2D, color := Color(0.62, 0.78, 0.9, 0.45), amount := 300) -> CPUParticles2D:
	var rain := CPUParticles2D.new()
	rain.texture = streak_texture()
	rain.amount = amount
	rain.lifetime = 1.1
	rain.preprocess = 1.0
	rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	rain.emission_rect_extents = Vector2(760, 20)
	rain.position = Vector2(0, -420)
	rain.direction = Vector2(0.12, 1)
	rain.spread = 4.0
	rain.gravity = Vector2(160, 900)
	rain.initial_velocity_min = 420.0
	rain.initial_velocity_max = 620.0
	rain.scale_amount_min = 0.7
	rain.scale_amount_max = 1.3
	rain.color = color
	rain.z_index = 40
	camera.add_child(rain)
	return rain


static func add_dust(camera: Node2D, color := Color(0.8, 0.83, 0.95, 0.3), amount := 55) -> CPUParticles2D:
	var dust := CPUParticles2D.new()
	dust.texture = dot_texture()
	dust.amount = amount
	dust.lifetime = 7.0
	dust.preprocess = 4.0
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = Vector2(720, 380)
	dust.position = Vector2(0, -40)
	dust.direction = Vector2(1, 0)
	dust.spread = 180.0
	dust.gravity = Vector2(0, -3)
	dust.initial_velocity_min = 6.0
	dust.initial_velocity_max = 24.0
	dust.scale_amount_min = 0.04
	dust.scale_amount_max = 0.12
	dust.color = color
	dust.z_index = 39
	camera.add_child(dust)
	return dust


static func add_embers(camera: Node2D, color := Color(1.0, 0.6, 0.25, 0.5), amount := 70) -> CPUParticles2D:
	var embers := CPUParticles2D.new()
	embers.texture = dot_texture()
	embers.amount = amount
	embers.lifetime = 4.5
	embers.preprocess = 2.0
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(720, 20)
	embers.position = Vector2(0, 330)
	embers.direction = Vector2(0, -1)
	embers.spread = 22.0
	embers.gravity = Vector2(20, -34)
	embers.initial_velocity_min = 40.0
	embers.initial_velocity_max = 110.0
	embers.scale_amount_min = 0.05
	embers.scale_amount_max = 0.16
	embers.color = color
	embers.z_index = 39
	camera.add_child(embers)
	return embers


static func add_post_fx(level: Node, pal: Dictionary, vignette := 0.58, grain := 0.055, tint := Color(0, 0, 0, 0)) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 14
	layer.name = "PostFX"
	level.add_child(layer)
	if tint.a > 0.0:
		var tint_rect := ColorRect.new()
		tint_rect.color = tint
		tint_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		tint_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(tint_rect)

	var vignette_rect := ColorRect.new()
	vignette_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vmat := ShaderMaterial.new()
	var vshader := Shader.new()
	vshader.code = """
shader_type canvas_item;
uniform float strength = 0.6;
void fragment() {
	vec2 uv = SCREEN_UV;
	float d = distance(uv, vec2(0.5)) * 1.4142;
	float v = smoothstep(0.42, 1.05, d) * strength;
	COLOR = vec4(0.0, 0.0, 0.0, v);
}
"""
	vmat.shader = vshader
	vmat.set_shader_parameter("strength", vignette)
	vignette_rect.material = vmat
	layer.add_child(vignette_rect)

	if grain > 0.0:
		var grain_rect := ColorRect.new()
		grain_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		grain_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var gmat := ShaderMaterial.new()
		var gshader := Shader.new()
		gshader.code = """
shader_type canvas_item;
render_mode blend_add;
uniform float amount = 0.05;
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	float n = hash(SCREEN_UV * vec2(1280.0, 720.0) + vec2(fract(TIME * 7.0) * 1389.0));
	COLOR = vec4(vec3(n * amount), 1.0);
}
"""
		gmat.shader = gshader
		gmat.set_shader_parameter("amount", grain)
		grain_rect.material = gmat
		layer.add_child(grain_rect)


static func add_scroll_strip(level: Node, pal: Dictionary, y: float, scroll: float, count: int, seed_value: int, z := -12) -> void:
	var parallax := Parallax2D.new()
	parallax.scroll_scale = Vector2(scroll, 0.0)
	parallax.repeat_size = Vector2(REPEAT_W, 0.0)
	parallax.z_index = z
	level.add_child(parallax)
	var batch := Batch.new()
	parallax.add_child(batch)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var w := rng.randf_range(60, 260)
		var h := rng.randf_range(6, 22)
		batch.rect(Rect2(rng.randf_range(0, REPEAT_W), y + rng.randf_range(-40, 30), w, h), Color(pal["far"].r, pal["far"].g, pal["far"].b, rng.randf_range(0.5, 0.95)))
	batch.flush()


static func add_moving_platform(level: Node, center: Vector2, size: Vector2, travel: Vector2, duration: float, pal: Dictionary, wait_time := 0.7) -> AnimatableBody2D:
	var body := AnimatableBody2D.new()
	body.position = center
	body.set_script(load("res://scripts/levels/moving_platform.gd"))
	body.set("travel", travel)
	body.set("duration", duration)
	body.set("wait_time", wait_time)
	var batch := Batch.new()
	body.add_child(batch)
	batch.rect(Rect2(-size.x * 0.5, -size.y * 0.5, size.x, size.y), pal["ground"])
	batch.rect(Rect2(-size.x * 0.5, -size.y * 0.5, size.x, 3.0), pal["edge"])
	batch.rect(Rect2(-size.x * 0.5 + 3, size.y * 0.5 - 4, size.x - 6, 2), Color(0, 0, 0, 0.3))
	batch.rect(Rect2(-size.x * 0.5 + 6, -size.y * 0.5 + 8, 2, size.y - 12), Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.4))
	batch.flush()
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = size
	shape.shape = r
	body.add_child(shape)
	level.add_child(body)
	return body


static func add_crusher(level: Node, center: Vector2, size: Vector2, travel: float, pal: Dictionary) -> AnimatableBody2D:
	var body := AnimatableBody2D.new()
	body.position = center
	body.set_script(load("res://scripts/levels/crusher.gd"))
	body.set("travel", Vector2(0, travel))
	var batch := Batch.new()
	body.add_child(batch)
	batch.rect(Rect2(-size.x * 0.5, -size.y * 0.5, size.x, size.y), pal["detail"])
	batch.rect(Rect2(-size.x * 0.5, -size.y * 0.5, size.x, 4), pal["edge"])
	for i in int(size.x / 26.0):
		var sx := -size.x * 0.5 + i * 26.0
		batch.poly(PackedVector2Array([Vector2(sx, size.y * 0.5), Vector2(sx + 13, size.y * 0.5 + 16), Vector2(sx + 26, size.y * 0.5)]), Color(pal["edge"].r * 0.9, pal["edge"].g * 0.9, pal["edge"].b, 1))
	batch.flush()
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = size
	shape.shape = r
	body.add_child(shape)
	var hazard := Area2D.new()
	hazard.add_to_group("hazards")
	hazard.collision_layer = 0
	hazard.collision_mask = 1
	hazard.set_script(load("res://scripts/levels/hazard.gd"))
	var hshape := CollisionShape2D.new()
	var hr := RectangleShape2D.new()
	hr.size = Vector2(size.x, size.y + 16)
	hshape.shape = hr
	hshape.position = Vector2(0, 8)
	hazard.add_child(hshape)
	body.add_child(hazard)
	level.add_child(body)
	return body


static func add_door(level: Node, rect: Rect2, pal: Dictionary) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size * 0.5
	body.set_script(load("res://scripts/levels/door.gd"))
	var batch := Batch.new()
	body.add_child(batch)
	batch.rect(Rect2(-rect.size.x * 0.5, -rect.size.y * 0.5, rect.size.x, rect.size.y), pal["detail"])
	batch.rect(Rect2(-rect.size.x * 0.5, -rect.size.y * 0.5, 4, rect.size.y), pal["edge"])
	batch.rect(Rect2(rect.size.x * 0.5 - 4, -rect.size.y * 0.5, 4, rect.size.y), pal["edge"])
	for i in int(rect.size.y / 48.0):
		batch.rect(Rect2(-rect.size.x * 0.5 + 10, -rect.size.y * 0.5 + 16 + i * 48.0, rect.size.x - 20, 3), Color(1, 1, 1, 0.06))
	batch.flush()
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = rect.size
	shape.shape = r
	body.add_child(shape)
	level.add_child(body)
	return body


static func add_switch(level: Node, pos: Vector2, door: Node, pal: Dictionary) -> Area2D:
	var area := Area2D.new()
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 1
	area.set_script(load("res://scripts/levels/switch_plate.gd"))
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(70, 90)
	shape.shape = r
	shape.position = Vector2(0, -40)
	area.add_child(shape)
	var batch := Batch.new()
	area.add_child(batch)
	batch.rect(Rect2(-26, -8, 52, 10), pal["edge"])
	batch.rect(Rect2(-8, -58, 16, 50), pal["detail"])
	batch.rect(Rect2(-15, -74, 30, 18), Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.9))
	batch.flush()
	var glow := Sprite2D.new()
	glow.texture = radial_texture()
	glow.position = Vector2(0, -66)
	glow.scale = Vector2.ONE * 0.4
	glow.modulate = Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.3)
	glow.material = _add_material()
	area.add_child(glow)
	area.set_meta("glow", glow)
	level.add_child(area)
	area.door_path = area.get_path_to(door)
	return area


static func add_ceiling_light(level: Node, pos: Vector2, color: Color, size := 90.0) -> void:
	var batch := Batch.new()
	level.add_child(batch)
	batch.rect(Rect2(pos.x - size * 0.5, pos.y, size, 8), Color(color.r, color.g, color.b, 0.9))
	batch.rect(Rect2(pos.x - size * 0.5 + 4, pos.y + 8, size - 8, 3), Color(1, 1, 1, 0.25))
	batch.flush()
	add_glow(level, pos + Vector2(0, 4), color, size * 0.012, 0.5)


static func add_lantern(player: Node2D) -> PointLight2D:
	var light := PointLight2D.new()
	light.texture = radial_texture()
	light.color = Color(1.0, 0.84, 0.62)
	light.energy = 1.25
	light.texture_scale = 2.1
	light.position = Vector2(0, -80)
	light.blend_mode = Light2D.BLEND_MODE_ADD
	player.add_child(light)
	var flicker := light.create_tween().set_loops()
	flicker.tween_property(light, "energy", 1.05, 0.18)
	flicker.tween_property(light, "energy", 1.32, 0.22)
	flicker.tween_property(light, "energy", 1.18, 0.14)
	flicker.tween_property(light, "energy", 1.25, 0.3)
	return light


static func add_ladder(level: Node, rect: Rect2, pal: Dictionary) -> Area2D:
	var area := Area2D.new()
	area.position = rect.position + rect.size * 0.5
	area.collision_layer = 0
	area.collision_mask = 1
	area.set_script(load("res://scripts/levels/ladder.gd"))
	area.add_to_group("ladders")
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(70, rect.size.y)
	shape.shape = r
	area.add_child(shape)
	var batch := Batch.new()
	area.add_child(batch)
	var w := rect.size.x
	var h := rect.size.y
	batch.rect(Rect2(-w * 0.5, -h * 0.5, 5, h), Color(pal["edge"].r, pal["edge"].g, pal["edge"].b, 0.85))
	batch.rect(Rect2(w * 0.5 - 5, -h * 0.5, 5, h), Color(pal["edge"].r, pal["edge"].g, pal["edge"].b, 0.85))
	var rungs := int(h / 34.0)
	for i in rungs:
		batch.rect(Rect2(-w * 0.5, -h * 0.5 + 12 + i * 34.0, w, 4), Color(pal["edge"].r, pal["edge"].g, pal["edge"].b, 0.55))
	batch.flush()
	level.add_child(area)
	return area


static func radial_texture() -> Texture2D:
	if _radial != null:
		return _radial
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 256
	t.height = 256
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	_radial = t
	return _radial


static func dot_texture() -> Texture2D:
	if _dot != null:
		return _dot
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	_dot = ImageTexture.create_from_image(img)
	return _dot


static func streak_texture() -> Texture2D:
	if _streak != null:
		return _streak
	var img := Image.create(3, 20, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0))
	for y in 20:
		img.set_pixel(1, y, Color(1, 1, 1, 0.55 + 0.45 * float(y) / 19.0))
	_streak = ImageTexture.create_from_image(img)
	return _streak


static func _add_material() -> CanvasItemMaterial:
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return mat
