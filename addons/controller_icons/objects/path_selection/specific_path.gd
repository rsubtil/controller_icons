@tool
extends Panel

const GODOT_4_6_VERSION = 0x040600

signal done

@onready var n_name_filter := %NameFilter
@onready var n_base_asset_names := %BaseAssetNames
@onready var n_icon_container := %IconContainer

var color_text_enabled : Color
var color_text_disabled : Color

var asset_names_root : TreeItem

func populate(editor_interface: EditorInterface, icon: ControllerIconTexture) -> void:
	## Using clear() triggers a signal and uses freed nodes.
	## Setting the text directly does not.
	n_name_filter.text = ""
	n_base_asset_names.clear()
	n_icon_container.clear()

	var editor_control := editor_interface.get_base_control()
	color_text_enabled = editor_control.get_theme_color("font_color", "Editor")
	color_text_disabled = editor_control.get_theme_color("disabled_font_color", "Editor")
	n_name_filter.right_icon = editor_control.get_theme_icon("Search", "EditorIcons")

	asset_names_root = n_base_asset_names.create_item()

	var icon_pack := ControllerIcons._load_icon_pack(icon.icon_pack)
	assert(icon_pack)
	var base_path := icon_pack._get_root_asset_path()

	# Files first
	handle_files("", base_path, icon_pack)
	# Directories next
	for dir in DirAccess.get_directories_at(base_path):
		handle_files(dir, base_path.path_join(dir), icon_pack)
	
	var child : TreeItem = asset_names_root.get_next_in_tree()
	if child:
		child.select(0)

func handle_files(category: String, base_path: String, icon_pack: ControllerIconPack):
	for file in DirAccess.get_files_at(base_path):
		if file.get_extension() == "import": continue
		create_icon(category, icon_pack._convert_asset_path(file.get_basename()), icon_pack._get_folder_name())

func create_icon(category: String, path: String, icon_pack: String):
	var map_category := "<no category>" if category.is_empty() else category
	if not n_icon_container.button_nodes.has(map_category):
		n_icon_container.button_nodes[map_category] = {}
		var item : TreeItem = n_base_asset_names.create_item(asset_names_root)
		item.set_text(0, map_category)

	var filename := path.get_file()
	if n_icon_container.button_nodes[map_category].has(filename): return

	var icon_path = ("" if category.is_empty() else category + "/") + path.get_file().get_basename()
	n_icon_container.add_icon(map_category, icon_path, icon_pack)

func get_icon_path() -> String:
	var button : Button = n_icon_container.get_selected_icon()
	if button:
		return button.icon.path
	return ""

func grab_focus(hide_focus: bool = false) -> void:
	# UPGRADE: In Godot 4.6, grab_focus has a new internal arg
	# n_name_filter.grab_focus(hide_focus)
	if Engine.get_version_info().hex >= GODOT_4_6_VERSION:
		n_name_filter.call("grab_focus", hide_focus)
	else:
		n_name_filter.grab_focus()


func _on_base_asset_names_item_selected():
	var selected : TreeItem = n_base_asset_names.get_selected()
	if not selected: return

	var category := selected.get_text(0)
	n_icon_container.select_category(category)


func _on_name_filter_text_changed(new_text:String):
	var any_visible := {}
	var asset_name := asset_names_root.get_next_in_tree()
	while asset_name:
		any_visible[asset_name.get_text(0)] = false
		asset_name = asset_name.get_next_in_tree()

	var selected_category : TreeItem = n_base_asset_names.get_selected()

	# UPGRADE: In Godot 4.2, for-loop variables can be
	# statically typed:
	# for key:String in button_nodes.keys():
	# 	for icon:Icon in button_nodes[key].values():
	for key in n_icon_container.button_nodes.keys():
		for icon in n_icon_container.button_nodes[key].values():
			var filtered : bool = true if new_text.is_empty() else icon.path.findn(new_text) != -1
			icon.filtered = filtered
			any_visible[key] = any_visible[key] or filtered
	
	asset_name = asset_names_root.get_next_in_tree()
	while asset_name:
		var category := asset_name.get_text(0)
		if any_visible.has(category): 
			var selectable : bool = any_visible[category]
			asset_name.set_selectable(0, selectable)
			if not selectable:
				asset_name.deselect(0)
			asset_name.set_custom_color(0, color_text_enabled if selectable else color_text_disabled)
		asset_name = asset_name.get_next_in_tree()


func _on_icon_container_icon_selected(Icon: Variant) -> void:
	done.emit()
