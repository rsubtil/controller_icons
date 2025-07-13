extends ControllerIconPack

func _get_folder_name() -> String:
	return "xelu"

func _get_root_asset_path() -> String:
	return "res://addons/controller_icons/icon_packs/xelu/assets"

func _convert_key_to_path(scancode: int) -> String:
	match scancode:
		KEY_ESCAPE:
			return "key/esc"
		KEY_TAB:
			return "key/tab"
		KEY_BACKSPACE:
			return "key/backspace_alt"
		KEY_ENTER:
			return "key/enter_alt"
		KEY_KP_ENTER:
			return "key/enter_tall"
		KEY_INSERT:
			return "key/insert"
		KEY_DELETE:
			return "key/del"
		KEY_PRINT:
			return "key/print_screen"
		KEY_HOME:
			return "key/home"
		KEY_END:
			return "key/end"
		KEY_LEFT:
			return "key/arrow_left"
		KEY_UP:
			return "key/arrow_up"
		KEY_RIGHT:
			return "key/arrow_right"
		KEY_DOWN:
			return "key/arrow_down"
		KEY_PAGEUP:
			return "key/page_up"
		KEY_PAGEDOWN:
			return "key/page_down"
		KEY_SHIFT:
			return "key/shift_alt"
		KEY_CTRL:
			return "key/ctrl"
		KEY_META:
			match OS.get_name():
				"macOS":
					return "key/command"
				_:
					return "key/meta"
		KEY_ALT:
			return "key/alt"
		KEY_CAPSLOCK:
			return "key/caps_lock"
		KEY_NUMLOCK:
			return "key/num_lock"
		KEY_F1:
			return "key/f1"
		KEY_F2:
			return "key/f2"
		KEY_F3:
			return "key/f3"
		KEY_F4:
			return "key/f4"
		KEY_F5:
			return "key/f5"
		KEY_F6:
			return "key/f6"
		KEY_F7:
			return "key/f7"
		KEY_F8:
			return "key/f8"
		KEY_F9:
			return "key/f9"
		KEY_F10:
			return "key/f10"
		KEY_F11:
			return "key/f11"
		KEY_F12:
			return "key/f12"
		KEY_KP_MULTIPLY, KEY_ASTERISK:
			return "key/asterisk"
		KEY_KP_SUBTRACT, KEY_MINUS:
			return "key/minus"
		KEY_KP_ADD:
			return "key/plus_tall"
		KEY_KP_0:
			return "key/0"
		KEY_KP_1:
			return "key/1"
		KEY_KP_2:
			return "key/2"
		KEY_KP_3:
			return "key/3"
		KEY_KP_4:
			return "key/4"
		KEY_KP_5:
			return "key/5"
		KEY_KP_6:
			return "key/6"
		KEY_KP_7:
			return "key/7"
		KEY_KP_8:
			return "key/8"
		KEY_KP_9:
			return "key/9"
		KEY_UNKNOWN:
			return ""
		KEY_SPACE:
			return "key/space"
		KEY_QUOTEDBL:
			return "key/quote"
		KEY_PLUS:
			return "key/plus"
		KEY_0:
			return "key/0"
		KEY_1:
			return "key/1"
		KEY_2:
			return "key/2"
		KEY_3:
			return "key/3"
		KEY_4:
			return "key/4"
		KEY_5:
			return "key/5"
		KEY_6:
			return "key/6"
		KEY_7:
			return "key/7"
		KEY_8:
			return "key/8"
		KEY_9:
			return "key/9"
		KEY_SEMICOLON:
			return "key/semicolon"
		KEY_LESS:
			return "key/mark_left"
		KEY_GREATER:
			return "key/mark_right"
		KEY_QUESTION:
			return "key/question"
		KEY_A:
			return "key/a"
		KEY_B:
			return "key/b"
		KEY_C:
			return "key/c"
		KEY_D:
			return "key/d"
		KEY_E:
			return "key/e"
		KEY_F:
			return "key/f"
		KEY_G:
			return "key/g"
		KEY_H:
			return "key/h"
		KEY_I:
			return "key/i"
		KEY_J:
			return "key/j"
		KEY_K:
			return "key/k"
		KEY_L:
			return "key/l"
		KEY_M:
			return "key/m"
		KEY_N:
			return "key/n"
		KEY_O:
			return "key/o"
		KEY_P:
			return "key/p"
		KEY_Q:
			return "key/q"
		KEY_R:
			return "key/r"
		KEY_S:
			return "key/s"
		KEY_T:
			return "key/t"
		KEY_U:
			return "key/u"
		KEY_V:
			return "key/v"
		KEY_W:
			return "key/w"
		KEY_X:
			return "key/x"
		KEY_Y:
			return "key/y"
		KEY_Z:
			return "key/z"
		KEY_BRACKETLEFT:
			return "key/bracket_left"
		KEY_BACKSLASH:
			return "key/slash"
		KEY_SLASH:
			return "key/forward_slash"
		KEY_BRACKETRIGHT:
			return "key/bracket_right"
		KEY_ASCIITILDE:
			return "key/tilda"
		KEY_QUOTELEFT:
			return "key/backtick"
		KEY_APOSTROPHE:
			return "key/apostrophe"
		KEY_COMMA:
			return "key/comma"
		KEY_EQUAL:
			return "key/equals"
		KEY_PERIOD, KEY_KP_PERIOD:
			return "key/period"
		_:
			return ""

