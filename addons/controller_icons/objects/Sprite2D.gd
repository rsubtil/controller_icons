@tool
extends Sprite2D
class_name ControllerSprite2D

@export var path : String = "":
	set(_path):
		path = _path
		if is_inside_tree():
			texture = ControllerIcons.parse_path(path)
			
@export_enum("Both", "Keyboard/Mouse", "Controller") var show_only : int = 0:
	set(_show_only):
		show_only = _show_only
		_on_input_type_changed(ControllerIcons._last_input_type)

func _ready():
	ControllerIcons.input_type_changed.connect(_on_input_type_changed)
	path = path

func _on_input_type_changed(input_type):
	if show_only == 0 or \
		(show_only == 1 and input_type == ControllerIcons.InputType.KEYBOARD_MOUSE) or \
		(show_only == 2 and input_type == ControllerIcons.InputType.CONTROLLER):
		visible = true
		path = path
	else:
		visible = false
