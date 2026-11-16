class_name CharacterAnimator
extends Node3D

## Procedural pose engine for the hooded traveller. The controller feeds motion
## state every physics tick; this node poses the rig every render frame so the
## gait stays smooth even when physics and rendering tick at different rates.

signal footstep(foot: int)
signal landed(impact: float)

const HIP_HEIGHT := 0.50
const STEP_STRIDE_WALK := 88.0
const STEP_STRIDE_RUN := 128.0


class Pose:
	var hips_pos := Vector3(0.0, HIP_HEIGHT, 0.0)
	var hips_rot := Vector3.ZERO
	var spine_rot := Vector3.ZERO
	var chest_rot := Vector3.ZERO
	var head_rot := Vector3.ZERO
	var sh_l := Vector3(0.0, 0.0, 0.075)
	var sh_r := Vector3(0.0, 0.0, -0.075)
	var el_l := Vector3(-0.18, 0.0, 0.0)
	var el_r := Vector3(-0.18, 0.0, 0.0)
	var wr_l := Vector3.ZERO
	var wr_r := Vector3.ZERO
	var hp_l := Vector3.ZERO
	var hp_r := Vector3.ZERO
	var kn_l := Vector3(0.05, 0.0, 0.0)
	var kn_r := Vector3(0.05, 0.0, 0.0)
	var an_l := Vector3.ZERO
	var an_r := Vector3.ZERO


@onready var hips: Node3D = $Visual/Hips
@onready var spine: Node3D = $Visual/Hips/Spine
@onready var chest: Node3D = $Visual/Hips/Spine/Chest
@onready var neck: Node3D = $Visual/Hips/Spine/Chest/Neck
@onready var head: Node3D = $Visual/Hips/Spine/Chest/Neck/HeadPivot
@onready var scarf_root: Node3D = $Visual/Hips/Spine/Chest/Neck/ScarfRoot
@onready var scarf_mid: Node3D = $Visual/Hips/Spine/Chest/Neck/ScarfRoot/ScarfLink1
@onready var scarf_tip: Node3D = $Visual/Hips/Spine/Chest/Neck/ScarfRoot/ScarfLink1/ScarfLink2
@onready var shoulder_l: Node3D = $Visual/Hips/Spine/Chest/ShoulderL
@onready var elbow_l: Node3D = $Visual/Hips/Spine/Chest/ShoulderL/ElbowL
@onready var wrist_l: Node3D = $Visual/Hips/Spine/Chest/ShoulderL/ElbowL/WristL
@onready var shoulder_r: Node3D = $Visual/Hips/Spine/Chest/ShoulderR
@onready var elbow_r: Node3D = $Visual/Hips/Spine/Chest/ShoulderR/ElbowR
@onready var wrist_r: Node3D = $Visual/Hips/Spine/Chest/ShoulderR/ElbowR/WristR
@onready var hip_l: Node3D = $Visual/Hips/HipL
@onready var knee_l: Node3D = $Visual/Hips/HipL/KneeL
@onready var ankle_l: Node3D = $Visual/Hips/HipL/KneeL/AnkleL
@onready var hip_r: Node3D = $Visual/Hips/HipR
@onready var knee_r: Node3D = $Visual/Hips/HipR/KneeR
@onready var ankle_r: Node3D = $Visual/Hips/HipR/KneeR/AnkleR
@onready var coat: Node3D = get_node_or_null("Visual/Hips/Coat")
@onready var lantern: Node3D = get_node_or_null("Visual/Hips/Spine/Chest/ShoulderR/ElbowR/WristR/LanternPivot")

var _velocity := Vector2.ZERO
var _on_floor := true
var _running := false
var _in_water := false
var _on_ladder := false

var _state := "Idle"
var _clock := 0.0
var _phase := 0.0
var _speed := 0.0
var _gait := 0.0
var _step_index := 0
var _land_time := 10.0
var _land_amp := 0.0
var _scarf_root_x := 0.0
var _scarf_mid_x := 0.0
var _scarf_tip_x := 0.0


func set_motion(velocity: Vector2, on_floor: bool, running: bool, in_water: bool, on_ladder: bool) -> void:
	_velocity = velocity
	_on_floor = on_floor
	_running = running
	_in_water = in_water
	_on_ladder = on_ladder


func notify_land(impact: float) -> void:
	_land_time = 0.0
	_land_amp = clampf(impact / 650.0, 0.15, 1.0)
	landed.emit(clampf(impact, 0.0, 900.0))


func state_name() -> String:
	return _state


