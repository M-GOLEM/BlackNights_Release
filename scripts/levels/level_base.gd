class_name LevelBase
extends Node2D

@export var chapter := 1
@export var level_width := 3200.0
@export var level_height := 1080.0
@export var start_pos := Vector2(400, 560)
@export var finish_pos := Vector2(3060, 560)
@export var title_en := "CHAPTER I"
@export var title_ar := "الاستيقاظ"
@export var next_level := ""
@export var follow_vertical := false
@export var fall_limit := 1300.0
@export var is_finale := false
@export var camera_y := 420.0

var pal: Dictionary


func _enter_tree() -> void:
	pal = LevelKit.palette(chapter)
	_build()
	_configure()


func _configure() -> void:
	var cam := $Camera2D as Camera2D
	cam.limit_left = 0
	cam.limit_right = int(level_width)
	if follow_vertical:
		cam.limit_top = 0
		cam.limit_bottom = int(level_height)
	else:
		cam.limit_top = -400
		cam.limit_bottom = int(level_height) + 200
	var cy := camera_y
	if follow_vertical:
		cy = start_pos.y - 160.0
	cam.position = Vector2(clampf(start_pos.x, 960.0, maxf(level_width - 960.0, 960.0)), cy)
	var lm := $LevelManager as Node
	lm.chapter_index = chapter
	lm.spawn_point = start_pos
	lm.fall_limit = fall_limit
	lm.follow_vertical = follow_vertical
	lm.is_finale = is_finale
	lm.chapter_title_en = title_en
	lm.chapter_title_ar = title_ar
	lm.next_level_path = next_level
	($CharacterRoot as Node2D).position = start_pos


func _build() -> void:
	LevelKit.build_sky(self, pal)


func add_finish_marker() -> void:
	LevelKit.add_finish(self, finish_pos, pal)
