extends SceneTree

const LIB_PATH := "res://resources/animation_libraries/noor_animations.tres"
const SM_PATH := "res://resources/animation_libraries/noor_state_machine.tres"
const STATES := ["Idle", "Walk", "Run", "Jump", "Fall", "Swim", "Push", "Climb"]

const HIP_POS := "Visual/Hips:position"
const HIP_ROT := "Visual/Hips:rotation"
const SHO_L := "Visual/Hips/ShoulderL:rotation"
const ELB_L := "Visual/Hips/ShoulderL/ElbowL:rotation"
const SHO_R := "Visual/Hips/ShoulderR:rotation"
const ELB_R := "Visual/Hips/ShoulderR/ElbowR:rotation"
const HIP_L := "Visual/Hips/HipL:rotation"
const KNEE_L := "Visual/Hips/HipL/KneeL:rotation"
const HIP_R := "Visual/Hips/HipR:rotation"
const KNEE_R := "Visual/Hips/HipR/KneeR:rotation"

const HIP_BASE := Vector3(0.0, 0.52, 0.0)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://resources/animation_libraries"))

	var library := AnimationLibrary.new()
	library.add_animation("RESET", _reset())
	for state_name in STATES:
		library.add_animation(state_name, call("_" + state_name.to_lower()))

	var err := ResourceSaver.save(library, LIB_PATH)
	if err != OK:
		push_error("Failed to save animation library: " + error_string(err))
		quit(1)
		return

	var machine := AnimationNodeStateMachine.new()
	machine.resource_name = "StateMachine"
	for state_name in STATES:
		var anim_node := AnimationNodeAnimation.new()
		anim_node.animation = StringName(state_name)
		machine.add_node(state_name, anim_node)
	var start_transition := AnimationNodeStateMachineTransition.new()
	start_transition.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
	machine.add_transition(&"Start", &"Idle", start_transition)
	for from_state in STATES:
		for to_state in STATES:
			if from_state == to_state:
				continue
			var transition := AnimationNodeStateMachineTransition.new()
			transition.xfade_time = 0.18
			transition.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_DISABLED
			machine.add_transition(from_state, to_state, transition)

	err = ResourceSaver.save(machine, SM_PATH)
	if err != OK:
		push_error("Failed to save state machine: " + error_string(err))
		quit(1)
		return

	print("BUILD_OK library=", LIB_PATH, " machine=", SM_PATH)
	quit(0)


func _reset() -> Animation:
	var anim := _anim(0.1, false)
	_pos(anim, HIP_POS, [[0.0, HIP_BASE]])
	_rot(anim, HIP_ROT, [[0.0, Vector3.ZERO]])
	_rot(anim, SHO_L, [[0.0, Vector3.ZERO]])
	_rot(anim, ELB_L, [[0.0, Vector3.ZERO]])
	_rot(anim, SHO_R, [[0.0, Vector3.ZERO]])
	_rot(anim, ELB_R, [[0.0, Vector3.ZERO]])
	_rot(anim, HIP_L, [[0.0, Vector3.ZERO]])
	_rot(anim, KNEE_L, [[0.0, Vector3.ZERO]])
	_rot(anim, HIP_R, [[0.0, Vector3.ZERO]])
	_rot(anim, KNEE_R, [[0.0, Vector3.ZERO]])
	return anim


func _idle() -> Animation:
	var anim := _anim(3.0, true)
	_pos(anim, HIP_POS, [
		[0.0, HIP_BASE], [1.5, HIP_BASE + Vector3(0.0, 0.008, 0.0)], [3.0, HIP_BASE],
	])
	_rot(anim, HIP_ROT, [[0.0, Vector3(1.0, 0, 0)], [1.5, Vector3(2.6, 1.5, 0)], [3.0, Vector3(1.0, 0, 0)]])
	_rot(anim, SHO_L, [[0.0, Vector3(4, 0, 4)], [1.5, Vector3(2, 0, 6)], [3.0, Vector3(4, 0, 4)]])
	_rot(anim, ELB_L, [[0.0, Vector3(-10, 0, 0)], [1.5, Vector3(-14, 0, 0)], [3.0, Vector3(-10, 0, 0)]])
	_rot(anim, SHO_R, [[0.0, Vector3(4, 0, -4)], [1.5, Vector3(2, 0, -6)], [3.0, Vector3(4, 0, -4)]])
	_rot(anim, ELB_R, [[0.0, Vector3(-10, 0, 0)], [1.5, Vector3(-14, 0, 0)], [3.0, Vector3(-10, 0, 0)]])
	_rot(anim, HIP_L, [[0.0, Vector3(-1, 0, 1.5)], [3.0, Vector3(-1, 0, 1.5)]])
	_rot(anim, KNEE_L, [[0.0, Vector3(2, 0, 0)], [3.0, Vector3(2, 0, 0)]])
	_rot(anim, HIP_R, [[0.0, Vector3(-1, 0, -1.5)], [3.0, Vector3(-1, 0, -1.5)]])
	_rot(anim, KNEE_R, [[0.0, Vector3(2, 0, 0)], [3.0, Vector3(2, 0, 0)]])
	return anim


