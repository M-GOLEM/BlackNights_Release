class_name UiTheme
extends RefCounted


static func build() -> Theme:
	var theme := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI", "Tahoma", "Arial"])
	theme.default_font = font
	theme.default_font_size = 26

	theme.set_color("font_color", "Label", Color(0.78, 0.78, 0.81, 1))
	theme.set_color("font_color", "Button", Color(0.74, 0.74, 0.77, 1))
	theme.set_color("font_hover_color", "Button", Color(0.95, 0.95, 0.97, 1))
	theme.set_color("font_pressed_color", "Button", Color(0.55, 0.55, 0.58, 1))
	theme.set_color("font_focus_color", "Button", Color(0.95, 0.95, 0.97, 1))
	theme.set_color("font_disabled_color", "Button", Color(0.32, 0.32, 0.34, 1))

	theme.set_stylebox("normal", "Button", _flat(Color(0.055, 0.055, 0.065, 0.9), Color(0.22, 0.22, 0.24, 1)))
	theme.set_stylebox("hover", "Button", _flat(Color(0.11, 0.11, 0.125, 0.95), Color(0.55, 0.55, 0.6, 1)))
	theme.set_stylebox("pressed", "Button", _flat(Color(0.16, 0.16, 0.18, 1), Color(0.7, 0.7, 0.75, 1)))
	theme.set_stylebox("focus", "Button", _flat(Color(0, 0, 0, 0), Color(0.62, 0.62, 0.68, 1)))
	theme.set_stylebox("disabled", "Button", _flat(Color(0.05, 0.05, 0.055, 0.6), Color(0.16, 0.16, 0.18, 1)))

	theme.set_color("font_color", "CheckButton", Color(0.74, 0.74, 0.77, 1))
	theme.set_color("font_hover_color", "CheckButton", Color(0.95, 0.95, 0.97, 1))
	theme.set_color("font_pressed_color", "CheckButton", Color(0.74, 0.74, 0.77, 1))

	return theme


static func _flat(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_content_margin_all(12)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	return style
