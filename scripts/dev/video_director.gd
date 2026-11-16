extends CanvasLayer

const LEVELS := [
	"res://scenes/levels/Level_01_Wake.tscn",
	"res://scenes/levels/Level_02_Flooded.tscn",
	"res://scenes/levels/Level_03_Factory.tscn",
	"res://scenes/levels/Level_04_Tunnels.tscn",
	"res://scenes/levels/Level_05_Tower.tscn",
	"res://scenes/levels/Level_06_Lab.tscn",
	"res://scenes/levels/Level_07_FalseDawn.tscn",
]

const CHAPTERS := [
	{"ar": "الفصل الأول — الاستيقاظ", "en": "CHAPTER I — WAKE", "line": "مدينة نائمة… ونجم واحد يرفض الانطفاء"},
	{"ar": "الفصل الثاني — الطوفان", "en": "CHAPTER II — FLOODED", "line": "الماء يبتلع الشوارع، لكنه يعلّمك كيف تطفو"},
	{"ar": "الفصل الثالث — المصنع", "en": "CHAPTER III — FACTORY", "line": "منصات متحركة، مكابس، ومفتاح واحد يفتح الطريق"},
	{"ar": "الفصل الرابع — الأنفاق", "en": "CHAPTER IV — TUNNELS", "line": "الظلام يبتلع الضوء… والفانوس يحرسك"},
	{"ar": "الفصل الخامس — البرج", "en": "CHAPTER V — TOWER", "line": "سبع سلالم… سبع طبقات… صعود بلا نهاية"},
	{"ar": "الفصل السادس — المختبر", "en": "CHAPTER VI — LAB", "line": "أشعة لا ترحم… وتوقيتها هو كل شيء"},
	{"ar": "الفصل السابع — فجر كاذب", "en": "CHAPTER VII — FALSE DAWN", "line": "الشمس تشرق… لكن المدينة ما زالت نائمة"},
]

var _video := false
var _player: CharacterBody2D

var _bar_top: ColorRect
var _bar_bottom: ColorRect
var _caption_panel: PanelContainer
var _caption_ar: Label
var _caption_en: Label
var _card: Control
var _card_bg: ColorRect
var _card_box: VBoxContainer
var _versions: Control
var _results: Array[String] = []
var _chapter_token := 0
var _deaths := 0
var _now := 0.0


func _process(delta: float) -> void:
	# Movie Maker renders well below real time, so every route budget must be
	# measured in game seconds or every timeout would fire early in the video.
	_now += delta


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var args := OS.get_cmdline_user_args()
	if not args.has("--video") and not args.has("--autoplay"):
		queue_free()
		return
	_video = args.has("--video")
	var log_file := FileAccess.open("user://video_log.txt", FileAccess.WRITE)
	if log_file != null:
		log_file.store_line("start")
		log_file.close()
	if _video:
		_build_ui()
	else:
		var watchdog := Timer.new()
		watchdog.wait_time = 420.0
		watchdog.one_shot = true
		watchdog.timeout.connect(func() -> void:
			print("AUTOPLAY_TIMEOUT ", JSON.stringify(_results))
			get_tree().quit(1))
		add_child(watchdog)
		watchdog.start()
	_run.call_deferred()


func _run() -> void:
	await _wait(0.8)
	if _video:
		await _intro()
		await _menu_segment()
		await _showcase()
	else:
		print("AUTOPLAY start")
	var start := 0
	var only := -1
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--from="):
			start = int(arg.substr(7))
		elif arg.begins_with("--only="):
			only = int(arg.substr(7))
	if only >= 0:
		await _chapter(only)
		if not _video:
			print("AUTOPLAY_DONE ", JSON.stringify(_results))
		else:
			await _wait(1.0)
		get_tree().quit(0)
		return
	for i in range(start, LEVELS.size()):
		await _chapter(i)
		if _video and i < LEVELS.size() - 1:
			await _wait(1.4)
	if _video:
		await _outro()
	else:
		print("AUTOPLAY_DONE ", JSON.stringify(_results))
		get_tree().quit(0)


