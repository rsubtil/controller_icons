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
@export var path: String = "":
	set(_path):
		path = _path
		_load_texture_path()

## Modifiers to add to the displayed icon
## TODO: Document
@export var modifiers: String = "":
	set(_modifiers):
		modifiers = _modifiers
		_load_texture_path()


enum ShowMode {
	ANY, ## Icon will be display on any input method.
	KEYBOARD_MOUSE, ## Icon will be display only when the keyboard/mouse is being used.
	CONTROLLER ## Icon will be display only when a controller is being used.
}

## Show the icon only if a specific input method is being used. When hidden,
## the icon will not occupy have any space (no width and height).
@export var show_mode: ShowMode = ShowMode.ANY:
	set(_show_mode):
		show_mode = _show_mode
		_load_texture_path()

## TODO: Document
@export var icon_pack: String = "":
	set(_icon_pack):
		icon_pack = _icon_pack
		_load_texture_path()

@export_subgroup("Overrides")

## Forces the icon to show a specific controller style, regardless of the
## currently used controller type.
##[br][br]
## This will override force_device if set to a value other than NONE.
##[br][br]
## This is only relevant for paths using input actions, and has no effect on
## other scenarios.
@export var force_controller_icon_style: ControllerIcons.Devices = ControllerIcons.Devices.NONE:
	set(_force_controller_icon_style):
		force_controller_icon_style = _force_controller_icon_style
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
@export var force_type: ForceType = ForceType.NONE:
	set(_force_type):
		force_type = _force_type
		_load_texture_path()

enum ForceDevice {
	DEVICE_0,
	DEVICE_1,
	DEVICE_2,
	DEVICE_3,
	DEVICE_4,
	DEVICE_5,
	DEVICE_6,
	DEVICE_7,
	DEVICE_8,
	DEVICE_9,
	DEVICE_10,
	DEVICE_11,
	DEVICE_12,
	DEVICE_13,
	DEVICE_14,
	DEVICE_15,
	ANY # No device will be forced
}

## Forces the icon to use the textures for the device connected at the specified index.
## For example, if a PlayStation 5 controller is connected at device_index 0,
## the icon will always show PlayStation 5 textures.
@export var force_device: ForceDevice = ForceDevice.ANY:
	set(_force_device):
		force_device = _force_device
		_load_texture_path()

@export_subgroup("Text Rendering")
## Custom LabelSettings. If set, overrides the addon's global label settings.
@export var custom_label_settings: LabelSettings:
	set(_custom_label_settings):
		custom_label_settings = _custom_label_settings
		_load_texture_path()

		# Call _texture_data setter, which handles signal connections for label settings
		_texture_data = _texture_data


## Returns a text representation of the displayed icon, useful for TTS
## (text-to-speech) scenarios.
## [br][br]
## This takes into consideration the currently displayed icon, and will thus be
## different if the icon is from keyboard/mouse or controller. It also takes
## into consideration the controller type, and will thus use native button
## names (e.g. [code]A[/code] for Xbox, [code]Cross[/code] for PlayStation, etc).
func get_tts_string() -> String:
	if force_type:
		return ControllerIcons.parse_path_to_tts(path, icon_pack, force_type - 1)
	else:
		return ControllerIcons.parse_path_to_tts(path, icon_pack)

func _can_be_shown():
	match show_mode:
		1:
			return ControllerIcons._last_input_type == ControllerIcons.InputType.KEYBOARD_MOUSE
		2:
			return ControllerIcons._last_input_type == ControllerIcons.InputType.CONTROLLER
		0, _:
			return true