func _convert_mouse_button_to_path(button_index: int) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT:
			return "mouse/left"
		MOUSE_BUTTON_RIGHT:
			return "mouse/right"
		MOUSE_BUTTON_MIDDLE:
			return "mouse/middle"
		MOUSE_BUTTON_WHEEL_UP:
			return "mouse/wheel_up"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "mouse/wheel_down"
		MOUSE_BUTTON_XBUTTON1:
			return "mouse/side_down"
		MOUSE_BUTTON_XBUTTON2:
			return "mouse/side_up"
		_:
			return "mouse/sample"

func _convert_joypad_path(path: String, device: ControllerIcons.Devices) -> String:
	match device:
		ControllerIcons.Devices.LUNA:
			return _convert_joypad_to_luna(path)
		ControllerIcons.Devices.PS3:
			return _convert_joypad_to_ps3(path)
		ControllerIcons.Devices.PS4:
			return _convert_joypad_to_ps4(path)
		ControllerIcons.Devices.PS5:
			return _convert_joypad_to_ps5(path)
		ControllerIcons.Devices.STADIA:
			return _convert_joypad_to_stadia(path)
		ControllerIcons.Devices.STEAM:
			return _convert_joypad_to_steam(path)
		ControllerIcons.Devices.SWITCH:
			return _convert_joypad_to_switch(path)
		ControllerIcons.Devices.JOYCON:
			return _convert_joypad_to_joycon(path)
		ControllerIcons.Devices.XBOX360:
			return _convert_joypad_to_xbox360(path)
		ControllerIcons.Devices.XBOXONE:
			return _convert_joypad_to_xboxone(path)
		ControllerIcons.Devices.XBOXSERIES:
			return _convert_joypad_to_xboxseries(path)
		ControllerIcons.Devices.STEAM_DECK:
			return _convert_joypad_to_steamdeck(path)
		ControllerIcons.Devices.OUYA:
			return _convert_joypad_to_ouya(path)
		_:
			return ""

func _convert_joypad_to_luna(path: String):
	path = path.replace("joypad", "luna")
	match path.substr(path.find("/") + 1):
		"select":
			return path.replace("/select", "/circle")
		"start":
			return path.replace("/start", "/menu")
		"share":
			return path.replace("/share", "/microphone")
		_:
			return path

func _convert_joypad_to_playstation(path: String):
	match path.substr(path.find("/") + 1):
		"a":
			return path.replace("/a", "/cross")
		"b":
			return path.replace("/b", "/circle")
		"x":
			return path.replace("/x", "/square")
		"y":
			return path.replace("/y", "/triangle")
		"lb":
			return path.replace("/lb", "/l1")
		"rb":
			return path.replace("/rb", "/r1")
		"lt":
			return path.replace("/lt", "/l2")
		"rt":
			return path.replace("/rt", "/r2")
		_:
			return path

func _convert_joypad_to_ps3(path: String):
	return _convert_joypad_to_playstation(path.replace("joypad", "ps3"))

func _convert_joypad_to_ps4(path: String):
	path = _convert_joypad_to_playstation(path.replace("joypad", "ps4"))
	match path.substr(path.find("/") + 1):
		"select":
			return path.replace("/select", "/share")
		"start":
			return path.replace("/start", "/options")
		"share":
			return path.replace("/share", "/")
		_:
			return path

func _convert_joypad_to_ps5(path: String):
	path = _convert_joypad_to_playstation(path.replace("joypad", "ps5"))
	match path.substr(path.find("/") + 1):
		"select":
			return path.replace("/select", "/share")
		"start":
			return path.replace("/start", "/options")
		"home":
			return path.replace("/home", "/assistant")
		"share":
			return path.replace("/share", "/microphone")
		_:
			return path

