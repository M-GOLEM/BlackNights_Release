class_name CharacterModel
extends Node3D

## Sculpts the hooded traveller from lofted meshes at load time. The skeleton
## (Node3D joints) stays untouched so CharacterAnimator keeps driving the pose.

var _cloak: StandardMaterial3D
var _leather: StandardMaterial3D
var _hood_mat: StandardMaterial3D
var _lining: StandardMaterial3D
var _brass: StandardMaterial3D
var _glass: StandardMaterial3D
var _sole: StandardMaterial3D
var _dark: StandardMaterial3D
var _core: StandardMaterial3D


func _ready() -> void:
	_grab_materials()
	_build_torso()
	_build_coat()
	_build_mantle()
	_build_hood()
	_build_boots()
	_build_accessories()
	_build_lantern()


func _grab_materials() -> void:
	var torso := get_node("Hips/Spine/Chest/Torso") as MeshInstance3D
	_cloak = (torso.mesh as PrimitiveMesh).material as StandardMaterial3D
	var hand := get_node("Hips/Spine/Chest/ShoulderL/ElbowL/WristL/HandL") as MeshInstance3D
	_leather = (hand.mesh as PrimitiveMesh).material as StandardMaterial3D
	var hood := get_node("Hips/Spine/Chest/Neck/HeadPivot/Hood") as MeshInstance3D
	_hood_mat = (hood.mesh as PrimitiveMesh).material as StandardMaterial3D
	var head := get_node("Hips/Spine/Chest/Neck/HeadPivot/Head") as MeshInstance3D
	var face := StandardMaterial3D.new()
	face.albedo_color = Color(0.44, 0.35, 0.3)
	face.roughness = 0.62
	face.rim_enabled = true
	face.rim = 0.3
	face.rim_tint = 0.8
	head.material_override = face

	_lining = StandardMaterial3D.new()
	_lining.albedo_color = Color(0.07, 0.028, 0.034)
	_lining.roughness = 0.98

	var legs := StandardMaterial3D.new()
	legs.albedo_color = Color(0.095, 0.098, 0.115)
	legs.roughness = 0.96
	legs.rim_enabled = true
	legs.rim = 0.12
	for name in ["Hips/HipL/ThighL", "Hips/HipL/KneeL/ShinL", "Hips/HipR/ThighR", "Hips/HipR/KneeR/ShinR"]:
		var leg := get_node(name) as MeshInstance3D
		leg.material_override = legs

	_brass = StandardMaterial3D.new()
	_brass.albedo_color = Color(0.52, 0.36, 0.16)
	_brass.metallic = 0.75
	_brass.roughness = 0.34
	_brass.rim_enabled = true
	_brass.rim = 0.5

	_glass = StandardMaterial3D.new()
	_glass.albedo_color = Color(1.0, 0.78, 0.45)
	_glass.emission_enabled = true
	_glass.emission = Color(1.0, 0.62, 0.26)
	_glass.emission_energy_multiplier = 2.4
	_glass.roughness = 0.35

	_sole = StandardMaterial3D.new()
	_sole.albedo_color = Color(0.045, 0.045, 0.05)
	_sole.roughness = 1.0

	_dark = StandardMaterial3D.new()
	_dark.albedo_color = Color(0.025, 0.026, 0.033)
	_dark.roughness = 1.0

	_core = StandardMaterial3D.new()
	_core.albedo_color = Color(1.0, 0.9, 0.7)
	_core.emission_enabled = true
	_core.emission = Color(1.0, 0.82, 0.52)
	_core.emission_energy_multiplier = 6.0


