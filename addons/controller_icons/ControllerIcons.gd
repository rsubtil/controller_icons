@tool
extends Node

signal input_type_changed(input_type: InputType, controller: int)

enum InputType {
	AUTO, ## The input type should be auto-deducted.
	KEYBOARD_MOUSE, ## The input is from the keyboard and/or mouse.
	CONTROLLER, ## The input is from a controller.
}

enum PathType {
	INPUT_ACTION, ## The path is an input action.
	JOYPAD_PATH, ## The path is a generic joypad path.
	SPECIFIC_PATH ## The path is a specific path.
}

enum Devices {
	NONE = -1,
	LUNA,
	OUYA,
	PS3,
	PS4,
	PS5,
	STADIA,
	STEAM,
	SWITCH,
	JOYCON,
	XBOX360,
	XBOXONE,
	XBOXSERIES,
	STEAM_DECK
}

class TextureData:
	# We cannot use char(0) because it spams GDScript errors...
	const NULL_CHAR = char(0xFFFD)
	var draw_string : String
	var textures : Array[Texture2D]
	var flairs : Dictionary[String, int]

	static func tokenize_draw_string(draw_string: String) -> Array[Token]:
		var tokens : Array[Token]

		var bounded_access = func(i: int) -> String:
			if i >= 0 and i < draw_string.length():
				return draw_string[i]
			return NULL_CHAR

		var accum_text : String
		var i := 0
		while i < draw_string.length():
			match bounded_access.call(i):
				"\\":
					# User might be escaping _ or {
					var next_char = bounded_access.call(i+1)
					if next_char == '_' or next_char == "{":
						# In that case, insert only that char
						accum_text += next_char
						i += 1
				"_":
					# Might be the start of an icon token; check if it starts
					# with a number
					if not bounded_access.call(i+1).is_valid_int():
						# Invalid token start; treat as text
						accum_text += '_'
						i += 1
						continue

					# Begin of an icon token; before we start, we must generate
					# a text token for any accumulated text so far
					if !accum_text.is_empty():
						tokens.push_back(TextToken.new(accum_text))
						accum_text = ""

					# Extract the number associated to this token
					var number_str : String
					while bounded_access.call(i+1).is_valid_int():
						number_str += bounded_access.call(i+1)
						i += 1

					# Generate icon token
					assert(number_str.is_valid_int())
					var icon_token := IconToken.new(number_str.to_int() - 1)
					tokens.push_back(icon_token)
					
					# Then, immediately test for an incoming flair
					if bounded_access.call(i+1) == "{":
						i += 1
						# Accumulate text and figure out whether it's a flair, or just text
						var accum_flair : String
						var next_char = bounded_access.call(i+1)
						while next_char != "}" and next_char != NULL_CHAR:
							accum_flair += next_char
							i += 1
							next_char = bounded_access.call(i+1)

						# Did we reach the end of the stream?
						if next_char == NULL_CHAR:
							# No closing token } found; treat this as text
							tokens.push_back(TextToken.new(accum_flair))
						else:
							# Found end token; treat this as flair
							i += 1
							icon_token.flair = accum_flair
				NULL_CHAR:
					# NUL char, skip
					pass
				var text:
					# Text; accumulate
					accum_text += text
			i += 1
		# Don't forget to generate a text token for the remaining text
		if not accum_text.is_empty():
			tokens.push_back(TextToken.new(accum_text))
		return tokens

	@abstract class Token:
		pass

	class IconToken extends Token:
		func _init(index: int) -> void:
			self.index = index

		var index : int
		var flair : String

	class TextToken extends Token:
		func _init(text: String) -> void:
			self.text = text

		var text : String