func _walk() -> Animation:
	var anim := _anim(0.85, true)
	_pos(anim, HIP_POS, [
		[0.0, HIP_BASE], [0.2125, HIP_BASE + Vector3(0, 0.022, 0)], [0.425, HIP_BASE],
		[0.6375, HIP_BASE + Vector3(0, 0.022, 0)], [0.85, HIP_BASE],
	])
	_rot(anim, HIP_ROT, [[0.0, Vector3(4, -3, 0)], [0.425, Vector3(4, 3, 0)], [0.85, Vector3(4, -3, 0)]])
	_rot(anim, HIP_L, [
		[0.0, Vector3(-24, 0, 1)], [0.2125, Vector3(-4, 0, 1)], [0.425, Vector3(22, 0, 1)],
		[0.6375, Vector3(6, 0, 1)], [0.85, Vector3(-24, 0, 1)],
	])
	_rot(anim, KNEE_L, [
		[0.0, Vector3(6, 0, 0)], [0.2125, Vector3(10, 0, 0)], [0.425, Vector3(4, 0, 0)],
		[0.6375, Vector3(42, 0, 0)], [0.85, Vector3(6, 0, 0)],
	])
	_rot(anim, HIP_R, [
		[0.0, Vector3(22, 0, -1)], [0.2125, Vector3(6, 0, -1)], [0.425, Vector3(-24, 0, -1)],
		[0.6375, Vector3(-4, 0, -1)], [0.85, Vector3(22, 0, -1)],
	])
	_rot(anim, KNEE_R, [
		[0.0, Vector3(4, 0, 0)], [0.2125, Vector3(42, 0, 0)], [0.425, Vector3(6, 0, 0)],
		[0.6375, Vector3(10, 0, 0)], [0.85, Vector3(4, 0, 0)],
	])
	_rot(anim, SHO_L, [
		[0.0, Vector3(16, 0, 3)], [0.2125, Vector3(2, 0, 3)], [0.425, Vector3(-16, 0, 3)],
		[0.6375, Vector3(2, 0, 3)], [0.85, Vector3(16, 0, 3)],
	])
	_rot(anim, ELB_L, [[0.0, Vector3(-14, 0, 0)], [0.85, Vector3(-14, 0, 0)]])
	_rot(anim, SHO_R, [
		[0.0, Vector3(-16, 0, -3)], [0.2125, Vector3(2, 0, -3)], [0.425, Vector3(16, 0, -3)],
		[0.6375, Vector3(2, 0, -3)], [0.85, Vector3(-16, 0, -3)],
	])
	_rot(anim, ELB_R, [[0.0, Vector3(-14, 0, 0)], [0.85, Vector3(-14, 0, 0)]])
	return anim