func _build_torso() -> void:
	var node := get_node("Hips/Spine/Chest/Torso") as MeshInstance3D
	node.scale = Vector3.ONE
	var rings := [
		{"y": -0.122, "rx": 0.001, "rz": 0.001},
		{"y": -0.118, "rx": 0.060, "rz": 0.048},
		{"y": -0.090, "rx": 0.068, "rz": 0.053},
		{"y": -0.040, "rx": 0.078, "rz": 0.060},
		{"y": 0.005, "rx": 0.086, "rz": 0.066},
		{"y": 0.045, "rx": 0.093, "rz": 0.064},
		{"y": 0.072, "rx": 0.090, "rz": 0.058},
		{"y": 0.082, "rx": 0.076, "rz": 0.050},
		{"y": 0.088, "rx": 0.001, "rz": 0.001},
	]
	var mesh := _shell(rings, 0.0, TAU, 28, false)
	mesh.surface_set_material(0, _cloak)
	node.mesh = mesh


func _build_coat() -> void:
	var old := get_node_or_null("Hips/Spine/Chest/Cloak")
	if old != null:
		old.visible = false
		old.queue_free()

	var hips := get_node("Hips") as Node3D
	var pivot := Node3D.new()
	pivot.name = "Coat"
	pivot.position = Vector3(0, 0.06, 0)
	hips.add_child(pivot)

	var rings := [
		{"y": -0.260, "rx": 0.158, "rz": 0.132, "wobble": 0.007, "ywave": 0.007},
		{"y": -0.200, "rx": 0.140, "rz": 0.116, "wobble": 0.004},
		{"y": -0.100, "rx": 0.118, "rz": 0.097},
		{"y": -0.020, "rx": 0.102, "rz": 0.084},
		{"y": 0.006, "rx": 0.092, "rz": 0.076},
	]
	var outer := _shell(rings, deg_to_rad(17.0), deg_to_rad(343.0), 40, false)
	var inner := _shell(_inset(rings, 0.007), deg_to_rad(17.0), deg_to_rad(343.0), 40, true)

	var mesh := ArrayMesh.new()
	mesh = _append(mesh, outer)
	mesh = _append(mesh, inner)
	mesh.surface_set_material(0, _cloak)
	mesh.surface_set_material(1, _lining)

	var inst := MeshInstance3D.new()
	inst.name = "CoatMesh"
	inst.mesh = mesh
	pivot.add_child(inst)


func _build_mantle() -> void:
	var chest := get_node("Hips/Spine/Chest") as Node3D
	var inst := MeshInstance3D.new()
	inst.name = "Mantle"
	inst.position = Vector3(0, 0.03, 0)
	var rings := [
		{"y": -0.014, "rx": 0.134, "rz": 0.112, "wobble": 0.005, "ywave": 0.004},
		{"y": 0.030, "rx": 0.122, "rz": 0.104},
		{"y": 0.070, "rx": 0.104, "rz": 0.092},
		{"y": 0.096, "rx": 0.086, "rz": 0.078},
	]
	var mesh := _shell(rings, deg_to_rad(30.0), deg_to_rad(330.0), 32, false)
	mesh.surface_set_material(0, _cloak)
	inst.mesh = mesh
	chest.add_child(inst)


func _build_hood() -> void:
	var node := get_node("Hips/Spine/Chest/Neck/HeadPivot/Hood") as MeshInstance3D
	var rings := [
		{"y": -0.078, "rx": 0.076, "rz": 0.070, "cz": 0.004, "from_deg": 52.0, "to_deg": 308.0},
		{"y": -0.050, "rx": 0.086, "rz": 0.080, "cz": 0.0, "from_deg": 47.0, "to_deg": 313.0},
		{"y": -0.018, "rx": 0.094, "rz": 0.088, "cz": -0.004, "from_deg": 43.0, "to_deg": 317.0},
		{"y": 0.014, "rx": 0.096, "rz": 0.090, "cz": -0.006, "from_deg": 34.0, "to_deg": 326.0},
		{"y": 0.044, "rx": 0.090, "rz": 0.082, "cz": -0.012, "from_deg": 26.0, "to_deg": 334.0},
		{"y": 0.066, "rx": 0.070, "rz": 0.062, "cz": -0.024, "from_deg": 20.0, "to_deg": 340.0},
		{"y": 0.082, "rx": 0.042, "rz": 0.038, "cz": -0.036, "from_deg": 16.0, "to_deg": 344.0},
		{"y": 0.094, "rx": 0.001, "rz": 0.001, "cz": -0.042},
	]
	var from := deg_to_rad(52.0)
	var to := deg_to_rad(308.0)
	var outer := _shell(rings, from, to, 30, false)
	var inner := _shell(_inset(rings, 0.009), from, to, 30, true)
	var mesh := ArrayMesh.new()
	mesh = _append(mesh, outer)
	mesh = _append(mesh, inner)
	mesh.surface_set_material(0, _hood_mat)
	mesh.surface_set_material(1, _dark)
	node.mesh = mesh