func _process(delta: float) -> void:
	_clock += delta
	_speed = absf(_velocity.x)
	_resolve_state()
	var run_blend := clampf((_speed - 185.0) / 100.0, 0.0, 1.0)
	if _running and _speed > 200.0:
		run_blend = maxf(run_blend, 0.55)
	_advance_gait(delta, run_blend)

	var p := Pose.new()
	if _state == "Jump" or _state == "Fall":
		_pose_air(p)
	elif _state == "Swim":
		_pose_swim(p)
	elif _state == "Climb":
		_pose_climb(p)
	else:
		_pose_ground(p, run_blend)
	_apply_land(delta, p)

	_blend_position(hips, p.hips_pos, 18.0, delta)
	_blend_rotation(hips, p.hips_rot, 14.0, delta)
	_blend_rotation(spine, p.spine_rot, 13.0, delta)
	_blend_rotation(chest, p.chest_rot, 11.0, delta)
	_blend_rotation(neck, Vector3(p.head_rot.x * -0.25, p.head_rot.y * -0.3, 0.0), 10.0, delta)
	_blend_rotation(head, p.head_rot, 12.0, delta)
	_blend_rotation(shoulder_l, p.sh_l, 16.0, delta)
	_blend_rotation(shoulder_r, p.sh_r, 16.0, delta)
	_blend_rotation(elbow_l, p.el_l, 18.0, delta)
	_blend_rotation(elbow_r, p.el_r, 18.0, delta)
	_blend_rotation(wrist_l, p.wr_l, 14.0, delta)
	_blend_rotation(wrist_r, p.wr_r, 14.0, delta)
	_blend_rotation(hip_l, p.hp_l, 20.0, delta)
	_blend_rotation(hip_r, p.hp_r, 20.0, delta)
	_blend_rotation(knee_l, p.kn_l, 20.0, delta)
	_blend_rotation(knee_r, p.kn_r, 20.0, delta)
	_blend_rotation(ankle_l, p.an_l, 16.0, delta)
	_blend_rotation(ankle_r, p.an_r, 16.0, delta)
	_update_scarf(delta)
	_update_cloth_accessories(delta, run_blend)


func _resolve_state() -> void:
	if _in_water:
		_state = "Swim"
	elif _on_ladder:
		_state = "Climb"
	elif not _on_floor:
		_state = "Jump" if _velocity.y < -30.0 else "Fall"
	elif _speed > 26.0:
		_state = "Run" if _running and _speed > 200.0 else "Walk"
	else:
		_state = "Idle"


func _advance_gait(delta: float, run_blend: float) -> void:
	var moving := _state == "Walk" or _state == "Run"
	var target := 1.0 if moving else 0.0
	_gait = move_toward(_gait, target, delta * 4.5)
	if not moving or _speed < 12.0:
		return
	var stride := lerpf(STEP_STRIDE_WALK, STEP_STRIDE_RUN, run_blend)
	var before := _phase
	_phase = fmod(_phase + _speed / stride * PI * delta, TAU)
	var wrapped := before > _phase
	if wrapped:
		_footstep(1 if _step_index == 0 else 0)
		_step_index = int(floor(_phase / PI))
		return
	var index := int(floor(_phase / PI))
	if index != _step_index:
		_step_index = index
		_footstep(index % 2)


func _footstep(foot: int) -> void:
	if _on_floor and not _in_water and _gait > 0.45:
		footstep.emit(foot)


