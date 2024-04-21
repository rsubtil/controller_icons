@tool
extends EditorPlugin

var inspector_plugin : EditorInspectorPlugin

func _enable_plugin():
	add_autoload_singleton("ControllerIcons", "res://addons/controller_icons/ControllerIcons.gd")

func _disable_plugin():
	remove_autoload_singleton("ControllerIcons")

func _enter_tree():
	inspector_plugin = preload("res://addons/controller_icons/objects/ControllerIconEditorInspector.gd").new()
	inspector_plugin.editor_interface = get_editor_interface()

	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