# ---------------------------------------------------------------- overlays

func _build_ui() -> void:
	layer = 100
	_bar_top = ColorRect.new()
	_bar_top.color = Color.BLACK
	_bar_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_bar_top.offset_bottom = 84
	_bar_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bar_top)

	_bar_bottom = ColorRect.new()
	_bar_bottom.color = Color.BLACK
	_bar_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bar_bottom.offset_top = -84
	_bar_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bar_bottom)

	_caption_panel = PanelContainer.new()
	_caption_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_caption_panel.offset_left = -540
	_caption_panel.offset_right = 540
	_caption_panel.offset_top = -232
	_caption_panel.offset_bottom = -112
	_caption_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.015, 0.015, 0.025, 0.78)
	style.border_color = Color(0.65, 0.7, 0.8, 0.22)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	_caption_panel.add_theme_stylebox_override("panel", style)
	add_child(_caption_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	_caption_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	margin.add_child(box)

	_caption_ar = Label.new()
	_caption_ar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption_ar.add_theme_font_size_override("font_size", 30)
	_caption_ar.add_theme_color_override("font_color", Color(0.94, 0.94, 0.97, 1))
	box.add_child(_caption_ar)

	_caption_en = Label.new()
	_caption_en.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption_en.add_theme_font_size_override("font_size", 17)
	_caption_en.add_theme_color_override("font_color", Color(0.62, 0.66, 0.75, 1))
	box.add_child(_caption_en)

	_caption_panel.visible = false

	_card = Control.new()
	_card.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.visible = false
	add_child(_card)

	_card_bg = ColorRect.new()
	_card_bg.color = Color(0.02, 0.02, 0.03, 0.96)
	_card_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(_card_bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(center)

	_card_box = VBoxContainer.new()
	_card_box.add_theme_constant_override("separation", 18)
	_card_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_card_box)

	_versions = Control.new()
	_versions.set_anchors_preset(Control.PRESET_FULL_RECT)
	_versions.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_versions.visible = false
	add_child(_versions)


func _title_card(title_ar: String, title_en: String, lines: Array, footer := "") -> void:
	_clear_card()
	_card_add(title_ar, 74, Color(0.96, 0.93, 0.88, 1))
	_card_add(title_en, 26, Color(0.62, 0.66, 0.76, 1))
	for line in lines:
		_card_add(str(line), 24, Color(0.78, 0.8, 0.86, 1))
	if footer != "":
		_card_add(footer, 19, Color(0.5, 0.53, 0.6, 1))
	_card.visible = true
	_card.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_card, "modulate:a", 1.0, 0.6)


func _card_show(title: String, items: Array, footer := "") -> void:
	_clear_card()
	_card_add(title, 46, Color(0.96, 0.9, 0.8, 1))
	for item in items:
		_card_add(str(item), 26, Color(0.8, 0.82, 0.88, 1))
	if footer != "":
		_card_add(footer, 19, Color(0.52, 0.55, 0.62, 1))
	_card.visible = true
	_card.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_card, "modulate:a", 1.0, 0.5)


func _card_add(text: String, size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("line_spacing", 6)
	_card_box.add_child(label)


func _clear_card() -> void:
	for child in _card_box.get_children():
		child.queue_free()


func _card_hide() -> void:
	var tw := create_tween()
	tw.tween_property(_card, "modulate:a", 0.0, 0.5)
	await tw.finished
	_card.visible = false


func _caption(ar: String, en := "") -> void:
	_caption_ar.text = ar
	_caption_en.text = en
	_caption_en.visible = en != ""
	_caption_panel.visible = true
	_caption_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_caption_panel, "modulate:a", 1.0, 0.4)