func _pose_ground(p: Pose, run_blend: float) -> void:
	var g := _gait
	var idle := 1.0 - g
	var phase := _phase
	var swing := sin(phase)
	var cos_p := cos(phase)
	var hip_amp := lerpf(0.42, 0.70, run_blend)
	var knee_amp := lerpf(0.72, 1.05, run_blend)
	var arm_amp := lerpf(0.34, 0.62, run_blend)
	var bob := lerpf(0.018, 0.036, run_blend)
	var lean := lerpf(0.07, 0.22, run_blend)
	var yaw := lerpf(0.08, 0.15, run_blend)
	var lift_l := maxf(0.0, -swing)
	var lift_r := maxf(0.0, swing)

	p.hips_pos.y -= bob * (0.5 + 0.5 * cos(phase * 2.0)) * g
	p.hips_pos.x -= 0.012 * swing * g
	p.hips_rot.y = yaw * swing * g
	p.hips_rot.z = 0.035 * swing * g
	p.spine_rot.x = lean * g
	p.spine_rot.y = -yaw * 0.75 * swing * g
	p.spine_rot.z = -0.03 * swing * g
	p.chest_rot.y = -0.05 * swing * g
	p.head_rot.x = -lean * 0.72 * g
	p.head_rot.y = 0.04 * swing * g - 0.03 * run_blend * g

	p.hp_l.x = -hip_amp * cos_p * g
	p.hp_r.x = hip_amp * cos_p * g
	p.kn_l.x = 0.05 + (knee_amp * pow(lift_l, 1.35) + 0.10 * maxf(0.0, cos_p)) * g
	p.kn_r.x = 0.05 + (knee_amp * pow(lift_r, 1.35) + 0.10 * maxf(0.0, -cos_p)) * g
	p.an_l.x = (-p.hp_l.x - p.kn_l.x) * 0.5 * g + 0.12 * lift_l * g
	p.an_r.x = (-p.hp_r.x - p.kn_r.x) * 0.5 * g + 0.12 * lift_r * g

	p.sh_l.x = arm_amp * cos_p * g - 0.02 * run_blend * g
	p.sh_r.x = -arm_amp * cos_p * g - 0.02 * run_blend * g
	p.sh_l.z = 0.075 + 0.03 * run_blend * g
	p.sh_r.z = -0.075 - 0.03 * run_blend * g
	p.el_l.x = -0.18 - 0.30 * maxf(0.0, -cos_p) * g - 0.16 * run_blend * g
	p.el_r.x = -0.18 - 0.30 * maxf(0.0, cos_p) * g - 0.16 * run_blend * g

	var breathe := sin(_clock * 1.55)
	var shift := sin(_clock * 0.42)
	p.hips_pos.y += 0.006 * breathe * idle
	p.hips_pos.x += 0.013 * shift * idle
	p.hips_rot.z += 0.022 * shift * idle
	p.spine_rot.x += -0.01 * breathe * idle
	p.chest_rot.x = -0.022 * breathe * idle
	p.head_rot.y += 0.09 * sin(_clock * 0.23) * idle
	p.head_rot.x += -0.02 * sin(_clock * 0.31) * idle
	p.sh_l.x += 0.022 * breathe * idle
	p.sh_r.x += 0.022 * breathe * idle
	p.el_l.x += -0.03 * breathe * idle
	p.el_r.x += -0.03 * breathe * idle


func _pose_air(p: Pose) -> void:
	if _state == "Jump":
		p.hp_l.x = -0.46
		p.hp_r.x = 0.20
		p.kn_l.x = 0.80
		p.kn_r.x = 0.34
		p.an_l.x = 0.30
		p.an_r.x = -0.12
		p.sh_l = Vector3(0.38, 0.0, 0.32)
		p.sh_r = Vector3(0.38, 0.0, -0.32)
		p.el_l.x = -0.55
		p.el_r.x = -0.55
		p.spine_rot.x = 0.06
		p.head_rot.x = -0.04
		p.hips_pos.y += 0.012
	else:
		p.hp_l.x = -0.18
		p.hp_r.x = 0.26
		p.kn_l.x = 0.28
		p.kn_r.x = 0.46
		p.an_l.x = 0.10
		p.an_r.x = 0.06
		p.sh_l = Vector3(0.52, 0.0, 0.85)
		p.sh_r = Vector3(0.52, 0.0, -0.85)
		p.el_l.x = -0.38
		p.el_r.x = -0.38
		p.spine_rot.x = -0.06
		p.head_rot.x = 0.06
		p.hips_rot.z = 0.02 * sin(_clock * 5.0)


func _pose_swim(p: Pose) -> void:
	var t := _clock * 2.2
	p.hp_l.x = -0.32 + 0.26 * sin(t)
	p.hp_r.x = -0.32 - 0.26 * sin(t)
	p.kn_l.x = 0.55 + 0.28 * sin(t + 0.6)
	p.kn_r.x = 0.55 - 0.28 * sin(t + 0.6)
	p.an_l.x = 0.22
	p.an_r.x = 0.22
	p.sh_l = Vector3(-0.95 + 0.45 * sin(t + PI), 0.0, 0.34)
	p.sh_r = Vector3(-0.95 - 0.45 * sin(t + PI), 0.0, -0.34)
	p.el_l.x = -0.55
	p.el_r.x = -0.55
	p.hips_pos.y += -0.05 + 0.018 * sin(_clock * 1.35)
	p.hips_rot.z = 0.04 * sin(t * 0.5)
	p.spine_rot.x = 0.26
	p.spine_rot.y = 0.05 * sin(t * 0.5)
	p.head_rot.x = -0.30
	p.head_rot.y = 0.05 * sin(_clock * 0.4)