func _build_boots() -> void:
	for side in ["L", "R"]:
		var foot := get_node("Hips/Hip%s/Knee%s/Ankle%s/Foot%s" % [side, side, side, side]) as MeshInstance3D
		foot.rotation = Vector3.ZERO
		var sections := [
			{"z": -0.058, "rx": 0.001, "ry": 0.001, "cy": -0.006},
			{"z": -0.052, "rx": 0.025, "ry": 0.019, "cy": -0.006},
			{"z": -0.032, "rx": 0.032, "ry": 0.026, "cy": -0.004},
			{"z": 0.006, "rx": 0.034, "ry": 0.029, "cy": -0.002},
			{"z": 0.050, "rx": 0.035, "ry": 0.027, "cy": -0.003},
			{"z": 0.086, "rx": 0.032, "ry": 0.021, "cy": -0.007},
			{"z": 0.104, "rx": 0.022, "ry": 0.014, "cy": -0.010},
			{"z": 0.109, "rx": 0.001, "ry": 0.001, "cy": -0.011},
		]
		var upper := _z_shell(sections, 18)
		upper.surface_set_material(0, _leather)
		foot.mesh = upper

		var sole := MeshInstance3D.new()
		sole.name = "Sole"
		var box := BoxMesh.new()
		box.size = Vector3(0.044, 0.009, 0.162)
		sole.mesh = box
		sole.position = Vector3(0, -0.0335, 0.024)
		sole.material_override = _sole
		foot.add_child(sole)

		var heel := MeshInstance3D.new()
		heel.name = "Heel"
		var heel_box := BoxMesh.new()
		heel_box.size = Vector3(0.038, 0.01, 0.044)
		heel.mesh = heel_box
		heel.position = Vector3(0, -0.0325, -0.034)
		heel.material_override = _sole
		foot.add_child(heel)


func _build_accessories() -> void:
	var hips := get_node("Hips") as Node3D

	var buckle := MeshInstance3D.new()
	buckle.name = "Buckle"
	var b := BoxMesh.new()
	b.size = Vector3(0.04, 0.03, 0.012)
	buckle.mesh = b
	buckle.position = Vector3(0, 0.058, 0.082)
	buckle.material_override = _brass
	hips.add_child(buckle)

	for entry in [
		{"name": "PouchL", "pos": Vector3(0.082, 0.028, 0.056), "yaw": deg_to_rad(-18.0)},
		{"name": "PouchR", "pos": Vector3(-0.082, 0.028, 0.056), "yaw": deg_to_rad(18.0)},
	]:
		var pouch := MeshInstance3D.new()
		pouch.name = entry["name"]
		var p := BoxMesh.new()
		p.size = Vector3(0.046, 0.058, 0.028)
		pouch.mesh = p
		pouch.position = entry["pos"]
		pouch.rotation.y = entry["yaw"]
		pouch.material_override = _leather
		hips.add_child(pouch)

	var satchel := MeshInstance3D.new()
	satchel.name = "Satchel"
	var s := BoxMesh.new()
	s.size = Vector3(0.048, 0.082, 0.034)
	satchel.mesh = s
	satchel.position = Vector3(0.118, 0.012, -0.004)
	satchel.rotation.z = deg_to_rad(-8.0)
	satchel.material_override = _leather
	hips.add_child(satchel)

	var flap := MeshInstance3D.new()
	flap.name = "SatchelFlap"
	var f := BoxMesh.new()
	f.size = Vector3(0.052, 0.03, 0.038)
	flap.mesh = f
	flap.position = Vector3(0.118, 0.052, -0.004)
	flap.rotation.z = deg_to_rad(-8.0)
	flap.material_override = _leather
	hips.add_child(flap)

	var chest := get_node("Hips/Spine/Chest") as Node3D
	var harness := MeshInstance3D.new()
	harness.name = "Harness"
	var h := BoxMesh.new()
	h.size = Vector3(0.017, 0.215, 0.006)
	harness.mesh = h
	harness.position = Vector3(-0.008, 0.02, 0.066)
	harness.rotation.z = deg_to_rad(-32.0)
	harness.material_override = _leather
	chest.add_child(harness)

	var clasp := MeshInstance3D.new()
	clasp.name = "HarnessClasp"
	var c := BoxMesh.new()
	c.size = Vector3(0.026, 0.024, 0.008)
	clasp.mesh = c
	clasp.position = Vector3(0.03, -0.02, 0.069)
	clasp.material_override = _brass
	chest.add_child(clasp)

	for side in ["L", "R"]:
		var wrist := get_node("Hips/Spine/Chest/Shoulder%s/Elbow%s/Wrist%s" % [side, side, side]) as Node3D
		var cuff := MeshInstance3D.new()
		cuff.name = "Cuff%s" % side
		var ring := TorusMesh.new()
		ring.inner_radius = 0.022
		ring.outer_radius = 0.031
		ring.rings = 14
		ring.ring_segments = 6
		cuff.mesh = ring
		cuff.position = Vector3(0, -0.012, 0)
		cuff.material_override = _leather
		wrist.add_child(cuff)


