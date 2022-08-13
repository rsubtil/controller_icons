tool
extends Button
class_name ControllerButton

export(String) var path : String = "" setget set_path

func _ready():
	ControllerIcons.connect("input_type_changed", self, "_on_input_type_changed")
	set_path(path)

func _on_input_type_changed(input_type):
	set_path(path)

func set_path(_path: String):
	path = _path
	if is_inside_tree():
		icon = ControllerIcons.parse_path(path)
