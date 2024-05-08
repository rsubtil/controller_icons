@tool
extends Panel

signal done

@onready var n_name_filter := %NameFilter
@onready var n_base_asset_names := %BaseAssetNames
@onready var n_assets_container := %AssetsContainer

var _last_pressed_icon : ControllerIcons_Icon
var _last_pressed_timestamp : int

var color_text_enabled : Color
var color_text_disabled : Color

class ControllerIcons_Icon:
	static var group := ButtonGroup.new()

	func _init(category: String, path: String):
		self.category = category
		self.filtered = true
		self.path = path.get_slice("/", 1)

		button = Button.new()
		button.custom_minimum_size = Vector2(100, 100)
		button.clip_text = true
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.expand_icon = true
		button.toggle_mode = true
		button.button_group = group
		button.text = self.path

		var icon = ControllerIconTexture.new()
		icon.path = path
		button.icon = icon

	var button : Button
	var category : String
	var path : String
	
	var selected: bool:
		set(_selected):
			selected = _selected
			_query_visibility()
	
	var filtered: bool:
		set(_filtered):
			filtered = _filtered
			_query_visibility()
	
	func _query_visibility():
		if is_instance_valid(button):
			button.visible = selected and filtered

var button_nodes := {}
var asset_names_root : TreeItem

func populate(editor_interface: EditorInterface) -> void:
	## Using clear() triggers a signal and uses freed nodes.
	## Setting the text directly does not.
	n_name_filter.text = ""
	n_base_asset_names.clear()
	button_nodes.clear()
	for child in n_assets_container.get_children():
		n_assets_container.remove_child(child)
		child.queue_free()

	# UPGRADE: In Godot 4.2, there's no need to have an instance to
	# EditorInterface, since it's now a static call:
	# var editor_control := EditorInterface.get_base_control()
	var editor_control := editor_interface.get_base_control()
	color_text_enabled = editor_control.get_theme_color("font_color", "Editor")
	color_text_disabled = editor_control.get_theme_color("disabled_font_color", "Editor")
	n_name_filter.right_icon = editor_control.get_theme_icon("Search", "EditorIcons")

	asset_names_root = n_base_asset_names.create_item()

	var base_paths := [
		ControllerIcons._settings.custom_asset_dir,
		"res://addons/controller_icons/assets"
	]

	# UPGRADE: In Godot 4.2, for-loop variables can be
	# statically typed:
	# for base_path:String in base_paths:
	for base_path in base_paths:
		if base_path.is_empty() or not base_path.begins_with("res://"):
			continue
		# Files first
		handle_files("", base_path)
		# Directories next
		for dir in DirAccess.get_directories_at(base_path):
			handle_files(dir, base_path.path_join(dir))
	
	var child : TreeItem = asset_names_root.get_next_in_tree()
	if child:
		child.select(0)

func handle_files(category: String, base_path: String):
	for file in DirAccess.get_files_at(base_path):
		if file.get_extension() == ControllerIcons._base_extension:
			create_icon(category, base_path.path_join(file))

func create_icon(category: String, path: String):
	var map_category := "<no category>" if category.is_empty() else category
	if not button_nodes.has(map_category):
		button_nodes[map_category] = {}
		var item : TreeItem = n_base_asset_names.create_item(asset_names_root)
		item.set_text(0, map_category)

	var filename := path.get_file()
	if button_nodes[map_category].has(filename): return

	var icon_path = ("" if category.is_empty() else category + "/") + path.get_file().get_basename()
	var icon := ControllerIcons_Icon.new(map_category, icon_path)
	button_nodes[map_category][filename] = icon
	n_assets_container.add_child(icon.button)
	icon.button.pressed.connect(func():
		if _last_pressed_icon == icon:
			if Time.get_ticks_msec() < _last_pressed_timestamp:
				done.emit()
			else:
				_last_pressed_timestamp = Time.get_ticks_msec() + 1000
		else:
			_last_pressed_icon = icon
			_last_pressed_timestamp = Time.get_ticks_msec() + 1000
	)

func get_icon_path() -> String:
	var button := ControllerIcons_Icon.group.get_pressed_button()
	if button:
		return button.icon.path
	return ""

func grab_focus() -> void:
	n_name_filter.grab_focus()


func _on_base_asset_names_item_selected():
	var selected : TreeItem = n_base_asset_names.get_selected()
	if not selected: return

	var category := selected.get_text(0)
	if not button_nodes.has(category): return

	# UPGRADE: In Godot 4.2, for-loop variables can be
	# statically typed:
	# for key:String in button_nodes.keys():
	# 	for icon:ControllerIcon_Icon in button_nodes[key].values():
	for key in button_nodes.keys():
		for icon in button_nodes[key].values():
			icon.selected = key == category


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
	for key in button_nodes.keys():
		for icon in button_nodes[key].values():
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