const SETTING_JOYPAD_FALLBACK = "controller_icons/general/joypad_fallback"
const SETTING_JOYPAD_DEADZONE = "controller_icons/general/joypad_deadzone"
const SETTING_ALLOW_MOUSE_REMAP = "controller_icons/general/allow_mouse_remap"
const SETTING_MOUSE_MIN_MOVEMENT = "controller_icons/general/mouse_minimum_movement"
const SETTING_CUSTOM_LABEL_SETTINGS = "controller_icons/text_rendering/custom_label_settings"

var DEFAULT_SETTINGS := {
	SETTING_JOYPAD_FALLBACK: Devices.XBOX360,
	SETTING_JOYPAD_DEADZONE: 0.5,
	SETTING_ALLOW_MOUSE_REMAP: true,
	SETTING_MOUSE_MIN_MOVEMENT: 200,
	SETTING_CUSTOM_LABEL_SETTINGS: "",
}

var _cached_icons : Dictionary[String, Texture] = {}
var _custom_input_actions : Dictionary[String, Array] = {}

var _cached_callables_lock := Mutex.new()
var _cached_callables : Array[Callable] = []

var _last_input_type : InputType
var _last_controller : int

# Custom mouse velocity calculation, because Godot
# doesn't implement it on some OSes apparently
const _MOUSE_VELOCITY_DELTA := 0.1
var _t : float
var _mouse_velocity : int

var _icon_packs : Dictionary[String, ControllerIconPack]

# Default actions will be the builtin editor actions when
# the script is at editor ("tool") level. To pickup more
# actions available, these have to be queried manually
var _builtin_keys := [
	"input/ui_accept", "input/ui_cancel", "input/ui_copy",
	"input/ui_cut", "input/ui_down", "input/ui_end",
	"input/ui_filedialog_refresh", "input/ui_filedialog_show_hidden",
	"input/ui_filedialog_up_one_level", "input/ui_focus_next",
	"input/ui_focus_prev", "input/ui_graph_delete",
	"input/ui_graph_duplicate", "input/ui_home",
	"input/ui_left", "input/ui_menu", "input/ui_page_down",
	"input/ui_page_up", "input/ui_paste", "input/ui_redo",
	"input/ui_right", "input/ui_select", "input/ui_swap_input_direction",
	"input/ui_text_add_selection_for_next_occurrence",
	"input/ui_text_backspace", "input/ui_text_backspace_all_to_left",
	"input/ui_text_backspace_all_to_left.macos",
	"input/ui_text_backspace_word", "input/ui_text_backspace_word.macos",
	"input/ui_text_caret_add_above", "input/ui_text_caret_add_above.macos",
	"input/ui_text_caret_add_below", "input/ui_text_caret_add_below.macos",
	"input/ui_text_caret_document_end", "input/ui_text_caret_document_end.macos",
	"input/ui_text_caret_document_start", "input/ui_text_caret_document_start.macos",
	"input/ui_text_caret_down", "input/ui_text_caret_left",
	"input/ui_text_caret_line_end", "input/ui_text_caret_line_end.macos",
	"input/ui_text_caret_line_start", "input/ui_text_caret_line_start.macos",
	"input/ui_text_caret_page_down", "input/ui_text_caret_page_up",
	"input/ui_text_caret_right", "input/ui_text_caret_up",
	"input/ui_text_caret_word_left", "input/ui_text_caret_word_left.macos",
	"input/ui_text_caret_word_right", "input/ui_text_caret_word_right.macos",
	"input/ui_text_clear_carets_and_selection", "input/ui_text_completion_accept",
	"input/ui_text_completion_query", "input/ui_text_completion_replace",
	"input/ui_text_dedent", "input/ui_text_delete",
	"input/ui_text_delete_all_to_right", "input/ui_text_delete_all_to_right.macos",
	"input/ui_text_delete_word", "input/ui_text_delete_word.macos",
	"input/ui_text_indent", "input/ui_text_newline", "input/ui_text_newline_above",
	"input/ui_text_newline_blank", "input/ui_text_scroll_down",
	"input/ui_text_scroll_down.macos", "input/ui_text_scroll_up",
	"input/ui_text_scroll_up.macos", "input/ui_text_select_all",
	"input/ui_text_select_word_under_caret", "input/ui_text_select_word_under_caret.macos",
	"input/ui_text_submit", "input/ui_text_toggle_insert_mode", "input/ui_undo",
	"input/ui_up",
]