var _texture_data: ControllerIcons.TextureData:
	set(__texture_data):
		if _label_settings and _label_settings.is_connected("changed", _on_label_settings_changed):
			_label_settings.disconnect("changed", _on_label_settings_changed)

		_texture_data = __texture_data
		_label_settings = null
		if _texture_data:
			_label_settings = custom_label_settings
			if not _label_settings:
				var label_settings_res := ProjectSettings.get_setting_with_override(ControllerIcons.SETTING_CUSTOM_LABEL_SETTINGS)
				if ResourceLoader.exists(label_settings_res):
					_label_settings = load(ProjectSettings.get_setting_with_override(ControllerIcons.SETTING_CUSTOM_LABEL_SETTINGS))
			if not _label_settings:
				_label_settings = LabelSettings.new()
			_label_settings.connect("changed", _on_label_settings_changed)
			_font = ThemeDB.fallback_font if not _label_settings.font else _label_settings.font
			_on_label_settings_changed()

var _font: Font
var _label_settings: LabelSettings

func _on_label_settings_changed():
	_font = ThemeDB.fallback_font if not _label_settings.font else _label_settings.font
	_reload_resource()

func _reload_resource():
	_dirty = true
	emit_changed()

func _load_texture_path_impl():
	if ControllerIcons and ControllerIcons.is_node_ready() and _can_be_shown():
		var input_type = ControllerIcons.get_last_input_type() if force_type == ControllerIcons.InputType.AUTO else force_type
		var target_device = force_device if force_device != ForceDevice.ANY else ControllerIcons._last_controller
		_texture_data = ControllerIcons.parse_path(path, modifiers, icon_pack, input_type, target_device, force_controller_icon_style)
		_reload_resource()

func _load_texture_path():
	# Ensure loading only occurs on the main thread
	if OS.get_thread_caller_id() != OS.get_main_thread_id():
		# In Godot 4.3, call_deferred no longer makes this function
		# execute on the main thread due to changes in resource loading.
		# To ensure this, we instead rely on ControllerIcons for this
		ControllerIcons._defer_texture_load(_load_texture_path_impl)
	else:
		_load_texture_path_impl()

func _get_tokens() -> Array[ControllerIcons.TextureData.Token]:
	var modifier_string = "_1" if modifiers.is_empty() else modifiers
	return ControllerIcons.TextureData.tokenize_draw_string(modifier_string)

func _get_raw_tokens() -> Array[ControllerIcons.TextureData.Token]:
	if !_texture_data:
		return []
	return _texture_data.tokenize_draw_string(_texture_data.draw_string)

# TODO: Investigate. There might be a race condition in the engine, where
# sometimes this initializes before the ControllerIcons singleton is available.
# This hack seems to fix it, but it's ugly
var _hack_await_init := false
func _init():
	if not ControllerIcons and not _hack_await_init:
		_hack_await_init = true
		_init.call_deferred()
		return

	ControllerIcons.input_type_changed.connect(_on_input_type_changed)

func _on_input_type_changed(input_type: int, controller: int):
	_load_texture_path()

#region "Draw functions"
const _NULL_SIZE := 2

func _get_width() -> int:
	if _texture_data and _can_be_shown():
		var total = 0
		for token: ControllerIcons.TextureData.Token in _get_raw_tokens():
			if token is ControllerIcons.TextureData.IconToken:
				if _texture_data.textures.is_empty():
					return _NULL_SIZE
				var size := _texture_data.textures[token.index].get_width()
				if token.flair:
					size = max(size, _texture_data.textures[_texture_data.flairs[token.flair]].get_width())
				total += size
			elif token is ControllerIcons.TextureData.TextToken and _label_settings:
				total += _font.get_string_size(token.text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size).x
		# If total is 0, return a size of 2 to prevent triggering engine checks
		# for null sizes. The correct size will be set at a later frame.
		return total if total > 0 else _NULL_SIZE
	return _NULL_SIZE