func _caption_clear() -> void:
	if not _caption_panel.visible:
		return
	var tw := create_tween()
	tw.tween_property(_caption_panel, "modulate:a", 0.0, 0.35)
	await tw.finished
	_caption_panel.visible = false


func _show_versions() -> void:
	for child in _versions.get_children():
		child.queue_free()
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.03, 0.97)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_versions.add_child(bg)

	var title := Label.new()
	title.text = "قبل وبعد — تطور النسخة"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.96, 0.9, 0.8, 1))
	title.position = Vector2(0, 96)
	title.size = Vector2(1920, 60)
	_versions.add_child(title)

	var shots := [
		["res://assets/video/proto.png", "v0.1 — النموذج الأولي", "مشهد رمادي، حركة أساسية، بلا إضاءة"],
		["res://assets/video/final.png", "v1.0 — النسخة النهائية", "شخصية 3D، مدن متوازية، إضاءة وجوّ"],
	]
	for i in shots.size():
		var entry: Array = shots[i]
		var frame := PanelContainer.new()
		frame.position = Vector2(120 + i * 850, 200)
		frame.size = Vector2(810, 560)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.05, 0.05, 0.07, 1)
		style.border_color = Color(0.35, 0.38, 0.46, 0.7)
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		frame.add_theme_stylebox_override("panel", style)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_versions.add_child(frame)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		frame.add_child(margin)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 8)
		margin.add_child(column)

		var image := TextureRect.new()
		image.texture = load(entry[0])
		image.custom_minimum_size = Vector2(786, 442)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		column.add_child(image)

		var name_label := Label.new()
		name_label.text = entry[1]
		name_label.add_theme_font_size_override("font_size", 28)
		name_label.add_theme_color_override("font_color", Color(0.94, 0.9, 0.8, 1))
		column.add_child(name_label)

		var desc := Label.new()
		desc.text = entry[2]
		desc.add_theme_font_size_override("font_size", 20)
		desc.add_theme_color_override("font_color", Color(0.66, 0.69, 0.76, 1))
		column.add_child(desc)

	_versions.visible = true
	_versions.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_versions, "modulate:a", 1.0, 0.6)


func _hide_versions() -> void:
	var tw := create_tween()
	tw.tween_property(_versions, "modulate:a", 0.0, 0.5)
	await tw.finished
	_versions.visible = false
	for child in _versions.get_children():
		child.queue_free()


# ---------------------------------------------------------------- segments

func _intro() -> void:
	_title_card(
		"ليالي سوداء",
		"BLACK NIGHTS",
		["سبعة فصول · منصات سينمائية · شخصية ثلاثية الأبعاد في عالم ثنائي الأبعاد"],
		"نسخة 1.0 · 1920×1080 · موسيقى ومؤثرات أصلية"
	)
	await _wait(5.2)
	await _card_hide()


func _menu_segment() -> void:
	await _ensure_scene("res://scenes/ui/MainMenu.tscn")
	await _wait(1.6)
	_caption("القائمة الرئيسية — واجهة عربية كاملة وحفظ تلقائي", "MAIN MENU")
	await _wait(3.2)
	await _caption_clear()
	await _load("res://scenes/ui/Settings.tscn")
	await _wait(1.2)
	_caption("الإعدادات — تحكم كامل بالصوت وملء الشاشة", "SETTINGS")
	await _wait(2.8)
	await _caption_clear()