func _set_last_input_type(__last_input_type, __last_controller):
	_last_input_type = __last_input_type
	_last_controller = __last_controller
	emit_signal("input_type_changed", _last_input_type, _last_controller)

func _enter_tree():
	process_mode = Node.PROCESS_MODE_ALWAYS
	for setting in DEFAULT_SETTINGS:
		if not ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, DEFAULT_SETTINGS[setting])
		_initialize_setting_info(setting)

	if Engine.is_editor_hint():
		_parse_input_actions()

func _initialize_setting_info(key: String) -> void:
	ProjectSettings.set_initial_value(key, DEFAULT_SETTINGS[key])
	match key:
		SETTING_JOYPAD_FALLBACK:
			# Needs enum information
			ProjectSettings.add_property_info({
				"name": key,
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Amazon Luna,OUYA,PlayStation 3,PlayStation 4,PlayStation 5,Google Stadia,Steam Controller,Nintendo Switch Pro Controller,Nintendo Switch Joy-Cons,Xbox 360,Xbox One,Xbox Series S/X,Steam Deck"
			})
		SETTING_JOYPAD_DEADZONE:
			# Needs range
			ProjectSettings.add_property_info({
				"name": key,
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.0,1.0"
			})
		SETTING_MOUSE_MIN_MOVEMENT:
			# Needs range
			ProjectSettings.add_property_info({
				"name": key,
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0,10000"
			})
		SETTING_CUSTOM_LABEL_SETTINGS:
			# Is a resource type
			ProjectSettings.add_property_info({
				"name": key,
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_FILE,
				"hint_string": "*.tres"
			})

func _exit_tree():
	_icon_packs.clear()

func _load_icon_pack(icon_pack: String = "") -> ControllerIconPack:
	var _first_if_exists := func() -> ControllerIconPack:
		return _icon_packs.values().front() if !_icon_packs.is_empty() else null

	if icon_pack in _icon_packs:
		return _icon_packs[icon_pack]

	var candidate_paths := DirAccess.get_directories_at("res://addons/controller_icons/icon_packs")
	if candidate_paths.is_empty():
		return null
	
	var candidate_pack = "res://addons/controller_icons/icon_packs/%s/Main.gd" % (candidate_paths[0] if icon_pack.is_empty() else icon_pack)
	if not FileAccess.file_exists(candidate_pack):
		push_error("Attempted to fetch from \"%s\" icon pack which doesn't exist! Using default pack..." % icon_pack)
		return _first_if_exists.call()
	
	var candidate_inst : ControllerIconPack = load(candidate_pack).new()
	if not candidate_inst:
		push_error("Loading \"%s\" icon pack failed! Using default pack..." % icon_pack)
		return _first_if_exists.call()
	
	_icon_packs[icon_pack] = candidate_inst
	return candidate_inst

func _parse_input_actions():
	_custom_input_actions.clear()

	for key in _builtin_keys:
		var data : Dictionary = ProjectSettings.get_setting(key)
		if not data.is_empty() and data.has("events") and data["events"] is Array:
			_add_custom_input_action((key as String).trim_prefix("input/"), data)

	# A script running at editor ("tool") level only has
	# the default mappings. The way to get around this is
	# manually parsing the project file and adding the
	# new input actions to lookup.
	var proj_file := ConfigFile.new()
	if proj_file.load("res://project.godot"):
		printerr("Failed to open \"project.godot\"! Custom input actions will not work on editor view!")
		return
	if proj_file.has_section("input"):
		for input_action in proj_file.get_section_keys("input"):
			var data : Dictionary = proj_file.get_value("input", input_action)
			_add_custom_input_action(input_action, data)

