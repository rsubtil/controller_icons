@tool
extends Panel

signal done

@onready var n_name_filter := %NameFilter
@onready var n_builtin_action_button := %BuiltinActionButton
@onready var n_tree := %Tree

class ControllerIcons_Item:
	func _init(tree: Tree, root: TreeItem, path: String, is_default: bool):
		self.is_default = is_default
		self.filtered = true
		tree_item = tree.create_item(root)
		tree_item.set_text(0, path)

		controller_icon_key = ControllerIconTexture.new()
		controller_icon_key.path = path
		controller_icon_key.force_type = 1
		controller_icon_joy = ControllerIconTexture.new()
		controller_icon_joy.path = path
		controller_icon_joy.force_type = 2

		tree_item.set_icon_max_width(1, 48 * controller_icon_key._textures.size())
		tree_item.set_icon_max_width(2, 48 * controller_icon_key._textures.size())
		tree_item.set_icon(1, controller_icon_key)
		tree_item.set_icon(2, controller_icon_joy)

	var is_default : bool
	var tree_item : TreeItem
	var controller_icon_key : ControllerIconTexture
	var controller_icon_joy : ControllerIconTexture

	var show_default : bool:
		set(_show_default):
			show_default = _show_default
			_query_visibility()

	var filtered : bool:
		set(_filtered):
			filtered = _filtered
			_query_visibility()

	func _query_visibility():
		if is_instance_valid(tree_item):
			tree_item.visible = show_default and filtered

var root : TreeItem
var items : Array[ControllerIcons_Item]

func populate(editor_interface: EditorInterface) -> void:
	# Clear
	n_tree.clear()
	## Using clear() triggers a signal and uses freed nodes.
	## Setting the text directly does not.
	n_name_filter.text = "" 
	items.clear()

	n_name_filter.right_icon = editor_interface.get_base_control().get_theme_icon("Search", "EditorIcons")

	# Setup tree columns
	n_tree.set_column_title(0, "Action")
	n_tree.set_column_title(1, "Preview")
	n_tree.set_column_expand(1, false)
	n_tree.set_column_expand(2, false)

	# Force ControllerIcons to reload the input map
	ControllerIcons._parse_input_actions()

	# List with all default input actions
	var default_actions := ControllerIcons._builtin_keys.map(
		func(value: String):
			return value.trim_prefix("input/")
	)

	# Map with all input actions
	root = n_tree.create_item()
	for data in ControllerIcons._custom_input_actions:
		var child := ControllerIcons_Item.new(n_tree, root, data, data in default_actions)
		items.push_back(child)

	set_default_actions_visibility(n_builtin_action_button.button_pressed)

func get_icon_path() -> String:
	var item : TreeItem = n_tree.get_selected()
	if is_instance_valid(item):
		return item.get_text(0)
	return ""

func set_default_actions_visibility(display: bool):
	# UPGRADE: In Godot 4.2, for-loop variables can be
	# statically typed:
	# for item:ControllerIcons_Item in items:
	for item in items:
		item.show_default = display or not item.is_default

func grab_focus() -> void:
	n_name_filter.grab_focus()


func _on_builtin_action_button_toggled(toggled_on: bool) -> void:
	set_default_actions_visibility(toggled_on)


func _on_tree_item_activated() -> void:
	done.emit()


func _on_name_filter_text_changed(new_text: String):
	# UPGRADE: In Godot 4.2, for-loop variables can be
	# statically typed:
	# for item:ControllerIcons_Item in items:
	for item in items:
		var filtered := true if new_text.is_empty() else item.tree_item.get_text(0).findn(new_text) != -1
		item.filtered = filtered
