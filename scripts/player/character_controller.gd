extends CharacterBody2D

const SPEED := 185.0
const RUN_MULTIPLIER := 1.55
const JUMP_VELOCITY := -560.0
const GRAVITY := 1200.0
const ACCELERATION := 1500.0
const FRICTION := 1900.0
const TURN_ANGLE := 1.22

@onready var rig: CharacterAnimator = $SubViewportContainer/SubViewport/Character3D
@onready var shadow_sprite: Sprite2D = $ShadowSprite

var _dust: CPUParticles2D
var _in_water := false
var _on_ladder := false
var _was_on_floor := true
var _facing := 0.0
var _coyote := 0.0
var _jump_buffer := 0.0
var _landed_squash := 1.0

var _breath_timer := 4.0
var _step_count := 0
var _climb_timer := 0.0
var _surface := "stone"


func _ready() -> void:
	_build_dust()
	rig.footstep.connect(_on_footstep)
	rig.landed.connect(_on_landed)
	_breath_timer = randf_range(3.5, 6.0)


func _build_dust() -> void:
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 1))
	grad.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 16
	tex.height = 16
	_dust = CPUParticles2D.new()
	_dust.texture = tex
	_dust.emitting = false
	_dust.one_shot = true
	_dust.amount = 6
	_dust.lifetime = 0.55
	_dust.explosiveness = 0.95
	_dust.direction = Vector2(0, -1)
	_dust.spread = 62.0
	_dust.gravity = Vector2(0, 110)
	_dust.initial_velocity_min = 16.0
	_dust.initial_velocity_max = 40.0
	_dust.scale_amount_min = 0.1
	_dust.scale_amount_max = 0.26
	_dust.color = Color(0.66, 0.68, 0.74, 0.24)
	_dust.position = Vector2(0, -4)
	add_child(_dust)


func _physics_process(delta: float) -> void:
	_coyote = 0.0 if is_on_floor() else _coyote + delta
	if Input.is_action_just_pressed("jump"):
		_jump_buffer = 0.15
	else:
		_jump_buffer = maxf(_jump_buffer - delta, 0.0)

	var wants_up := Input.is_action_pressed("jump")

	if _in_water:
		_water_physics(delta, wants_up)
	elif _on_ladder:
		_ladder_physics(delta)
	else:
		_ground_physics(delta)

	var vy_before := velocity.y
	move_and_slide()
	_track_landing(vy_before)
	_update_turning(delta)
	_update_shadow()
	rig.set_motion(velocity, is_on_floor(), Input.is_action_pressed("run"), _in_water, _on_ladder)
	_update_breath(delta)


func _ground_physics(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, 900.0)

	if _jump_buffer > 0.0 and _coyote < 0.12:
		velocity.y = JUMP_VELOCITY
		_jump_buffer = 0.0
		_coyote = 1.0
		_play_sfx("jump", -6.0, randf_range(0.92, 1.06))
		_play_sfx(_cloth_sfx(), -12.0, randf_range(0.9, 1.1))

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		var speed := SPEED * (RUN_MULTIPLIER if Input.is_action_pressed("run") else 1.0)
		velocity.x = move_toward(velocity.x, direction * speed, ACCELERATION * delta)
		_facing = direction
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)


func _water_physics(delta: float, wants_up: bool) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var speed := SPEED * 0.72
	velocity.x = move_toward(velocity.x, direction * speed, ACCELERATION * 0.6 * delta)
	if direction != 0.0:
		_facing = direction
	var target_y := -60.0
	if wants_up:
		target_y = -230.0
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		target_y = 150.0
	velocity.y = move_toward(velocity.y, target_y, 900.0 * delta)


func _ladder_physics(delta: float) -> void:
	var up := Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var down := Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
	var vy := 0.0
	if up:
		vy = -165.0
	elif down:
		vy = 185.0
	velocity.y = move_toward(velocity.y, vy, 950.0 * delta)
	velocity.x = move_toward(velocity.x, Input.get_axis("move_left", "move_right") * 95.0, 900.0 * delta)
	_climb_timer -= delta
	if absf(velocity.y) > 20.0 and _climb_timer <= 0.0:
		_climb_timer = 0.42
		_play_sfx("step_metal_%d" % randi_range(1, 3), -14.0, randf_range(0.92, 1.08))
	if Input.is_action_just_pressed("jump"):
		_on_ladder = false
		velocity.y = JUMP_VELOCITY * 0.88