func _ready():
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	# Wait a frame to give a chance for the app to initialize
	await get_tree().process_frame
	# Set input type to what's likely being used currently
	if Input.get_connected_joypads().is_empty():
		_set_last_input_type(InputType.KEYBOARD_MOUSE, -1)
	else:
		_set_last_input_type(InputType.CONTROLLER, Input.get_connected_joypads().front())

func _on_joy_connection_changed(device, connected):
	if connected:
		_set_last_input_type(InputType.CONTROLLER, device)
	else:
		if Input.get_connected_joypads().is_empty():
			_set_last_input_type(InputType.KEYBOARD_MOUSE, -1)
		else:
			_set_last_input_type(InputType.CONTROLLER, Input.get_connected_joypads().front())

func _input(event: InputEvent):
	var input_type = _last_input_type
	var controller = _last_controller
	match event.get_class():
		"InputEventKey", "InputEventMouseButton":
			input_type = InputType.KEYBOARD_MOUSE
		"InputEventMouseMotion":
			if ProjectSettings.get_setting_with_override(SETTING_ALLOW_MOUSE_REMAP) and _test_mouse_velocity(event.relative):
				input_type = InputType.KEYBOARD_MOUSE
		"InputEventJoypadButton":
			input_type = InputType.CONTROLLER
			controller = event.device
		"InputEventJoypadMotion":
			if abs(event.axis_value) > ProjectSettings.get_setting_with_override(SETTING_JOYPAD_DEADZONE):
				input_type = InputType.CONTROLLER
				controller = event.device
	if input_type != _last_input_type or controller != _last_controller:
		_set_last_input_type(input_type, controller)

func _test_mouse_velocity(relative_vec: Vector2):
	if _t > _MOUSE_VELOCITY_DELTA:
		_t = 0
		_mouse_velocity = 0

	# We do a component sum instead of a length, to save on a
	# sqrt operation, and because length_squared is negatively
	# affected by low value vectors (<10).
	# It is also good enough for this system, so reliability
	# is sacrificed in favor of speed.
	_mouse_velocity += abs(relative_vec.x) + abs(relative_vec.y)
	return _mouse_velocity / _MOUSE_VELOCITY_DELTA > ProjectSettings.get_setting_with_override(SETTING_MOUSE_MIN_MOVEMENT)

func _process(delta: float) -> void:
	_t += delta

	if not _cached_callables.is_empty() and _cached_callables_lock.try_lock():
		# UPGRADE: In Godot 4.2, for-loop variables can be
		# statically typed:
		# for f: Callable in _cached_callables:
		for f in _cached_callables:
			if f.is_valid(): f.call()
		_cached_callables.clear()
		_cached_callables_lock.unlock()

func _add_custom_input_action(input_action: String, data: Dictionary):
	_custom_input_actions[input_action] = data["events"]

func refresh():
	# All it takes is to signal icons to refresh paths
	emit_signal("input_type_changed", _last_input_type, _last_controller)

func get_last_input_type() -> InputType:
	return _last_input_type

func parse_path(path: String, modifiers: String, icon_pack: String = "", input_type = _last_input_type, controller = _last_controller, forced_controller_icon_style = Devices.NONE) -> TextureData:
	var data := TextureData.new()
	if path.is_empty():
		return data

	if typeof(input_type) == TYPE_NIL:
		return data

	var icon_pack_inst := _load_icon_pack(icon_pack)
	if not icon_pack_inst:
		return data

	match get_path_type(path):
		PathType.INPUT_ACTION:
			return _compute_input_path(path, modifiers, icon_pack_inst, input_type, controller, forced_controller_icon_style)
		var type:
			if type == PathType.JOYPAD_PATH:
				path = _convert_joypad_path(path, icon_pack_inst, controller, forced_controller_icon_style)
			return _compute_other_path(path, modifiers, icon_pack_inst, input_type, controller, forced_controller_icon_style)