func _showcase() -> void:
	await _ensure_scene(LEVELS[0])
	await _wait(1.4)
	var scene := get_tree().current_scene
	var player := scene.get_node_or_null("CharacterRoot")
	var cam: Camera3D = null
	if player != null:
		cam = player.get_node_or_null("SubViewportContainer/SubViewport/Camera3D") as Camera3D
	if cam == null:
		return
	var old_pos := cam.position
	var old_rot := cam.rotation
	var old_size := cam.size
	cam.size = 1.3
	_caption("نموذج الشخصية — عباءة منحوتة مفتوحة، قلنسوة، وحزام جلد", "CHARACTER MODEL — TURNTABLE")
	var target := Vector3(0, 0.62, 0)
	var elapsed := 0.0
	var duration := 11.0
	var swapped := false
	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var a := -0.35 + TAU * clampf(elapsed / duration, 0.0, 1.0)
		cam.position = target + Vector3(sin(a) * 3.1, 0.16, cos(a) * 3.1)
		cam.look_at(target)
		if not swapped and elapsed > duration * 0.5:
			swapped = true
			_caption("فانوس نحاسي وضوء دافئ، قلنسوة بفتحة للوجه، وحقيبة جلدية", "BRASS LANTERN — HOOD — SATCHEL")
	await _caption_clear()
	cam.size = old_size
	cam.position = old_pos
	cam.rotation = old_rot
	await _wait(0.6)


func _chapter(index: int) -> void:
	_release_all()
	_log("ENTER chapter %d" % (index + 1))
	await _ensure_scene(LEVELS[index])
	await _wait(1.7)
	var scene := get_tree().current_scene
	_player = scene.get_node_or_null("CharacterRoot") as CharacterBody2D
	if _player == null:
		_log("CHAPTER %d FAIL — no player" % (index + 1))
		return
	if _video:
		var chapter: Dictionary = CHAPTERS[index]
		_caption(str(chapter["ar"]) + " — " + str(chapter["line"]), str(chapter["en"]))
	_chapter_token += 1
	_watch_deaths(_chapter_token)
	var started := _now_ms()
	match index:
		0: await _play_01()
		1: await _play_02()
		2: await _play_03()
		3: await _play_04()
		4: await _play_05()
		5: await _play_06()
		6: await _play_07()
	_release_all()
	var secs := (_now_ms() - started) / 1000.0
	_chapter_token += 1
	_log("CHAPTER %d %.1fs x=%.0f y=%.0f" % [index + 1, secs, _player.global_position.x, _player.global_position.y])
	if _video:
		await _caption_clear()
	await _wait(2.6)


func _outro() -> void:
	await _caption_clear()
	await _wait_for_scene("MainMenu", 12.0)
	await _wait(1.2)
	_card_show("ما تغيّر في هذه النسخة", [
		"شخصية ثلاثية الأبعاد بهيكل عظمي كامل داخل عالم ثنائي الأبعاد",
		"سبع حالات حركة: وقوف، مشي، جري، قفز، هبوط، سباحة، تسلق",
		"دوران ثلاثي الأبعاد عند الجري، ظل ديناميكي، وارتطام عند الهبوط",
		"تنفّس ووقفة غير متكلفة، وشال يتحرك مع الريح والجري",
	], "الترقيات — الشخصية والحركة")
	await _wait(6.4)
	_card_show("عالم وصوت وميكانيكات", [
		"سبعة فصول بألوان وأجواء وميكانيكات مختلفة",
		"طبقات خلفية متوازية، نوافذ مضاءة، مطر، جمر، ضباب، وبرق",
		"إضاءة فعلية: فانوس، أضواء أسقف، أعمدة ضوء ترتجف، وأشعة ليزر متوقّتة",
		"أجواء محيطة لكل فصل، وخطوات حسب السطح (حجر/معدن/خشب/ماء)",
		"تنفّس وحفيف ثياب، غبار وشظايا تحت الأقدام، وارتجاج عند الهبوط",
		"حفظ تلقائي، إعدادات صوت، وتحكم كامل بالكيبورد",
	], "الترقيات — العالم والصوت")
	await _wait(7.4)
	await _card_hide()
	_show_versions()
	await _wait(9.0)
	await _hide_versions()
	_title_card(
		"شكراً للمشاهدة",
		"BLACK NIGHTS — v1.0",
		["لعبة منصات سينمائية من سبعة فصول"],
		"صُنعت بـ Godot 4.7 · 1920×1080 · صوت أصلي"
	)
	await _wait(5.4)
	await _card_hide()
	await _wait(0.6)
	get_tree().quit(0)