func _build_lantern() -> void:
	var wrist := get_node("Hips/Spine/Chest/ShoulderR/ElbowR/WristR") as Node3D
	var pivot := Node3D.new()
	pivot.name = "LanternPivot"
	pivot.position = Vector3(0, -0.048, 0.012)
	wrist.add_child(pivot)

	var handle := MeshInstance3D.new()
	handle.name = "Handle"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.010
	torus.outer_radius = 0.016
	torus.rings = 16
	torus.ring_segments = 6
	handle.mesh = torus
	handle.rotation.x = deg_to_rad(90.0)
	handle.position = Vector3(0, 0.014, 0)
	handle.material_override = _brass
	pivot.add_child(handle)

	var top := MeshInstance3D.new()
	top.name = "CapTop"
	var top_mesh := CylinderMesh.new()
	top_mesh.top_radius = 0.014
	top_mesh.bottom_radius = 0.019
	top_mesh.height = 0.010
	top_mesh.radial_segments = 12
	top.mesh = top_mesh
	top.position = Vector3(0, 0.002, 0)
	top.material_override = _brass
	pivot.add_child(top)

	var glass := MeshInstance3D.new()
	glass.name = "Glass"
	var glass_mesh := CylinderMesh.new()
	glass_mesh.top_radius = 0.013
	glass_mesh.bottom_radius = 0.013
	glass_mesh.height = 0.030
	glass_mesh.radial_segments = 12
	glass.mesh = glass_mesh
	glass.position = Vector3(0, -0.018, 0)
	glass.material_override = _glass
	pivot.add_child(glass)

	var bottom := MeshInstance3D.new()
	bottom.name = "CapBottom"
	var bottom_mesh := CylinderMesh.new()
	bottom_mesh.top_radius = 0.019
	bottom_mesh.bottom_radius = 0.014
	bottom_mesh.height = 0.010
	bottom_mesh.radial_segments = 12
	bottom.mesh = bottom_mesh
	bottom.position = Vector3(0, -0.038, 0)
	bottom.material_override = _brass
	pivot.add_child(bottom)

	var core := MeshInstance3D.new()
	core.name = "Core"
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.007
	core_mesh.height = 0.014
	core_mesh.radial_segments = 10
	core_mesh.rings = 6
	core.mesh = core_mesh
	core.position = Vector3(0, -0.018, 0)
	core.material_override = _core
	pivot.add_child(core)

	for i in 3:
		var bar := MeshInstance3D.new()
		bar.name = "Bar%d" % i
		var bar_mesh := BoxMesh.new()
		bar_mesh.size = Vector3(0.0035, 0.032, 0.0035)
		bar.mesh = bar_mesh
		var angle := TAU * float(i) / 3.0
		bar.position = Vector3(sin(angle) * 0.0135, -0.018, cos(angle) * 0.0135)
		bar.material_override = _brass
		pivot.add_child(bar)

	var light := OmniLight3D.new()
	light.name = "Glow"
	light.position = Vector3(0, -0.018, 0.006)
	light.light_color = Color(1.0, 0.72, 0.42)
	light.light_energy = 0.32
	light.omni_range = 0.6
	pivot.add_child(light)