func parse_event_modifiers(event: InputEvent, icon_pack: ControllerIconPack = _load_icon_pack()) -> Array[Texture]:
	if not event or not event is InputEventWithModifiers:
		return []

	if not icon_pack:
		return []

	var icons : Array[Texture] = []
	var modifiers : Array[String] = []
	if event.command_or_control_autoremap:
		match OS.get_name():
			"macOS":
				modifiers.push_back("key/command")
			_:
				modifiers.push_back("key/ctrl")
	if event.ctrl_pressed and not event.command_or_control_autoremap:
		modifiers.push_back("key/ctrl")
	if event.shift_pressed:
		modifiers.push_back("key/shift")
	if event.alt_pressed:
		modifiers.push_back("key/alt")
	if event.meta_pressed and not event.command_or_control_autoremap:
		match OS.get_name():
			"macOS":
				modifiers.push_back("key/command")
			_:
				modifiers.push_back("key/win")

	for modifier in modifiers:
		if _load_icon(modifier, icon_pack) == OK:
			icons.push_back(_retrieve_cached_icon(modifier, icon_pack))

	return icons

func parse_path_to_tts(path: String, icon_pack: String, input_type: int = _last_input_type, controller: int = _last_controller) -> String:
	if input_type == null:
		return ""
	var icon_pack_inst := _load_icon_pack(icon_pack)
	if icon_pack_inst == null:
		return ""
	# TODO: Fix, return changed to array
	var tts = _convert_path_to_asset_files(path, input_type, controller, icon_pack_inst)
	return _convert_asset_file_to_tts(tts.get_basename().get_file())

func get_path_type(path: String) -> PathType:
	if _custom_input_actions.has(path) or InputMap.has_action(path):
		return PathType.INPUT_ACTION
	elif path.get_slice("/", 0) == "joypad":
		return PathType.JOYPAD_PATH
	else:
		return PathType.SPECIFIC_PATH

func get_joypad_type(device_idx: int):
	var available = Input.get_connected_joypads()
	if available.is_empty():
		return ProjectSettings.get_setting_with_override(SETTING_JOYPAD_FALLBACK)
	# If the requested joypad is not on the connected joypad list, try using the last known connected joypad
	if not device_idx in available:
		device_idx = ControllerIcons._last_controller
	# If that fails too, then use whatever joypad we have connected right now
	if not device_idx in available:
		device_idx = available.front()

	var controller_name = Input.get_joy_name(device_idx)
	if "Luna Controller" in controller_name:
		return Devices.LUNA
	elif "PS3 Controller" in controller_name:
		return Devices.PS3
	elif "PS4 Controller" in controller_name or \
		"DUALSHOCK 4" in controller_name:
		return Devices.PS4
	elif "PS5 Controller" in controller_name or \
		"DualSense" in controller_name:
		return Devices.PS5
	elif "Stadia Controller" in controller_name:
		return Devices.STADIA
	elif "Steam Controller" in controller_name:
		return Devices.STEAM
	elif "Switch Controller" in controller_name or \
		"Switch Pro Controller" in controller_name:
		return Devices.SWITCH
	elif "Joy-Con" in controller_name:
		return Devices.JOYCON
	elif "Xbox 360 Controller" in controller_name:
		return Devices.XBOX360
	elif "Xbox One" in controller_name or \
		"X-Box One" in controller_name or \
		"Xbox Wireless Controller" in controller_name:
		return Devices.XBOXONE
	elif "Xbox Series" in controller_name:
		return Devices.XBOXSERIES
	elif "Steam Deck" in controller_name or \
		"Steam Virtual Gamepad" in controller_name:
		return Devices.STEAM_DECK
	elif "OUYA Controller" in controller_name:
		return Devices.OUYA
	else:
		return ProjectSettings.get_setting_with_override(SETTING_JOYPAD_FALLBACK)