# ---------------------------------------------------------------- chapters

func _play_01() -> void:
	await _advance_to(3100.0, [1140.0, 2282.0], true, 30.0)


func _play_02() -> void:
	await _advance_to(860.0, [], true, 12.0)
	_hold("jump")
	_hold("run")
	_hold("move_right")
	await _until_x(1350.0, 14.0)
	_release("jump")
	await _advance_to(2032.0, [], true, 12.0)
	_hold("jump")
	_hold("run")
	_hold("move_right")
	await _until_x(2692.0, 16.0)
	_release("jump")
	await _advance_to(3240.0, [], true, 14.0)


func _play_03() -> void:
	var platforms := _nodes_by_script("moving_platform.gd")
	var crushers := _nodes_by_script("crusher.gd")
	if platforms.size() < 2 or crushers.is_empty():
		_log("CHAPTER 3 FAIL — missing mechanics")
		return
	var p1 := platforms[0] as AnimatableBody2D
	var p2 := platforms[1] as AnimatableBody2D
	var crusher := crushers[0] as AnimatableBody2D

	_log("CH3 step1 advance")
	await _advance_to(1442.0, [], true, 12.0)
	_log("CH3 step2 wait p1")
	await _wait_until(func() -> bool: return p1.position.x <= 1576.0, 10.0)
	_log("CH3 step3 board")
	_hold("run")
	_hold("move_right")
	await _until_x(1600.0, 3.0)
	_release("move_right")
	_release("run")
	await _wait(0.5)
	if _player.global_position.y > 760.0:
		_log("CHAPTER 3 FAIL — platform 1 missed")
		return
	_log("CH3 step4 ride")
	await _wait_until(func() -> bool: return p1.position.x >= 1792.0, 9.0)
	_log("CH3 step5 jump off")
	await _jump()
	await _advance_to(1990.0, [], true, 6.0)

	_log("CH3 step6 crusher")
	await _advance_to(2036.0, [], true, 6.0)
	await _wait_until(func() -> bool: return crusher.position.y <= 400.0, 5.0)
	_hold("run")
	_hold("move_right")
	await _until_x(2338.0, 4.0)
	_release("move_right")
	_release("run")
	await _wait(0.3)
	if _player.global_position.y > 900.0:
		_log("CHAPTER 3 FAIL — crusher hit")
		return

	_log("CH3 step7 p2")
	await _advance_to(2462.0, [], true, 8.0)
	await _wait_until(func() -> bool: return p2.position.x <= 2588.0, 10.0)
	_hold("run")
	_hold("move_right")
	await _until_x(2620.0, 3.0)
	_release("move_right")
	_release("run")
	await _wait(0.5)
	if _player.global_position.y > 760.0:
		_log("CHAPTER 3 FAIL — platform 2 missed")
		return
	_log("CH3 step8 ride2")
	await _wait_until(func() -> bool: return p2.position.x >= 2790.0, 9.0)
	await _jump()
	await _advance_to(2900.0, [], true, 8.0)
	await _wait(0.4)
	await _advance_to(3010.0, [], false, 6.0)
	await _wait(0.2)
	await _interact()
	await _advance_to(3095.0, [], true, 6.0)
	await _wait(1.8)
	await _advance_to(3520.0, [], true, 8.0)


func _play_04() -> void:
	await _advance_to(2950.0, [848.0, 1842.0, 2368.0], true, 26.0)


func _play_05() -> void:
	await _advance_to(720.0, [], false, 12.0)
	var tops := [2860.0, 2500.0, 2140.0, 1780.0, 1420.0, 1060.0, 700.0]
	for i in tops.size():
		await _climb_ladder(tops[i] + 60.0, "move_left" if i % 2 == 0 else "move_right")
		await _wait(0.35)
		if i < tops.size() - 1:
			await _advance_to(720.0, [], false, 5.0)
	await _advance_to(352.0, [], false, 8.0)


