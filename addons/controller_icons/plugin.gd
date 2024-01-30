@tool
extends EditorPlugin

var inspector_plugin : EditorInspectorPlugin

func _enter_tree():
	inspector_plugin = preload("res://addons/controller_icons/objects/ControllerIconEditorInspector.gd").new()
	inspector_plugin.editor_interface = get_editor_interface()

	add_autoload_singleton("ControllerIcons", "res://addons/controller_icons/ControllerIcons.gd")
	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
	remove_autoload_singleton("ControllerIcons")