func pack_supports_flairs(icon_pack: String) -> bool:
	var icon_pack_inst := _load_icon_pack(icon_pack)
	if not icon_pack_inst:
		return false
	
	return icon_pack_inst._supports_flairs()

func _get_action_events(path: String) -> Array:
	# First check project specific actions
	if _custom_input_actions.has(path):
		return _custom_input_actions[path]
	# Then use Godot default actions
	return InputMap.action_get_events(path)

func get_matching_events(path: String, input_type: InputType = _last_input_type, controller: int = _last_controller) -> Array[InputEvent]:
	var events := _get_action_events(path)

	var filter_func = func(event: InputEvent):
		if not is_instance_valid(event): return false
		match event.get_class():
			"InputEventKey", "InputEventMouse", "InputEventMouseMotion", "InputEventMouseButton":
				return input_type == InputType.KEYBOARD_MOUSE
			"InputEventJoypadButton", "InputEventJoypadMotion":
				return input_type == InputType.CONTROLLER
			_:
				return false

	var results : Array[InputEvent]
	var fallbacks : Array[InputEvent]
	for event in events.filter(filter_func):
		match input_type:
			InputType.KEYBOARD_MOUSE:
				results.push_back(event)
			InputType.CONTROLLER:
				# Use the first device specific mapping if there is one.
				if event.device == controller:
					results.push_back(event)
				# Otherwise, we create a fallback prioritizing events with 'ALL_DEVICE' 
				if event.device < 0: # All-device event
					fallbacks.push_back(event)

	return results + fallbacks

func _compute_input_path(input_action: String, modifiers: String, icon_pack: ControllerIconPack, input_type: InputType, controller: int, forced_controller_icon_style: Devices) -> TextureData:
	var data := TextureData.new()

	var input_events := get_matching_events(input_action, input_type, controller)
	if input_events.is_empty():
		return data

	# Temporary cache between texture index and draw string; avoids duplicated
	# textures in texture data
	var cached_textures : Dictionary[int, String]
	var append_texture := func(idx: int):
		if idx in cached_textures:
			data.draw_string += cached_textures[idx]
			return
		
		var event = input_events[idx % input_events.size()]

		var textures : Array[Texture]
		textures.append_array(parse_event_modifiers(event, icon_pack))
		var key_path := _convert_event_to_path(event, icon_pack, controller, forced_controller_icon_style)
		if _load_icon(key_path, icon_pack) == OK:
			textures.push_back(_retrieve_cached_icon(key_path, icon_pack))

		var draw_string : String
		for i in textures.size():
			data.textures.push_back(textures[i])
			draw_string += ("" if i == 0 else "+") + "_%d" % data.textures.size()

		data.draw_string += draw_string
		cached_textures[idx] = draw_string

	# Temporary cache between flair and draw string; avoids duplicated
	# textures in texture data
	var cached_flairs : Dictionary[String, String]
	var append_flair := func(flair: String):
		if flair in cached_flairs:
			data.draw_string += cached_flairs[flair]
			return

		var flair_path = "flairs/%s" % flair
		if _load_icon(flair_path, icon_pack) == OK:
			data.textures.push_back(_retrieve_cached_icon(flair_path, icon_pack))
			data.flairs[flair] = data.textures.size()-1
			var draw_string = "{%s}" % flair
			data.draw_string += draw_string
			cached_flairs[flair] = draw_string

	var draw_string := modifiers if not modifiers.is_empty() else "_1"

	# Tokenize the draw string to understand which textures to fetch
	for token: TextureData.Token in TextureData.tokenize_draw_string(draw_string):
		if token is TextureData.IconToken:
			append_texture.call(token.index)
			if token.flair:
				append_flair.call(token.flair)
		elif token is TextureData.TextToken:
			data.draw_string += token.text

	return data

