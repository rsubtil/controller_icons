@tool
extends ScrollContainer
class_name ControllerIcons_IconContainer

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

signal icon_selected(icon: ControllerIcons_Icon)

@onready var n_container := %Container

var button_nodes : Dictionary

var _last_pressed_icon : ControllerIcons_Icon
var _last_pressed_timestamp : int

func clear() -> void:
	button_nodes.clear()
	for child in n_container.get_children():
		child.queue_free()

func is_empty() -> bool:
	return button_nodes.is_empty()

func add_icon(category: String, path: String) -> void:
	var icon := ControllerIcons_Icon.new(category, path)
	button_nodes[category][path.get_file()] = icon
	n_container.add_child(icon.button)
	icon.button.pressed.connect(func():
		if _last_pressed_icon == icon:
			if Time.get_ticks_msec() < _last_pressed_timestamp:
				icon_selected.emit(_last_pressed_icon)
			else:
				_last_pressed_timestamp = Time.get_ticks_msec() + 1000
		else:
			_last_pressed_icon = icon
			_last_pressed_timestamp = Time.get_ticks_msec() + 1000
	)

func add_meta_icon(category: String, content: String) -> void:
	var icon := ControllerIcons_Icon.new(category, "/" + content)
	button_nodes[category][content] = icon
	n_container.add_child(icon.button)
	icon.button.pressed.connect(func():
		if _last_pressed_icon == icon:
			if Time.get_ticks_msec() < _last_pressed_timestamp:
				icon_selected.emit(_last_pressed_icon)
			else:
				_last_pressed_timestamp = Time.get_ticks_msec() + 1000
		else:
			_last_pressed_icon = icon
			_last_pressed_timestamp = Time.get_ticks_msec() + 1000
	)

func select_category(category: String) -> void:
	if not button_nodes.has(category): return

	# UPGRADE: In Godot 4.2, for-loop variables can be
	# statically typed:
	# for key:String in button_nodes.keys():
	# 	for icon:ControllerIcon_Icon in button_nodes[key].values():
	for key in button_nodes.keys():
		for icon in button_nodes[key].values():
			icon.selected = key == category

func get_selected_icon() -> Button:
	return ControllerIcons_Icon.group.get_pressed_button()