func _run() -> Animation:
	var anim := _anim(0.5, true)
	_pos(anim, HIP_POS, [
		[0.0, HIP_BASE], [0.125, HIP_BASE + Vector3(0, 0.05, 0)], [0.25, HIP_BASE],
		[0.375, HIP_BASE + Vector3(0, 0.05, 0)], [0.5, HIP_BASE],
	])
	_rot(anim, HIP_ROT, [[0.0, Vector3(13, -5, 0)], [0.25, Vector3(13, 5, 0)], [0.5, Vector3(13, -5, 0)]])
	_rot(anim, HIP_L, [
		[0.0, Vector3(-48, 0, 1)], [0.125, Vector3(-12, 0, 1)], [0.25, Vector3(42, 0, 1)],
		[0.375, Vector3(8, 0, 1)], [0.5, Vector3(-48, 0, 1)],
	])
	_rot(anim, KNEE_L, [
		[0.0, Vector3(18, 0, 0)], [0.125, Vector3(16, 0, 0)], [0.25, Vector3(8, 0, 0)],
		[0.375, Vector3(88, 0, 0)], [0.5, Vector3(18, 0, 0)],
	])
	_rot(anim, HIP_R, [
		[0.0, Vector3(42, 0, -1)], [0.125, Vector3(8, 0, -1)], [0.25, Vector3(-48, 0, -1)],
		[0.375, Vector3(-12, 0, -1)], [0.5, Vector3(42, 0, -1)],
	])
	_rot(anim, KNEE_R, [
		[0.0, Vector3(8, 0, 0)], [0.125, Vector3(88, 0, 0)], [0.25, Vector3(18, 0, 0)],
		[0.375, Vector3(16, 0, 0)], [0.5, Vector3(8, 0, 0)],
	])
	_rot(anim, SHO_L, [
		[0.0, Vector3(44, 0, 4)], [0.125, Vector3(6, 0, 4)], [0.25, Vector3(-44, 0, 4)],
		[0.375, Vector3(6, 0, 4)], [0.5, Vector3(44, 0, 4)],
	])
	_rot(anim, ELB_L, [[0.0, Vector3(-62, 0, 0)], [0.25, Vector3(-74, 0, 0)], [0.5, Vector3(-62, 0, 0)]])
	_rot(anim, SHO_R, [
		[0.0, Vector3(-44, 0, -4)], [0.125, Vector3(6, 0, -4)], [0.25, Vector3(44, 0, -4)],
		[0.375, Vector3(6, 0, -4)], [0.5, Vector3(-44, 0, -4)],
	])
	_rot(anim, ELB_R, [[0.0, Vector3(-74, 0, 0)], [0.25, Vector3(-62, 0, 0)], [0.5, Vector3(-74, 0, 0)]])
	return anim


func _jump() -> Animation:
	var anim := _anim(0.5, false)
	_pos(anim, HIP_POS, [
		[0.0, HIP_BASE + Vector3(0, -0.04, 0)], [0.14, HIP_BASE + Vector3(0, 0.06, 0)],
		[0.5, HIP_BASE + Vector3(0, 0.04, 0)],
	])
	_rot(anim, HIP_ROT, [[0.0, Vector3(9, 0, 0)], [0.5, Vector3(6, 0, 0)]])
	_rot(anim, HIP_L, [[0.0, Vector3(-16, 0, 1)], [0.14, Vector3(38, 0, 1)], [0.5, Vector3(30, 0, 1)]])
	_rot(anim, KNEE_L, [[0.0, Vector3(20, 0, 0)], [0.14, Vector3(24, 0, 0)], [0.5, Vector3(16, 0, 0)]])
	_rot(anim, HIP_R, [[0.0, Vector3(8, 0, -1)], [0.14, Vector3(-16, 0, -1)], [0.5, Vector3(-26, 0, -1)]])
	_rot(anim, KNEE_R, [[0.0, Vector3(18, 0, 0)], [0.14, Vector3(10, 0, 0)], [0.5, Vector3(64, 0, 0)]])
	_rot(anim, SHO_L, [[0.0, Vector3(-40, 0, 6)], [0.14, Vector3(-126, 0, 10)], [0.5, Vector3(-112, 0, 10)]])
	_rot(anim, ELB_L, [[0.0, Vector3(-40, 0, 0)], [0.5, Vector3(-24, 0, 0)]])
	_rot(anim, SHO_R, [[0.0, Vector3(-40, 0, -6)], [0.14, Vector3(-126, 0, -10)], [0.5, Vector3(-112, 0, -10)]])
	_rot(anim, ELB_R, [[0.0, Vector3(-40, 0, 0)], [0.5, Vector3(-24, 0, 0)]])
	return anim