func _compute_other_path(path: String, modifiers: String, icon_pack: ControllerIconPack, input_type: InputType, controller: int, forced_controller_icon_style: Devices) -> TextureData:
	var data := TextureData.new()

	var cached_texture : Texture
	var append_texture := func():
		if cached_texture:
			data.draw_string += "_1"
			return

		if _load_icon(path, icon_pack) == OK:
			cached_texture = _retrieve_cached_icon(path, icon_pack)
			data.textures.push_back(cached_texture)

		data.draw_string += "_1"

	# Temporary cache between flair and draw string; avoids duplicated
	# textures in texture data
	var cached_flairs : Dictionary[String, String]
	var append_flair := func(flair: String):
		if flair in cached_flairs:
			data.draw_string += cached_flairs[flair]
			return

		var flair_path = "flairs/%s" % flair
		if _load_icon(flair_path, icon_pack) == OK:
			data.textures.push_back(_retrieve_cached_icon(flair_path, icon_pack))
			data.flairs[flair] = data.textures.size()-1
			var draw_string = "{%s}" % flair
			data.draw_string += draw_string
			cached_flairs[flair] = draw_string

	var draw_string := modifiers if not modifiers.is_empty() else "_1"

	# Tokenize the draw string to understand which textures to fetch
	for token: TextureData.Token in TextureData.tokenize_draw_string(draw_string):
		if token is TextureData.IconToken:
			append_texture.call()
			if token.flair:
				append_flair.call(token.flair)
		elif token is TextureData.TextToken:
			data.draw_string += token.text

	return data

func _convert_path_to_asset_files(path: String, input_type: int, controller: int, icon_pack: ControllerIconPack, forced_controller_icon_style = Devices.NONE) -> Array[String]:
	match get_path_type(path):
		PathType.INPUT_ACTION:
			var paths : Array[String]
			for event in get_matching_events(path, input_type, controller):
				paths.push_back(_convert_event_to_path(event, icon_pack, controller, forced_controller_icon_style))
			return paths
		PathType.JOYPAD_PATH:
			return [_convert_joypad_path(path, icon_pack, controller, forced_controller_icon_style)]
		PathType.SPECIFIC_PATH, _:
			return [path]

func _convert_asset_file_to_tts(path: String) -> String:
	match path:
		"shift_alt":
			return "shift"
		"esc":
			return "escape"
		"backspace_alt":
			return "backspace"
		"enter_alt":
			return "enter"
		"enter_tall":
			return "keypad enter"
		"arrow_left":
			return "left arrow"
		"arrow_right":
			return "right arrow"
		"del":
			return "delete"
		"arrow_up":
			return "up arrow"
		"arrow_down":
			return "down arrow"
		"shift_alt":
			return "shift"
		"ctrl":
			return "control"
		"kp_add":
			return "keypad plus"
		"mark_left":
			return "left mark"
		"mark_right":
			return "right mark"
		"bracket_left":
			return "left bracket"
		"bracket_right":
			return "right bracket"
		"tilda":
			return "tilde"
		"lb":
			return "left bumper"
		"rb":
			return "right bumper"
		"lt":
			return "left trigger"
		"rt":
			return "right trigger"
		"l_stick_click":
			return "left stick click"
		"r_stick_click":
			return "right stick click"
		"l_stick":
			return "left stick"
		"r_stick":
			return "right stick"
		_:
			return path

func _convert_event_to_path(event: InputEvent, icon_pack: ControllerIconPack, controller: int = _last_controller, forced_controller_icon_style = Devices.NONE) -> String:
	if event is InputEventKey:
		# If this is a physical key, convert to localized scancode
		if event.keycode == 0:
			return icon_pack._convert_key_to_path(DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode))
		return icon_pack._convert_key_to_path(event.keycode)
	elif event is InputEventMouseButton:
		return icon_pack._convert_mouse_button_to_path(event.button_index)
	elif event is InputEventJoypadButton:
		return _convert_joypad_button_to_path(event.button_index, controller, icon_pack, forced_controller_icon_style)
	elif event is InputEventJoypadMotion:
		return _convert_joypad_motion_to_path(event.axis, controller, icon_pack, forced_controller_icon_style)

	# Unsupported InputEvent
	return ""