func _play_06() -> void:
	await _advance_to(1062.0, [686.0], true, 16.0)
	await _cross_laser(1120.0)
	await _cross_laser(1520.0)
	await _cross_laser(1920.0)
	await _advance_to(2604.0, [], true, 12.0)
	await _interact()
	await _wait(1.7)
	await _advance_to(3220.0, [], true, 10.0)


func _play_07() -> void:
	await _advance_to(4260.0, [1742.0, 2962.0], true, 30.0)


# ---------------------------------------------------------------- driving

func _watch_deaths(token: int) -> void:
	var last := _player.global_position
	while token == _chapter_token and is_instance_valid(_player):
		await get_tree().physics_frame
		if token != _chapter_token or not is_instance_valid(_player):
			return
		var p := _player.global_position
		if last.x - p.x > 200.0:
			_deaths += 1
			_log("DEATH at x=%.0f y=%.0f -> x=%.0f y=%.0f" % [last.x, last.y, p.x, p.y])
		last = p


func _advance_to(target_x: float, jumps: Array = [], run := true, timeout := 30.0) -> bool:
	var dir := 1.0 if target_x >= _player.global_position.x else -1.0
	if run:
		_hold("run")
	_hold("move_right" if dir > 0.0 else "move_left")
	var pending := jumps.duplicate()
	var spikes := _spike_rects() if dir > 0.0 else []
	var started := _now_ms()
	var last_log := started
	var last_x := _player.global_position.x
	var ok := true
	while (dir > 0.0 and _player.global_position.x < target_x) or (dir < 0.0 and _player.global_position.x > target_x):
		if _now_ms() - last_log > 1500:
			last_log = _now_ms()
			_log("ADV t=%.1f x=%.0f y=%.0f pend=%s" % [(last_log - started) / 1000.0, _player.global_position.x, _player.global_position.y, str(pending)])
		if _now_ms() - started > int(timeout * 1000.0):
			ok = false
			_log("ADVANCE timeout target=%.0f at x=%.0f y=%.0f" % [target_x, _player.global_position.x, _player.global_position.y])
			break
		var x := _player.global_position.x
		if last_x - x > 200.0:
			_log("RESPAWN mid-advance target=%.0f -> re-route from x=%.0f" % [target_x, x])
			pending = jumps.duplicate()
			spikes = _spike_rects()
			started = _now_ms()
			last_log = started
		last_x = x
		if dir > 0.0 and not pending.is_empty() and x >= float(pending[0]):
			pending.pop_front()
			_log("JUMP at x=%.0f y=%.0f" % [x, _player.global_position.y])
			await _jump()
			continue
		if dir > 0.0 and _player.is_on_floor() and _jump_needed_ahead(x, pending, spikes):
			_log("AUTOJUMP spike at x=%.0f" % x)
			await _jump()
			continue
		await get_tree().physics_frame
	_release("move_right")
	_release("move_left")
	_release("run")
	return ok


func _jump_needed_ahead(x: float, pending: Array, spikes: Array) -> bool:
	if not pending.is_empty() and float(pending[0]) - x < 220.0:
		return false
	for rect in spikes:
		var r := rect as Rect2
		var d := r.position.x - x
		if d > 24.0 and d < 70.0:
			return true
	return false


func _spike_rects() -> Array:
	var out: Array = []
	var scene := get_tree().current_scene
	if scene == null:
		return out
	for child in scene.get_children():
		var script := child.get_script() as Script
		if script == null or not str(script.resource_path).ends_with("hazard.gd"):
			continue
		var area := child as Area2D
		if area == null:
			continue
		var width := 160.0
		for sub in area.get_children():
			var shape_node := sub as CollisionShape2D
			if shape_node == null:
				continue
			var box := shape_node.shape as RectangleShape2D
			if box != null:
				width = box.size.x
		out.append(Rect2(area.global_position.x - width * 0.5, area.global_position.y - 13.0, width, 26.0))
	return out


