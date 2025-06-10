@tool
extends PanelContainer

signal path_selected(path: String)

@onready var n_tab_container := %TabContainer
@onready var n_input_action := %"Input Action"
@onready var n_joypad_path := %"Joypad Path"
@onready var n_specific_path := %"Specific Path"

var input_action_populated := false
var joypad_path_populated := false
var specific_path_populated := false

var editor_interface : EditorInterface

func populate(editor_interface: EditorInterface) -> void:
	self.editor_interface = editor_interface
	
	input_action_populated = false
	joypad_path_populated = false
	specific_path_populated = false
	
	n_tab_container.current_tab = 0

func get_icon_path() -> String:
	return n_tab_container.get_current_tab_control().get_icon_path()


func _on_tab_container_tab_selected(tab = null) -> void:
	match n_tab_container.get_current_tab_control():
		n_input_action:
			if not input_action_populated:
				input_action_populated = true
				n_input_action.populate(editor_interface)
		n_joypad_path:
			if not joypad_path_populated:
				joypad_path_populated = true
				n_joypad_path.populate(editor_interface)
		n_specific_path:
			if not specific_path_populated:
				specific_path_populated = true
				n_specific_path.populate(editor_interface)

	await get_tree().process_frame
	n_tab_container.get_current_tab_control().grab_focus()


func _on_input_action_done() -> void:
	path_selected.emit(n_input_action.get_icon_path())


func _on_joypad_path_done() -> void:
	path_selected.emit(n_joypad_path.get_icon_path())


func _on_specific_path_done() -> void:
	path_selected.emit(n_specific_path.get_icon_path())
