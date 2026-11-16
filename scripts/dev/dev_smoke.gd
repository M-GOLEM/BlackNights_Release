extends Node

const CAPTURE_DIR := "user://snapshots/"


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--shots"):
		process_mode = Node.PROCESS_MODE_ALWAYS
		_run_shots.call_deferred()
		return
	if args.has("--uis"):
		process_mode = Node.PROCESS_MODE_ALWAYS
		_run_ui_shots.call_deferred()
		return
	if not args.has("--smoke"):
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	var watchdog := Timer.new()
	watchdog.wait_time = 25.0
	watchdog.one_shot = true
	watchdog.timeout.connect(_on_watchdog)
	add_child(watchdog)
	watchdog.start()
	_run.call_deferred()


func _on_watchdog() -> void:
	print("SMOKE_TIMEOUT after 25s")
	get_tree().quit(1)


func _run() -> void:
	var tree := get_tree()
	print("SMOKE_STEP awaiting settle")
	await tree.create_timer(1.5).timeout
	var results := {"scene": str(tree.current_scene.name)}
	var skip := OS.get_cmdline_user_args().has("--smoke-skip-input")
	print("SMOKE_STEP capture start")
	await _capture("01_start")

	var player := tree.current_scene.get_node_or_null("CharacterRoot") as CharacterBody2D
	if player != null and not skip:
		print("SMOKE_STEP moving")
		var x0 := player.global_position.x
		Input.action_press("move_right")
		Input.action_press("run")
		await tree.create_timer(0.7).timeout
		var x1 := player.global_position.x
		var rig := player.get_node("SubViewportContainer/SubViewport/Character3D")
		results["moved_px"] = snappedf(x1 - x0, 0.1)
		results["run_state"] = str(rig.call("state_name"))
		print("SMOKE_STEP capture run")
		await _capture("02_run")
		Input.action_release("run")
		Input.action_release("move_right")

		print("SMOKE_STEP jumping")
		Input.action_press("jump")
		await tree.physics_frame
		await tree.physics_frame
		Input.action_release("jump")
		await tree.create_timer(0.2).timeout
		results["airborne"] = not player.is_on_floor()
		results["jump_state"] = str(rig.call("state_name"))
		print("SMOKE_STEP capture jump")
		await _capture("03_jump")

		await tree.create_timer(1.5).timeout
		results["grounded_after"] = player.is_on_floor()
		results["idle_state"] = str(rig.call("state_name"))
		print("SMOKE_STEP capture idle")
		await _capture("04_idle")

		print("SMOKE_STEP pause")
		_send_action("pause")
		await tree.create_timer(0.4).timeout
		results["paused"] = tree.paused
		await _capture("05_pause")
		_send_action("pause")
		await tree.create_timer(0.4).timeout
		results["resumed"] = not tree.paused

		print("SMOKE_STEP finish")
		player.global_position = Vector2(3060, 560)
		await tree.create_timer(3.2).timeout
		results["after_finish_scene"] = str(tree.current_scene.name) if tree.current_scene else "none"
		results["saved_highest"] = SaveSystem.highest_chapter()
		await _capture("06_after_finish")

	print("SMOKE_RESULT ", JSON.stringify(results))
	tree.quit(0)


func _run_shots() -> void:
	var paths := [
		"res://scenes/levels/Level_01_Wake.tscn",
		"res://scenes/levels/Level_02_Flooded.tscn",
		"res://scenes/levels/Level_03_Factory.tscn",
		"res://scenes/levels/Level_04_Tunnels.tscn",
		"res://scenes/levels/Level_05_Tower.tscn",
		"res://scenes/levels/Level_06_Lab.tscn",
		"res://scenes/levels/Level_07_FalseDawn.tscn",
	]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://shots/"))
	for i in paths.size():
		get_tree().change_scene_to_file(paths[i])
		await get_tree().create_timer(2.4).timeout
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		img.save_png("user://shots/level_%02d.png" % (i + 1))
		var scene := get_tree().current_scene
		print("SHOT ", i + 1, " scene=", scene.name if scene != null else "none", " nodes=", scene.get_child_count() if scene != null else 0)
	await get_tree().create_timer(0.3).timeout
	get_tree().quit(0)


func _run_ui_shots() -> void:
	await get_tree().create_timer(1.6).timeout
	var manager := get_tree().current_scene.get_node_or_null("LevelManager")
	_send_action("pause")
	await get_tree().create_timer(0.5).timeout
	await _capture("ui_01_pause")
	if manager != null:
		manager.call("_open_controls")
		await get_tree().create_timer(0.4).timeout
		await _capture("ui_02_controls")
		manager.call("_open_settings")
		await get_tree().create_timer(0.4).timeout
		await _capture("ui_03_pause_settings")
		manager.call("_close_pause_overlay")
	_send_action("pause")
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/ui/Settings.tscn")
	await get_tree().create_timer(1.4).timeout
	await _capture("ui_04_settings")
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
	await get_tree().create_timer(1.4).timeout
	await _capture("ui_05_menu")
	get_tree().quit(0)


func _send_action(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)


func _capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var image := get_viewport().get_texture().get_image()
	image.save_png(CAPTURE_DIR + "%s.png" % label)