func _get_height() -> int:
	if _texture_data and _can_be_shown():
		var max_value = 0
		for token: ControllerIcons.TextureData.Token in _get_raw_tokens():
			if token is ControllerIcons.TextureData.IconToken:
				if _texture_data.textures.is_empty():
					return _NULL_SIZE
				max_value = max(max_value, _texture_data.textures[token.index].get_height())
				if token.flair:
					max_value = max(max_value, _texture_data.textures[_texture_data.flairs[token.flair]].get_height())
			elif token is ControllerIcons.TextureData.TextToken and _label_settings:
				max_value = max(max_value, _font.get_string_size(token.text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size).y)
		# If total is 0, return a size of 2 to prevent triggering engine checks
		# for null sizes. The correct size will be set at a later frame.
		return max_value if max_value > 0 else _NULL_SIZE
	return _NULL_SIZE

func _has_alpha() -> bool:
	return _texture_data and _texture_data.textures.any(func(texture: Texture2D):
		return texture.has_alpha()
	)

func _is_pixel_opaque(x, y) -> bool:
	# TODO: Not exposed to GDScript; however, since this seems to be used for editor stuff, it's
	# seemingly fine to just report all pixels as opaque. Otherwise, mouse picking for Sprite2D
	# stops working.
	return true

func _draw_impl(rect: Rect2, draw_icon_func: Callable, draw_text_func: Callable):
	if not _texture_data: return

	var width_ratio := rect.size.x / _get_width()
	var height_ratio := rect.size.y / _get_height()

	var position := rect.position
	var size := rect.size

	for token: ControllerIcons.TextureData.Token in _get_raw_tokens():
		if token is ControllerIcons.TextureData.TextToken:
			var font_size := _font.get_string_size(token.text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size)
			var font_position := Vector2(
				position.x + (font_size.x * width_ratio) / 2 - (font_size.x / 2),
				position.y + (rect.size.y - font_size.y) / 2.0
			)
			await draw_text_func.call(token.text, font_position)
			position.x += font_size.x * width_ratio
		elif token is ControllerIcons.TextureData.IconToken:
			if _texture_data.textures.is_empty(): continue

			var draw_calls : Array[Callable]

			var tex := _texture_data.textures[token.index]
			var tex_size := tex.get_size() * Vector2(width_ratio, height_ratio)
			var tex_position := position
			# Icons are drawn always centered in the vertical axis
			tex_position.y += max(0, (size.y - tex_size.y) / 2.0)

			if token.flair:
				# Prepare already a draw call for flair drawing, because it might affect
				# the main texture's position
				var flair_tex := _texture_data.textures[_texture_data.flairs[token.flair]]
				var flair_size := flair_tex.get_size() * Vector2(width_ratio, height_ratio)
				var flair_position := position
				flair_position.y += max(0, (size.y - flair_size.y) / 2.0)
				draw_calls.push_back(draw_icon_func.bind(flair_tex, Rect2(flair_position, flair_size)) )

				tex_position.x += max(0, (flair_size.x - tex_size.x) / 2.0)

			draw_calls.push_front(draw_icon_func.bind(tex, Rect2(tex_position, tex_size)))
			
			var total_size := Vector2(0, 0)
			for draw_call in draw_calls:
				# Extract size from draw calls to compute largest dimensions
				total_size = total_size.max((draw_call.get_bound_arguments().back() as Rect2).size)
				await draw_call.call()

			position.x += total_size.x

func _draw_text(to_canvas_item: RID, text: String, font_position: Vector2):
	font_position.y += _font.get_ascent(_label_settings.font_size)
	
	if _label_settings.shadow_color.a > 0:
		_font.draw_string(to_canvas_item, font_position + _label_settings.shadow_offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size, _label_settings.shadow_color)
		if _label_settings.shadow_size > 0:
			_font.draw_string_outline(to_canvas_item, font_position + _label_settings.shadow_offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size, _label_settings.shadow_size, _label_settings.shadow_color)
	if _label_settings.outline_color.a > 0 and _label_settings.outline_size > 0:
			_font.draw_string_outline(to_canvas_item, font_position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size, _label_settings.outline_size, _label_settings.outline_color)
	_font.draw_string(to_canvas_item, font_position, text, HORIZONTAL_ALIGNMENT_CENTER, -1, _label_settings.font_size, _label_settings.font_color)

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool):
	var draw_icon_func := func(tex: Texture2D, rect: Rect2):
		tex.draw(to_canvas_item, rect.position, modulate, transpose)

	var draw_text_func := func(text: String, position: Vector2):
		_draw_text(to_canvas_item, text, position)

	_draw_impl(Rect2(pos, Vector2(_get_width(), _get_height())), draw_icon_func, draw_text_func)