func _convert_joypad_to_stadia(path: String):
	path = path.replace("joypad", "stadia")
	match path.substr(path.find("/") + 1):
		"lb":
			return path.replace("/lb", "/l1")
		"rb":
			return path.replace("/rb", "/r1")
		"lt":
			return path.replace("/lt", "/l2")
		"rt":
			return path.replace("/rt", "/r2")
		"select":
			return path.replace("/select", "/dots")
		"start":
			return path.replace("/start", "/menu")
		"share":
			return path.replace("/share", "/select")
		_:
			return path

func _convert_joypad_to_steam(path: String):
	path = path.replace("joypad", "steam")
	match path.substr(path.find("/") + 1):
		"r_stick_click":
			return path.replace("/r_stick_click", "/right_track_center")
		"select":
			return path.replace("/select", "/back")
		"home":
			return path.replace("/home", "/system")
		"dpad":
			return path.replace("/dpad", "/left_track")
		"dpad_up":
			return path.replace("/dpad_up", "/left_track_up")
		"dpad_down":
			return path.replace("/dpad_down", "/left_track_down")
		"dpad_left":
			return path.replace("/dpad_left", "/left_track_left")
		"dpad_right":
			return path.replace("/dpad_right", "/left_track_right")
		"l_stick":
			return path.replace("/l_stick", "/stick")
		"r_stick":
			return path.replace("/r_stick", "/right_track")
		_:
			return path

func _convert_joypad_to_switch(path: String):
	path = path.replace("joypad", "switch")
	match path.substr(path.find("/") + 1):
		"a":
			return path.replace("/a", "/b")
		"b":
			return path.replace("/b", "/a")
		"x":
			return path.replace("/x", "/y")
		"y":
			return path.replace("/y", "/x")
		"lb":
			return path.replace("/lb", "/l")
		"rb":
			return path.replace("/rb", "/r")
		"lt":
			return path.replace("/lt", "/zl")
		"rt":
			return path.replace("/rt", "/zr")
		"select":
			return path.replace("/select", "/minus")
		"start":
			return path.replace("/start", "/plus")
		"share":
			return path.replace("/share", "/square")
		_:
			return path

func _convert_joypad_to_joycon(path: String):
	path = _convert_joypad_to_switch(path)
	match path.substr(path.find("/") + 1):
		"dpad_up":
			return path.replace("/dpad_up", "/up")
		"dpad_down":
			return path.replace("/dpad_down", "/down")
		"dpad_left":
			return path.replace("/dpad_left", "/left")
		"dpad_right":
			return path.replace("/dpad_right", "/right")
		_:
			return path

func _convert_joypad_to_xbox360(path: String):
	path = path.replace("joypad", "xbox360")
	match path.substr(path.find("/") + 1):
		"select":
			return path.replace("/select", "/back")
		_:
			return path

func _convert_joypad_to_xbox_modern(path: String):
	match path.substr(path.find("/") + 1):
		"select":
			return path.replace("/select", "/view")
		"start":
			return path.replace("/start", "/menu")
		_:
			return path

func _convert_joypad_to_xboxone(path: String):
	return _convert_joypad_to_xbox_modern(path.replace("joypad", "xboxone"))

func _convert_joypad_to_xboxseries(path: String):
	return _convert_joypad_to_xbox_modern(path.replace("joypad", "xboxseries"))

func _convert_joypad_to_steamdeck(path: String):
	path = path.replace("joypad", "steamdeck")
	match path.substr(path.find("/") + 1):
		"lb":
			return path.replace("/lb", "/l1")
		"rb":
			return path.replace("/rb", "/r1")
		"lt":
			return path.replace("/lt", "/l2")
		"rt":
			return path.replace("/rt", "/r2")
		"select":
			return path.replace("/select", "/inventory")
		"start":
			return path.replace("/start", "/menu")
		"home":
			return path.replace("/home", "/steam")
		"share":
			return path.replace("/share", "/dots")
		_:
			return path

func _convert_joypad_to_ouya(path: String):
	path = path.replace("joypad", "ouya")
	match path.substr(path.find("/") + 1):
		"a":
			return path.replace("/a", "/o")
		"x":
			return path.replace("/x", "/u")
		"b":
			return path.replace("/b", "/a")
		"lb":
			return path.replace("/lb", "/l1")
		"rb":
			return path.replace("/rb", "/r1")
		"lt":
			return path.replace("/lt", "/l2")
		"rt":
			return path.replace("/rt", "/r2")
		"start":
			return path.replace("/start", "/menu")
		"share":
			return path.replace("/share", "/microphone")
		_:
			return path

func _convert_asset_path(asset: String) -> String:
	return "%s/%s.png" % [_get_root_asset_path(), asset]
