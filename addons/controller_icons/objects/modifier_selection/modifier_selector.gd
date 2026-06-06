@tool
extends PanelContainer

enum AddItems {
	ICON,
	TEXT
}

signal flair_requested(token: ControllerIcons_ModifierButton)
signal text_requested(token: ControllerIcons_ModifierButton)

@onready var add_icon := get_theme_icon("Add", "EditorIcons")
@onready var icon_icon := get_theme_icon("Sprite2D", "EditorIcons")
@onready var text_icon := get_theme_icon("TextMesh", "EditorIcons")

@onready var n_modifier_icons: HBoxContainer = %ModifierIcons
@onready var n_add_modifier: MenuButton = %AddModifier

@onready var modifier_button := preload("res://addons/controller_icons/objects/modifier_selection/modifier_token.tscn")

var editor_interface : EditorInterface

var icon : ControllerIconTexture

func _ready() -> void:
	n_add_modifier.icon = add_icon.duplicate()
	
	# Force-resize the add icon
	assert(n_add_modifier.icon is DPITexture)
	(n_add_modifier.icon as DPITexture).base_scale = 2
	var add_menu := n_add_modifier.get_popup()
	add_menu.set_item_icon(AddItems.ICON, icon_icon)
	add_menu.set_item_icon(AddItems.TEXT, text_icon)
	add_menu.id_pressed.connect(_add_menu_item_selected)


func _add_menu_item_selected(id: AddItems) -> void:
	match id:
		AddItems.ICON:
			var token := ControllerIcons.TextureData.IconToken.new(0)
			_instantiate_modifier_token(token)
		AddItems.TEXT:
			var token := ControllerIcons.TextureData.TextToken.new("")
			text_requested.emit(_instantiate_modifier_token(token))

func _instantiate_modifier_token(token: ControllerIcons.TextureData.Token) -> ControllerIcons_ModifierButton:
	var modifier_token : ControllerIcons_ModifierButton = modifier_button.instantiate()
	n_modifier_icons.add_child(modifier_token)
	modifier_token.set_token(token, icon.path, icon.force_type)

	modifier_token.item_requested.connect(func(id: ControllerIcons_ModifierButton.MainItems):
		match id:
			ControllerIcons_ModifierButton.MainItems.MOVE_LEFT:
				_move_button(modifier_token, -1)
				_calculate_move_buttons()
			ControllerIcons_ModifierButton.MainItems.MOVE_RIGHT:
				_move_button(modifier_token, 1)
				_calculate_move_buttons()
			ControllerIcons_ModifierButton.MainItems.REMOVE:
				modifier_token.queue_free()
				_calculate_move_buttons()
	)
	modifier_token.flair_requested.connect(func():
		flair_requested.emit(modifier_token)
	)
	modifier_token.text_requested.connect(func():
		text_requested.emit(modifier_token)
	)

	return modifier_token

func populate(editor_interface: EditorInterface) -> void:
	self.editor_interface = editor_interface

func setup_tokens(_icon: ControllerIconTexture) -> void:
	for child in n_modifier_icons.get_children():
		child.queue_free()

	icon = _icon
	for token in icon._get_tokens():
		_instantiate_modifier_token(token)
	_calculate_move_buttons()

func _move_button(button: ControllerIcons_ModifierButton, delta: int) -> void:
	n_modifier_icons.move_child(button, button.get_index() + delta)

func _calculate_move_buttons() -> void:
	var children := n_modifier_icons.get_children().filter(func(node: Node):
		return not node.is_queued_for_deletion()
	)
	
	for i in range(children.size()):
		children[i].set_left_enabled(i > 0)
		children[i].set_right_enabled(i < children.size() - 1)

func get_modifiers() -> String:
	var modifiers = ""
	for token in n_modifier_icons.get_children():
		modifiers += token.get_modifier()
	
	return modifiers
