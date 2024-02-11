extends EditorInspectorPlugin

var path_selector := preload("res://addons/controller_icons/objects/ControllerIconPathEditorProperty.gd")

var editor_interface : EditorInterface

class ControllerIcons_TexturePreview:
	var n_root: MarginContainer
	var n_background: TextureRect
	var n_texture: TextureRect
	
	var background: Texture2D

	var texture: Texture2D:
		set(_texture):
			texture = _texture
			n_texture.texture = texture
	
	func _init(editor_interface: EditorInterface):
		n_root = MarginContainer.new()

		# UPGRADE: In Godot 4.2, there's no need to have an instance to
		# EditorInterface, since it's now a static call:
		# background = EditorInterface.get_base_control().get_theme_icon("Checkerboard", "EditorIcons")
		background = editor_interface.get_base_control().get_theme_icon("Checkerboard", "EditorIcons")
		n_background = TextureRect.new()
		n_background.stretch_mode = TextureRect.STRETCH_TILE
		n_background.texture = background
		n_background.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		n_background.custom_minimum_size = Vector2(0, 256)
		n_root.add_child(n_background)
		
		n_texture = TextureRect.new()
		n_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		n_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
		n_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		n_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		n_root.add_child(n_texture)
	
	func get_root():
		return n_root

var preview: ControllerIcons_TexturePreview

func _can_handle(object: Object) -> bool:
	return object is ControllerIconTexture

func _parse_begin(object: Object) -> void:
	preview = ControllerIcons_TexturePreview.new(editor_interface)
	add_custom_control(preview.get_root())
	
	var icon := object as ControllerIconTexture
	if icon:
		preview.texture = icon

func _parse_property(object: Object, type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == "path":
		var path_selector_instance = path_selector.new(editor_interface)
		add_property_editor(name, path_selector_instance)
		return true
	return false