func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool):
	var draw_icon_func := func(tex: Texture2D, rect: Rect2):
		tex.draw_rect(to_canvas_item, rect, tile, modulate, transpose)

	var draw_text_func := func(text: String, position: Vector2):
		_draw_text(to_canvas_item, text, position)

	_draw_impl(rect, draw_icon_func, draw_text_func)

func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool):
	var draw_icon_func := func(tex: Texture2D, new_rect: Rect2):
		var src_rect_ratio := Vector2(
			tex.get_width() / float(_get_width()),
			tex.get_height() / float(_get_height())
		)
		var tex_src_rect := Rect2(
			src_rect.position * src_rect_ratio,
			src_rect.size * src_rect_ratio
		)
		tex.draw_rect_region(to_canvas_item, new_rect, tex_src_rect, modulate, transpose, clip_uv)

	var draw_text_func := func(text: String, position: Vector2):
		_draw_text(to_canvas_item, text, position)

	_draw_impl(rect, draw_icon_func, draw_text_func)

var _helper_viewport: Viewport
var _is_stitching_texture: bool = false
func _stitch_texture():
	if not _texture_data:
		return

	_is_stitching_texture = true
	var img := Image.create(_get_width(), _get_height(), true, Image.FORMAT_RGBA8)

	var draw_icon_func := func(tex: Texture2D, rect: Rect2):
		var texture_raw := tex.get_image()
		texture_raw.decompress()

		img.blend_rect(texture_raw, Rect2i(0, 0, texture_raw.get_width(), texture_raw.get_height()), rect.position)

	var draw_text_func := func(text: String, position: Vector2):
		var text_size = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size)
		# Generate a viewport to draw the text
		if not _helper_viewport:
			_helper_viewport = SubViewport.new()
			# FIXME: We need a 3px margin for some reason
			_helper_viewport.size = text_size + Vector2(3, 0)
			_helper_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			_helper_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
			_helper_viewport.transparent_bg = true
			ControllerIcons.add_child(_helper_viewport)

		var label := Label.new()
		label.label_settings = _label_settings
		label.text = text
		label.position = Vector2.ZERO
		_helper_viewport.add_child(label)
		await RenderingServer.frame_post_draw
		label.queue_free()

		var font_image = _helper_viewport.get_texture().get_image()

		var region := font_image.get_used_rect()
		position.y += (text_size.y - region.size.y) / 2
		img.blend_rect(font_image, region, position)

	await _draw_impl(Rect2(Vector2.ZERO, Vector2(_get_width(), _get_height())), draw_icon_func, draw_text_func)

	if _helper_viewport:
		ControllerIcons.remove_child(_helper_viewport)
		_helper_viewport.free()
	_is_stitching_texture = false
	_dirty = false
	_texture_3d = ImageTexture.create_from_image(img)
	emit_changed()

# This is necessary for 3D sprites, as the texture is assigned to a material, and not drawn directly.
# For multi prompts, we need to generate a texture
var _dirty := true
var _texture_3d: Texture
func _get_rid() -> RID:
	if _dirty:
		if not _is_stitching_texture:
			# FIXME: Function may await, but because this is an internal engine call, we can't do anything about it.
			# This results in a one-frame white texture being displayed, which is not ideal. Investigate later.
			_stitch_texture()
			if _is_stitching_texture:
				return RID()
		else:
			return RID()
	return _texture_3d.get_rid() if _texture_data else RID()

#endregion