func _until_x(x: float, timeout := 15.0) -> bool:
	var started := _now_ms()
	while _player.global_position.x < x:
		if _now_ms() - started > int(timeout * 1000.0):
			_log("UNTIL timeout x=%.0f at %.0f" % [x, _player.global_position.x])
			return false
		await get_tree().physics_frame
	return true


func _jump() -> void:
	_hold("jump")
	await get_tree().physics_frame
	await get_tree().physics_frame
	_release("jump")


func _interact() -> void:
	# Switches read the action in _process (render frames), so the hold must
	# span visible frames: at --fixed-fps 30 there are two physics ticks per
	# frame and a physics-only hold can press and release unseen.
	_hold("interact")
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	_release("interact")


func _climb_ladder(stop_y: float, side: String) -> void:
	_log("CLIMB start x=%.0f y=%.0f stop=%.0f side=%s" % [_player.global_position.x, _player.global_position.y, stop_y, side])
	_key(KEY_W, true)
	var started := _now_ms()
	while _player.global_position.y > stop_y:
		if _now_ms() - started > 9500:
			_log("CLIMB timeout y=%.0f stop=%.0f" % [_player.global_position.y, stop_y])
			break
		await get_tree().physics_frame
	_log("CLIMB top x=%.0f y=%.0f" % [_player.global_position.x, _player.global_position.y])
	_hold(side)
	started = _now_ms()
	while not _player.is_on_floor():
		if _now_ms() - started > 4000:
			_log("CLIMB landing timeout y=%.0f x=%.0f" % [_player.global_position.y, _player.global_position.x])
			break
		await get_tree().physics_frame
	_key(KEY_W, false)
	_release(side)
	_log("CLIMB landed x=%.0f y=%.0f" % [_player.global_position.x, _player.global_position.y])
	await _wait(0.12)


func _climb_to(stop_y: float, timeout := 9.0) -> void:
	_key(KEY_W, true)
	var started := _now_ms()
	while _player.global_position.y > stop_y:
		if _now_ms() - started > int(timeout * 1000.0):
			_log("CLIMB timeout y=%.0f stop=%.0f" % [_player.global_position.y, stop_y])
			break
		await get_tree().physics_frame
	_key(KEY_W, false)


func _wait_until(condition: Callable, timeout := 10.0) -> bool:
	var started := _now_ms()
	while not bool(condition.call()):
		if _now_ms() - started > int(timeout * 1000.0):
			_log("WAIT timeout")
			return false
		await get_tree().process_frame
	return true


func _cross_laser(x: float) -> void:
	# Each timed column must be cleared in order. A death past a checkpoint can
	# respawn on either side of earlier columns, so re-cross whatever is behind
	# us whenever the route is restarted.
	var priors: Array = []
	for col in _laser_columns():
		if col < x - 5.0:
			priors.append(col)
	for attempt in 3:
		for col in priors:
			var prior := float(col)
			if _player.global_position.x < prior - 26.0:
				await _cross_one(prior)
		var before := _deaths
		await _cross_one(x)
		if _deaths == before and _player.global_position.x >= x + 60.0:
			return
		_log("LASER retry x=%.0f attempt=%d at x=%.0f" % [x, attempt + 1, _player.global_position.x])
	_log("LASER failed x=%.0f at x=%.0f" % [x, _player.global_position.x])


func _cross_one(x: float) -> void:
	if x - _player.global_position.x > 220.0:
		await _advance_to(x - 120.0, [], true, 10.0)
	await _walk_to(x - 40.0, 7.0)
	await _wait(0.12)
	var laser := _laser_near(x)
	if laser != null:
		var started := _now_ms()
		# Arriving mid-window leaves only a sliver of off time, so always align
		# to the start of a full off cycle before dashing.
		while not laser.visible:
			if _now_ms() - started > 4000:
				break
			await get_tree().process_frame
		while laser.visible:
			if _now_ms() - started > 8000:
				break
			await get_tree().process_frame
	await _advance_to(x + 70.0, [], true, 8.0)