func _pose_climb(p: Pose) -> void:
	var moving := absf(_velocity.y) > 12.0
	var t := _clock * (3.0 if moving else 0.9)
	p.sh_l = Vector3(-2.18 + 0.28 * sin(t), 0.0, 0.18)
	p.sh_r = Vector3(-2.18 - 0.28 * sin(t), 0.0, -0.18)
	p.el_l.x = -0.55
	p.el_r.x = -0.55
	p.hp_l.x = -0.32 + 0.20 * sin(t)
	p.hp_r.x = -0.32 - 0.20 * sin(t)
	p.kn_l.x = 0.62
	p.kn_r.x = 0.62
	p.an_l.x = 0.18
	p.an_r.x = 0.18
	p.spine_rot.x = 0.10
	p.spine_rot.y = 0.06 * sin(t)
	p.head_rot.x = -0.16
	p.hips_pos.y += 0.012 * sin(t * 2.0)


func _apply_land(delta: float, p: Pose) -> void:
	if _land_time > 1.4:
		return
	_land_time += delta
	var c := _land_amp * exp(-5.5 * _land_time) * cos(13.0 * _land_time)
	if c <= 0.0:
		return
	p.hips_pos.y -= 0.085 * c
	p.kn_l.x += 0.50 * c
	p.kn_r.x += 0.50 * c
	p.spine_rot.x += 0.16 * c
	p.sh_l.z += 0.18 * c
	p.sh_r.z -= 0.18 * c


func _update_scarf(delta: float) -> void:
	var target_root := clampf(_speed * 0.0018, 0.0, 0.34) + 0.04
	if _state == "Swim":
		target_root = -0.26
	elif _state == "Climb":
		target_root = 0.10
	elif _state == "Jump" or _state == "Fall":
		target_root = 0.30 if _velocity.y > 0.0 else 0.20
	_scarf_root_x = lerpf(_scarf_root_x, target_root, 1.0 - exp(-5.0 * delta))
	_scarf_mid_x = lerpf(_scarf_mid_x, _scarf_root_x * 1.22, 1.0 - exp(-4.0 * delta))
	_scarf_tip_x = lerpf(_scarf_tip_x, _scarf_mid_x * 1.18, 1.0 - exp(-3.2 * delta))
	var breeze := 0.05 * sin(_clock * 0.85)
	var sway := 0.07 * sin(_clock * 0.62)
	scarf_root.rotation = Vector3(0.1 + _scarf_root_x + breeze, 0.16 * sin(_clock * 0.5), 0.16 + sway)
	scarf_mid.rotation = Vector3(0.09 + _scarf_mid_x - _scarf_root_x, 0.10 * sin(_clock * 0.5 + 0.9), 0.08 * sin(_clock * 0.7 + 1.1))
	scarf_tip.rotation = Vector3(0.07 + _scarf_tip_x - _scarf_mid_x, 0.08 * sin(_clock * 0.5 + 1.8), 0.06 * sin(_clock * 0.7 + 2.2))


func _update_cloth_accessories(delta: float, run_blend: float) -> void:
	var g := _gait
	if coat != null:
		var speed_lean := clampf(_speed / 420.0, 0.0, 1.0)
		var target_x := 0.05 * g + 0.12 * speed_lean + 0.05 * run_blend + 0.02 * sin(_phase * 2.0) * g
		if _state == "Fall":
			target_x = -0.08
		elif _state == "Jump":
			target_x = 0.02
		coat.rotation.x = lerpf(coat.rotation.x, target_x, minf(1.0, 6.0 * delta))
		coat.rotation.z = lerpf(coat.rotation.z, 0.05 * sin(_phase) * g, minf(1.0, 5.0 * delta))
	if lantern != null:
		var swing := 0.32 * sin(_phase + 0.6) * g + 0.08 * clampf(_speed / 500.0, 0.0, 1.0)
		var target := Vector3(swing, 0.0, 0.10 * sin(_phase * 0.5) * g)
		if _state == "Jump" or _state == "Fall":
			target.x = -0.20
		lantern.rotation = lantern.rotation.lerp(target, minf(1.0, 5.0 * delta))


func _blend_rotation(node: Node3D, target: Vector3, rate: float, delta: float) -> void:
	var t := 1.0 - exp(-rate * delta)
	node.rotation.x = lerp_angle(node.rotation.x, target.x, t)
	node.rotation.y = lerp_angle(node.rotation.y, target.y, t)
	node.rotation.z = lerp_angle(node.rotation.z, target.z, t)


func _blend_position(node: Node3D, target: Vector3, rate: float, delta: float) -> void:
	node.position = node.position.lerp(target, 1.0 - exp(-rate * delta))