func _convert_joypad_button_to_path(button_index: int, controller: int, icon_pack: ControllerIconPack, forced_controller_icon_style = Devices.NONE):
	var path
	match button_index:
		JOY_BUTTON_A:
			path = "joypad/a"
		JOY_BUTTON_B:
			path = "joypad/b"
		JOY_BUTTON_X:
			path = "joypad/x"
		JOY_BUTTON_Y:
			path = "joypad/y"
		JOY_BUTTON_LEFT_SHOULDER:
			path = "joypad/lb"
		JOY_BUTTON_RIGHT_SHOULDER:
			path = "joypad/rb"
		JOY_BUTTON_LEFT_STICK:
			path = "joypad/l_stick_click"
		JOY_BUTTON_RIGHT_STICK:
			path = "joypad/r_stick_click"
		JOY_BUTTON_BACK:
			path = "joypad/select"
		JOY_BUTTON_START:
			path = "joypad/start"
		JOY_BUTTON_DPAD_UP:
			path = "joypad/dpad_up"
		JOY_BUTTON_DPAD_DOWN:
			path = "joypad/dpad_down"
		JOY_BUTTON_DPAD_LEFT:
			path = "joypad/dpad_left"
		JOY_BUTTON_DPAD_RIGHT:
			path = "joypad/dpad_right"
		JOY_BUTTON_GUIDE:
			path = "joypad/home"
		JOY_BUTTON_MISC1:
			path = "joypad/share"
		_:
			return ""
	return _convert_joypad_path(path, icon_pack, controller, forced_controller_icon_style)

func _convert_joypad_motion_to_path(axis: int, controller: int, icon_pack: ControllerIconPack, forced_controller_icon_style = Devices.NONE):
	var path : String
	match axis:
		JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
			path = "joypad/l_stick"
		JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
			path = "joypad/r_stick"
		JOY_AXIS_TRIGGER_LEFT:
			path = "joypad/lt"
		JOY_AXIS_TRIGGER_RIGHT:
			path = "joypad/rt"
		_:
			return ""
	return _convert_joypad_path(path, icon_pack, controller, forced_controller_icon_style)

func _convert_joypad_path(path: String, icon_pack: ControllerIconPack, controller_idx: int, forced_controller_icon_style := Devices.NONE) -> String:
	var device = forced_controller_icon_style if forced_controller_icon_style != Devices.NONE else get_joypad_type(controller_idx)
	return icon_pack._convert_joypad_path(path, device)

func _load_icon(path: String, icon_pack: ControllerIconPack) -> int:
	var cache_key = "%s:%s" % [icon_pack._get_folder_name(), path]

	if _cached_icons.has(cache_key): return OK

	var full_path := icon_pack._convert_asset_path(path)
	var tex = null
	if full_path.begins_with("res://"):
		if ResourceLoader.exists(full_path):
			tex = load(full_path)
			if not tex:
				return ERR_FILE_CORRUPT
		else:
			return ERR_FILE_NOT_FOUND
	else:
		if not FileAccess.file_exists(full_path):
			return ERR_FILE_NOT_FOUND
		var img := Image.new()
		var err = img.load(full_path)
		if err != OK:
			return err
		tex = ImageTexture.new()
		tex.create_from_image(img)

	_cached_icons[cache_key] = tex
	return OK

func _retrieve_cached_icon(path: String, icon_pack: ControllerIconPack) -> Texture:
	var cache_key = "%s:%s" % [icon_pack._get_folder_name(), path]
	return _cached_icons[cache_key] if cache_key in _cached_icons else null

func _defer_texture_load(f: Callable) -> void:
	_cached_callables_lock.lock()
	_cached_callables.push_back(f)
	_cached_callables_lock.unlock()