func _fall() -> Animation:
	var anim := _anim(0.9, true)
	_pos(anim, HIP_POS, [
		[0.0, HIP_BASE + Vector3(0, 0.045, 0)],
		[0.45, HIP_BASE + Vector3(0, 0.06, 0)],
		[0.9, HIP_BASE + Vector3(0, 0.045, 0)],
	])
	_rot(anim, HIP_ROT, [[0.0, Vector3(3, 0, 0)], [0.9, Vector3(3, 0, 0)]])
	_rot(anim, SHO_L, [[0.0, Vector3(-108, 0, 14)], [0.45, Vector3(-96, 0, 20)], [0.9, Vector3(-108, 0, 14)]])
	_rot(anim, ELB_L, [[0.0, Vector3(-30, 0, 0)], [0.45, Vector3(-44, 0, 0)], [0.9, Vector3(-30, 0, 0)]])
	_rot(anim, SHO_R, [[0.0, Vector3(-108, 0, -14)], [0.45, Vector3(-96, 0, -20)], [0.9, Vector3(-108, 0, -14)]])
	_rot(anim, ELB_R, [[0.0, Vector3(-30, 0, 0)], [0.45, Vector3(-44, 0, 0)], [0.9, Vector3(-30, 0, 0)]])
	_rot(anim, HIP_L, [[0.0, Vector3(20, 0, 2)], [0.45, Vector3(10, 0, 2)], [0.9, Vector3(20, 0, 2)]])
	_rot(anim, KNEE_L, [[0.0, Vector3(30, 0, 0)], [0.45, Vector3(46, 0, 0)], [0.9, Vector3(30, 0, 0)]])
	_rot(anim, HIP_R, [[0.0, Vector3(8, 0, -2)], [0.45, Vector3(22, 0, -2)], [0.9, Vector3(8, 0, -2)]])
	_rot(anim, KNEE_R, [[0.0, Vector3(44, 0, 0)], [0.45, Vector3(28, 0, 0)], [0.9, Vector3(44, 0, 0)]])
	return anim


func _swim() -> Animation:
	var anim := _anim(1.2, true)
	_pos(anim, HIP_POS, [
		[0.0, HIP_BASE + Vector3(0, -0.02, 0)], [0.6, HIP_BASE + Vector3(0, 0.02, 0)],
		[1.2, HIP_BASE + Vector3(0, -0.02, 0)],
	])
	_rot(anim, HIP_ROT, [[0.0, Vector3(58, 0, 0)], [0.6, Vector3(62, 0, 0)], [1.2, Vector3(58, 0, 0)]])
	_rot(anim, SHO_L, [
		[0.0, Vector3(-70, 0, 16)], [0.3, Vector3(-150, 0, 26)], [0.6, Vector3(-60, 0, 18)],
		[0.9, Vector3(-140, 0, 24)], [1.2, Vector3(-70, 0, 16)],
	])
	_rot(anim, ELB_L, [[0.0, Vector3(-30, 0, 0)], [0.6, Vector3(-52, 0, 0)], [1.2, Vector3(-30, 0, 0)]])
	_rot(anim, SHO_R, [
		[0.0, Vector3(-150, 0, -26)], [0.3, Vector3(-60, 0, -18)], [0.6, Vector3(-140, 0, -24)],
		[0.9, Vector3(-70, 0, -16)], [1.2, Vector3(-150, 0, -26)],
	])
	_rot(anim, ELB_R, [[0.0, Vector3(-52, 0, 0)], [0.6, Vector3(-30, 0, 0)], [1.2, Vector3(-52, 0, 0)]])
	_rot(anim, HIP_L, [[0.0, Vector3(16, 0, 3)], [0.6, Vector3(-8, 0, 3)], [1.2, Vector3(16, 0, 3)]])
	_rot(anim, KNEE_L, [[0.0, Vector3(36, 0, 0)], [0.6, Vector3(12, 0, 0)], [1.2, Vector3(36, 0, 0)]])
	_rot(anim, HIP_R, [[0.0, Vector3(-8, 0, -3)], [0.6, Vector3(16, 0, -3)], [1.2, Vector3(-8, 0, -3)]])
	_rot(anim, KNEE_R, [[0.0, Vector3(12, 0, 0)], [0.6, Vector3(36, 0, 0)], [1.2, Vector3(12, 0, 0)]])
	return anim


