tool
extends TextureRect
class_name ControllerTextureRect

export(String) var path : String = "" setget set_path
export(int) var max_width : int = 40 setget set_max_width

func _ready():
	ControllerIcons.connect("input_type_changed", self, "_on_input_type_changed")
	set_path(path)
	set_max_width(max_width)

func _on_input_type_changed(input_type):
	set_path(path)

func set_path(_path: String):
	path = _path
	if is_inside_tree():
		texture = ControllerIcons.parse_path(path)

func set_max_width(_max_width: int):
	max_width = _max_width
	if is_inside_tree():
		if max_width < 0:
			expand = false
		else:
			expand = true
			rect_min_size.x = max_width
			if texture:
				rect_min_size.y = texture.get_height() * max_width / texture.get_width()
			else:
				rect_min_size.y = rect_min_size.x