func _track_landing(vy_before: float) -> void:
	var on_floor := is_on_floor()
	if on_floor and not _was_on_floor:
		_landed_squash = 0.86
		rig.notify_land(vy_before)
		if vy_before > 220.0 and not _in_water:
			_play_sfx("land", -4.0, randf_range(0.94, 1.05))
			if vy_before > 420.0:
				_play_sfx(_cloth_sfx(), -10.0, randf_range(0.9, 1.1))
	_was_on_floor = on_floor
	_landed_squash = lerpf(_landed_squash, 1.0, 0.18)


func _update_turning(delta: float) -> void:
	var target := 0.0
	if absf(velocity.x) > 12.0 and not _in_water:
		target = TURN_ANGLE * signf(velocity.x)
	rig.rotation.y = lerp_angle(rig.rotation.y, target, minf(1.0, 11.0 * delta))
	rig.scale = Vector3(1.0, _landed_squash, 1.0)


func _update_shadow() -> void:
	var height := clampf(-velocity.y / 900.0, 0.0, 0.35)
	shadow_sprite.scale = Vector2(0.62 - height, 0.24 - height * 0.4)
	shadow_sprite.modulate.a = 1.0 - height


func _update_breath(delta: float) -> void:
	var idle := is_on_floor() and not _in_water and not _on_ladder and absf(velocity.x) < 18.0
	if not idle:
		_breath_timer = minf(_breath_timer, 1.2)
		return
	_breath_timer -= delta
	if _breath_timer <= 0.0:
		_play_sfx("breath_%d" % randi_range(1, 2), -12.0, randf_range(0.9, 1.1))
		_breath_timer = randf_range(4.5, 8.5)


func _on_footstep(_foot: int) -> void:
	_surface = _surface_for_chapter()
	if _surface == "water":
		_play_sfx("step_water_%d" % randi_range(1, 3), -5.0, randf_range(0.9, 1.1))
		_spawn_dust(0.75, Color(0.62, 0.72, 0.82, 0.32))
		return
	var running := Input.is_action_pressed("run")
	_step_count += 1
	var volume := -6.0 if running else -9.0
	_play_sfx("step_%s_%d" % [_surface, randi_range(1, 3)], volume + randf_range(-1.5, 1.0), randf_range(0.88, 1.12))
	_spawn_dust(0.3 if running else 0.15, Color(0.66, 0.68, 0.74, 0.2))
	if running and _step_count % 4 == 0:
		_play_sfx(_cloth_sfx(), -16.0, randf_range(0.9, 1.1))


func _on_landed(impact: float) -> void:
	if _in_water:
		if AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("splash", -7.0, randf_range(0.95, 1.05))
		_spawn_dust(1.0, Color(0.68, 0.78, 0.88, 0.4))
		return
	if impact < 120.0:
		return
	_spawn_dust(clampf(impact / 550.0, 0.3, 1.2), Color(0.66, 0.68, 0.74, 0.3))
	if impact > 280.0:
		var manager := get_tree().current_scene.get_node_or_null("LevelManager") if get_tree().current_scene != null else null
		if manager != null and manager.has_method("add_camera_dip"):
			manager.add_camera_dip(clampf(impact / 80.0, 2.5, 11.0))


func _spawn_dust(strength: float, color: Color) -> void:
	_dust.amount = int(lerpf(5.0, 14.0, clampf(strength, 0.0, 1.0)))
	_dust.initial_velocity_min = lerpf(14.0, 26.0, strength)
	_dust.initial_velocity_max = lerpf(34.0, 84.0, strength)
	_dust.color = color
	_dust.restart()


func _surface_for_chapter() -> String:
	var scene := get_tree().current_scene
	var chapter := 1
	if scene != null:
		var manager := scene.get_node_or_null("LevelManager")
		if manager != null:
			chapter = int(manager.get("chapter_index"))
	match chapter:
		2:
			return "water"
		3, 6:
			return "metal"
		5:
			return "wood"
		_:
			return "stone"


func _cloth_sfx() -> String:
	return "cloth_%d" % randi_range(1, 3)


func set_in_water(value: bool) -> void:
	if _in_water == value:
		return
	_in_water = value
	if not value and velocity.y > -180.0:
		velocity.y = -300.0


func set_on_ladder(value: bool) -> void:
	if value and not _on_ladder:
		_play_sfx("step_metal_2", -9.0, 1.15)
	_on_ladder = value


func is_in_water() -> bool:
	return _in_water


func _play_sfx(sfx_name: String, volume_db := 0.0, pitch := 1.0) -> void:
	if AudioManager != null and AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx(sfx_name, volume_db, pitch)
