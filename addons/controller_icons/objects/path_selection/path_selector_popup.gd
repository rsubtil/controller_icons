@tool
extends ConfirmationDialog

signal path_selected(path: String)

var editor_interface : EditorInterface

@onready var n_selector := $ControllerIconPathSelector

func populate():
	n_selector.populate(editor_interface)


func _on_controller_icon_path_selector_path_selected(path) -> void:
	path_selected.emit(path)
	hide()


func _on_confirmed() -> void:
	path_selected.emit(n_selector.get_icon_path())