func _walk_to(target_x: float, timeout := 6.0) -> void:
	var started := _now_ms()
	while absf(_player.global_position.x - target_x) > 4.0:
		if _now_ms() - started > int(timeout * 1000.0):
			_log("WALK timeout target=%.0f at %.0f" % [target_x, _player.global_position.x])
			break
		if _player.global_position.x < target_x:
			_release("move_left")
			_hold("move_right")
		else:
			_release("move_right")
			_hold("move_left")
		await get_tree().physics_frame
	_release("move_right")
	_release("move_left")


func _laser_columns() -> Array:
	var out: Array = []
	var scene := get_tree().current_scene
	if scene == null:
		return out
	for child in scene.get_children():
		var script := child.get_script() as Script
		if script == null or not str(script.resource_path).ends_with("laser_gate.gd"):
			continue
		var node2d := child as Node2D
		if node2d == null:
			continue
		var size := Vector2.ZERO
		for sub in node2d.get_children():
			var shape_node := sub as CollisionShape2D
			if shape_node == null:
				continue
			var box := shape_node.shape as RectangleShape2D
			if box != null:
				size = box.size
		if size.y > size.x:
			out.append(node2d.global_position.x)
	out.sort()
	return out


func _laser_near(x: float) -> Node2D:
	var best: Node2D = null
	var best_dist := 99999.0
	for node in _nodes_by_script("laser_gate.gd"):
		var node2d := node as Node2D
		if node2d == null:
			continue
		var d: float = absf(node2d.global_position.x - x)
		if d < best_dist:
			best_dist = d
			best = node2d
	return best


func _nodes_by_script(file_name: String) -> Array:
	var out: Array = []
	var scene := get_tree().current_scene
	if scene == null:
		return out
	for child in scene.get_children():
		var script := child.get_script() as Script
		if script != null and str(script.resource_path).ends_with(file_name):
			out.append(child)
	return out


func _hold(action: String) -> void:
	if not Input.is_action_pressed(action):
		Input.action_press(action)


func _release(action: String) -> void:
	if Input.is_action_pressed(action):
		Input.action_release(action)


func _release_all() -> void:
	for action in ["move_left", "move_right", "run", "jump", "pause"]:
		if Input.is_action_pressed(action):
			Input.action_release(action)
	_key(KEY_W, false)
	_key(KEY_S, false)
	_key(KEY_UP, false)
	_key(KEY_DOWN, false)


func _key(code: Key, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = down
	Input.parse_input_event(event)


func _now_ms() -> int:
	return int(_now * 1000.0)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


func _load(path: String) -> void:
	get_tree().change_scene_to_file(path)
	await _wait(0.15)
	var started := _now_ms()
	while _now_ms() - started < 5000:
		var scene := get_tree().current_scene
		if scene != null and scene.scene_file_path == path:
			break
		await get_tree().process_frame


func _ensure_scene(path: String) -> void:
	var scene := get_tree().current_scene
	if scene != null and scene.scene_file_path == path:
		return
	await _load(path)


func _wait_for_scene(scene_name: String, timeout: float) -> void:
	var started := _now_ms()
	while _now_ms() - started < int(timeout * 1000.0):
		var scene := get_tree().current_scene
		if scene != null and scene.name == scene_name:
			return
		await get_tree().process_frame


func _log(line: String) -> void:
	_results.append(line)
	print("VIDEO ", line)
	var f := FileAccess.open("user://video_log.txt", FileAccess.READ_WRITE)
	if f == null:
		f = FileAccess.open("user://video_log.txt", FileAccess.WRITE)
	if f != null:
		f.seek_end()
		f.store_line(line)
		f.flush()
		f.close()