# ---------------------------------------------------------------- geometry

func _shell(rings: Array, theta_from: float, theta_to: float, segments: int, flip: bool) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rows := rings.size()
	var cols := segments + 1
	for r in rows:
		var ring: Dictionary = rings[r]
		var a0 := theta_from
		var a1 := theta_to
		if ring.has("from_deg"):
			a0 = deg_to_rad(float(ring["from_deg"]))
		if ring.has("to_deg"):
			a1 = deg_to_rad(float(ring["to_deg"]))
		for c in cols:
			var t := a0 + (a1 - a0) * float(c) / float(segments)
			var wobble := float(ring.get("wobble", 0.0)) * sin(3.0 * t + 0.7)
			var x := (float(ring["rx"]) + wobble) * sin(t)
			var z := (float(ring["rz"]) + wobble) * cos(t) + float(ring.get("cz", 0.0))
			var y := float(ring["y"]) + float(ring.get("ywave", 0.0)) * sin(2.0 * t + 1.1)
			st.set_uv(Vector2(float(c) / float(segments), float(r) / float(rows - 1)))
			st.add_vertex(Vector3(x, y, z))
	for r in rows - 1:
		for c in segments:
			var i0 := r * cols + c
			var i1 := i0 + 1
			var i2 := i0 + cols
			var i3 := i2 + 1
			if flip:
				st.add_index(i0)
				st.add_index(i2)
				st.add_index(i1)
				st.add_index(i1)
				st.add_index(i2)
				st.add_index(i3)
			else:
				st.add_index(i0)
				st.add_index(i1)
				st.add_index(i2)
				st.add_index(i1)
				st.add_index(i3)
				st.add_index(i2)
	st.generate_normals()
	return st.commit()


func _z_shell(sections: Array, segments: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rows := sections.size()
	var cols := segments + 1
	for r in rows:
		var sec: Dictionary = sections[r]
		for c in cols:
			var a := TAU * float(c) / float(segments)
			var x := float(sec["rx"]) * cos(a)
			var y := float(sec["cy"]) + float(sec["ry"]) * sin(a)
			st.set_uv(Vector2(float(c) / float(segments), float(r) / float(rows - 1)))
			st.add_vertex(Vector3(x, y, float(sec["z"])))
	for r in rows - 1:
		for c in segments:
			var i0 := r * cols + c
			var i1 := i0 + 1
			var i2 := i0 + cols
			var i3 := i2 + 1
			st.add_index(i0)
			st.add_index(i1)
			st.add_index(i2)
			st.add_index(i1)
			st.add_index(i3)
			st.add_index(i2)
	st.generate_normals()
	return st.commit()


func _inset(rings: Array, amount: float) -> Array:
	var out: Array = []
	for ring in rings:
		var copy: Dictionary = ring.duplicate()
		copy["rx"] = maxf(0.001, float(copy["rx"]) - amount)
		copy["rz"] = maxf(0.001, float(copy["rz"]) - amount)
		out.append(copy)
	return out


func _append(base: ArrayMesh, extra: ArrayMesh) -> ArrayMesh:
	# Merge the extra surface into base by re-emitting its triangles.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var arrays := extra.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	for i in indices.size():
		var idx := indices[i]
		st.set_normal(normals[idx])
		st.set_uv(uvs[idx])
		st.add_vertex(verts[idx])
	st.commit(base)
	return base
