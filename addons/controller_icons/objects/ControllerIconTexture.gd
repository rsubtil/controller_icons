@tool
@icon("res://addons/controller_icons/objects/controller_texture_icon.svg")
extends Texture2D
class_name ControllerIconTexture
## [Texture2D] proxy for displaying controller icons
##
## A 2D texture representing a controller icon. The underlying system provides
## a [Texture2D] that may react to changes in the current input method, and also detect the user's controller type.
## Specify the [member path] property to setup the desired icon and behavior.[br]
## [br]
## For a more technical overview, this resource functions as a proxy for any
## node that accepts a [Texture2D], redefining draw commands to use an
## underlying plain [Texture2D], which may be swapped by the remapping system.[br]
## [br]
## This resource works out-of-the box with many default nodes, such as [Sprite2D],
## [Sprite3D], [TextureRect], [RichTextLabel], and others. If you are
## integrating this resource on a custom node, you will need to connect to the
## [signal Resource.changed] signal to properly handle changes to the underlying
## texture. You might also need to force a redraw with methods such as
## [method CanvasItem.queue_redraw].
##
## @tutorial(Online documentation): https://github.com/rsubtil/controller_icons/blob/master/DOCS.md

var _texture : Texture2D:
	set(__texture):
		if _texture and _texture.is_connected("changed", _reload_resource):
			_texture.disconnect("changed", _reload_resource)

		_texture = __texture
		if _texture:
			_texture.connect("changed", _reload_resource)

func _reload_resource():
	_dirty = true
	emit_changed()

func _load_texture_path():
	if ControllerIcons.is_node_ready() and _can_be_shown():
		if force_type > 0:
			_texture = ControllerIcons.parse_path(path, force_type - 1)
		else:
			_texture = ControllerIcons.parse_path(path)
	else:
		_texture = null
	_reload_resource()

## A path describing the desired icon. This is a generic path that can be one
## of three different types:
## [br][br]
## [b]- Input Action[/b]: Specify the exact name of an existing input action. The
## icon will be swapped automatically depending on whether the keyboard/mouse or the
## controller is being used. When using a controller, it also changes according to
## the controller type.[br][br]
## [i]This is the recommended approach, as it will handle all input methods
## automatically, and supports any input remapping done at runtime[/i].
## [codeblock]
## # "Enter" on keyboard, "Cross" on Sony,
## # "A" on Xbox, "B" on Nintendo
## path = "ui_accept"
## [/codeblock]
## [b]- Joypad Path[/b]: Specify a generic joypad path resembling the layout of a
## Xbox 360 controller, starting with the [code]joypad/[/code] prefix. The icon will only
## display controller icons, but it will still change according to the controller type.
## [codeblock]
## # "Square" on Sony, "X" on Xbox, "Y" on Nintendo
## path = "joypad/x"
## [/codeblock]
## [b]- Specific Path[/b]: Specify a direct asset path from the addon assets.
## With this path type, there is no dynamic remapping, and the icon will always
## remain the same. The path to use is the path to an icon file, minus the base
## path and extension.
## [codeblock]
## # res://addons/controller_icons/assets/steam/gyro.png
## path = "steam/gyro"
## [/codeblock]
@export var path : String = "":
	set(_path):
		path = _path
		_load_texture_path()

enum ShowMode {
	ANY, ## Icon will be display on any input method.
	KEYBOARD_MOUSE, ## Icon will be display only when the keyboard/mouse is being used.
	CONTROLLER ## Icon will be display only when a controller is being used.
}

## Show the icon only if a specific input method is being used. When hidden, 
## the icon will not occupy have any space (no width and height).
@export var show_mode : ShowMode = ShowMode.ANY:
	set(_show_mode):
		show_mode = _show_mode
		_load_texture_path()

enum ForceType {
	NONE, ## Icon will swap according to the used input method.
	KEYBOARD_MOUSE, ## Icon will always show the keyboard/mouse action.
	CONTROLLER, ## Icon will always show the controller action. 
}

## Forces the icon to show either the keyboard/mouse or controller icon,
## regardless of the currently used input method.
##[br][br]
## This is only relevant for paths using input actions, and has no effect on
## other scenarios.
@export var force_type : ForceType = ForceType.NONE:
	set(_force_type):
		force_type = _force_type
		_load_texture_path()

## Returns a text representation of the displayed icon, useful for TTS
## (text-to-speech) scenarios.
## [br][br]
## This takes into consideration the currently displayed icon, and will thus be
## different if the icon is from keyboard/mouse or controller. It also takes
## into consideration the controller type, and will thus use native button
## names (e.g. [code]A[/code] for Xbox, [code]Cross[/code] for PlayStation, etc).
func get_tts_string() -> String:
	if force_type:
		return ControllerIcons.parse_path_to_tts(path, force_type - 1)
	else:
		return ControllerIcons.parse_path_to_tts(path)

func _can_be_shown():
	match show_mode:
		1:
			return ControllerIcons._last_input_type == ControllerIcons.InputType.KEYBOARD_MOUSE
		2:
			return ControllerIcons._last_input_type == ControllerIcons.InputType.CONTROLLER
		0, _:
			return true

func _init():
	ControllerIcons.input_type_changed.connect(_on_input_type_changed)

func _on_input_type_changed(input_type: int):
	_load_texture_path()

#region "Draw functions"

func _get_width():
	if _texture and _can_be_shown():
		return _texture.get_width()
	return 2

func _get_height():
	if _texture and _can_be_shown():
		return _texture.get_height()
	return 2

func _has_alpha():
	return _texture.has_alpha() if _texture else false

func _is_pixel_opaque(x, y):
	# TODO: Not exposed to GDScript; however, since this seems to be used for editor stuff, it's
	# seemingly fine to just report all pixels as opaque. Otherwise, mouse picking for Sprite2D
	# stops working.
	return true

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool):
	if _texture:
		_texture.draw(to_canvas_item, pos, modulate, transpose)

func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool):
	if _texture:
		_texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)

func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool):
	if _texture:
		_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)

func _stitch_texture():
	# TODO: This lays the foundation for multi-icon prompts and simple text drawing.
	# For now, don't do anything special with it; just blit it, otherwise
	# Godot automatically reimports the texture as 3D, which may be undesired.

	if not _texture:
		return
	var texture_raw := _texture.get_image()
	texture_raw.decompress()
	var img := Image.create(_get_width(), _get_height(), true, texture_raw.get_format())

	var pos := Vector2i(0, 0)
	img.blit_rect(texture_raw, Rect2i(0, 0, texture_raw.get_width(), texture_raw.get_height()), pos)

	_texture_3d = ImageTexture.create_from_image(img)

# This is necessary for 3D sprites, as the texture is assigned to a material, and not drawn directly.
# For multi prompts, we need to generate a texture
var _dirty := true
var _texture_3d : Texture
func _get_rid():
	if _dirty:
		_stitch_texture()
		_dirty = false
	return _texture_3d.get_rid() if _texture else 0

#endregion