func _push() -> Animation:
	var anim := _anim(1.0, true)
	_pos(anim, HIP_POS, [
		[0.0, HIP_BASE + Vector3(0, -0.02, 0)], [0.5, HIP_BASE + Vector3(0, 0.0, 0)],
		[1.0, HIP_BASE + Vector3(0, -0.02, 0)],
	])
	_rot(anim, HIP_ROT, [[0.0, Vector3(24, 0, 0)], [0.5, Vector3(27, 0, 0)], [1.0, Vector3(24, 0, 0)]])
	_rot(anim, SHO_L, [[0.0, Vector3(-82, 0, 12)], [0.5, Vector3(-76, 0, 12)], [1.0, Vector3(-82, 0, 12)]])
	_rot(anim, ELB_L, [[0.0, Vector3(-10, 0, 0)], [1.0, Vector3(-10, 0, 0)]])
	_rot(anim, SHO_R, [[0.0, Vector3(-82, 0, -12)], [0.5, Vector3(-76, 0, -12)], [1.0, Vector3(-82, 0, -12)]])
	_rot(anim, ELB_R, [[0.0, Vector3(-10, 0, 0)], [1.0, Vector3(-10, 0, 0)]])
	_rot(anim, HIP_L, [[0.0, Vector3(-26, 0, 1)], [0.5, Vector3(18, 0, 1)], [1.0, Vector3(-26, 0, 1)]])
	_rot(anim, KNEE_L, [[0.0, Vector3(12, 0, 0)], [0.5, Vector3(32, 0, 0)], [1.0, Vector3(12, 0, 0)]])
	_rot(anim, HIP_R, [[0.0, Vector3(18, 0, -1)], [0.5, Vector3(-26, 0, -1)], [1.0, Vector3(18, 0, -1)]])
	_rot(anim, KNEE_R, [[0.0, Vector3(32, 0, 0)], [0.5, Vector3(12, 0, 0)], [1.0, Vector3(32, 0, 0)]])
	return anim


func _climb() -> Animation:
	var anim := _anim(1.0, true)
	_pos(anim, HIP_POS, [
		[0.0, HIP_BASE], [0.25, HIP_BASE + Vector3(0, 0.03, 0)], [0.5, HIP_BASE],
		[0.75, HIP_BASE + Vector3(0, 0.03, 0)], [1.0, HIP_BASE],
	])
	_rot(anim, HIP_ROT, [[0.0, Vector3(6, -4, 0)], [0.5, Vector3(6, 4, 0)], [1.0, Vector3(6, -4, 0)]])
	_rot(anim, SHO_L, [[0.0, Vector3(-158, 0, 12)], [0.5, Vector3(-104, 0, 10)], [1.0, Vector3(-158, 0, 12)]])
	_rot(anim, ELB_L, [[0.0, Vector3(-16, 0, 0)], [0.5, Vector3(-48, 0, 0)], [1.0, Vector3(-16, 0, 0)]])
	_rot(anim, SHO_R, [[0.0, Vector3(-104, 0, -10)], [0.5, Vector3(-158, 0, -12)], [1.0, Vector3(-104, 0, -10)]])
	_rot(anim, ELB_R, [[0.0, Vector3(-48, 0, 0)], [0.5, Vector3(-16, 0, 0)], [1.0, Vector3(-48, 0, 0)]])
	_rot(anim, HIP_L, [[0.0, Vector3(26, 0, 2)], [0.5, Vector3(-12, 0, 2)], [1.0, Vector3(26, 0, 2)]])
	_rot(anim, KNEE_L, [[0.0, Vector3(54, 0, 0)], [0.5, Vector3(18, 0, 0)], [1.0, Vector3(54, 0, 0)]])
	_rot(anim, HIP_R, [[0.0, Vector3(-12, 0, -2)], [0.5, Vector3(26, 0, -2)], [1.0, Vector3(-12, 0, -2)]])
	_rot(anim, KNEE_R, [[0.0, Vector3(18, 0, 0)], [0.5, Vector3(54, 0, 0)], [1.0, Vector3(18, 0, 0)]])
	return anim


func _anim(length: float, loop: bool) -> Animation:
	var anim := Animation.new()
	anim.length = length
	anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	return anim


func _rot(anim: Animation, path: String, keys: Array) -> void:
	var track := anim.add_track(Animation.TYPE_ROTATION_3D)
	anim.track_set_path(track, NodePath(path))
	for key in keys:
		var euler: Vector3 = key[1]
		var radians := Vector3(deg_to_rad(euler.x), deg_to_rad(euler.y), deg_to_rad(euler.z))
		anim.rotation_track_insert_key(track, key[0], Quaternion.from_euler(radians))
	anim.track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC)


func _pos(anim: Animation, path: String, keys: Array) -> void:
	var track := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(track, NodePath(path))
	for key in keys:
		anim.position_track_insert_key(track, key[0], key[1])
	anim.track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC)
