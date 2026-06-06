@tool
extends EditorProperty

var selector : ConfirmationDialog
var line_edit : LineEdit
var button : Button

func _init(editor_interface: EditorInterface):
	add_child(build_tree(editor_interface))

func build_tree(editor_interface: EditorInterface) -> Control:
	selector = preload("res://addons/controller_icons/objects/modifier_selection/modifier_selector_popup.tscn").instantiate()
	selector.editor_interface = editor_interface
	selector.visible = false
	selector.modifier_selected.connect(
		func(path: String):
			emit_changed(get_edited_property(), path)
	)

	var root := HBoxContainer.new()

	line_edit = LineEdit.new()
	line_edit.placeholder_text = "_1"
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.text_changed.connect(func(text):
		emit_changed(get_edited_property(), text)
	)

	button = Button.new()
	# UPGRADE: In Godot 4.2, there's no need to have an instance to
	# EditorInterface, since it's now a static call:
	# button.icon = EditorInterface.get_base_control().get_theme_icon("ListSelect", "EditorIcons")
	button.icon = editor_interface.get_base_control().get_theme_icon("ListSelect", "EditorIcons")
	button.tooltip_text = "Change icon modifiers"
	button.pressed.connect(func():
		var obj := get_edited_object()
		if !obj: return

		assert(obj is ControllerIconTexture)

		selector.populate()
		selector.icon = (obj as ControllerIconTexture)
		selector.popup_centered()
	)

	root.add_child(line_edit)
	root.add_child(button)
	root.add_child(selector)
	return root

func _update_property():
	var new_text = get_edited_object()[get_edited_property()]
	if line_edit.text != new_text:
		line_edit.text = new_text
