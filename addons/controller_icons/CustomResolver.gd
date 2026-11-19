extends RefCounted
class_name ControllerCustomResolver

const ControllerIcons = preload("res://addons/controller_icons/ControllerIcons.gd")

# Internals

func resolve_event(event: InputEvent, controller: int, forced_controller_icon_style: ControllerSettings.Devices) -> Texture:
	if event is InputEventKey:
		# If this is a physical key, convert to localized scancode
		if event.keycode == 0:
			return _resolve_key(DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode))
		return _resolve_key(event.keycode)
	elif event is InputEventMouseButton:
		return _resolve_mouse_button(event.button_index)
	elif event is InputEventJoypadButton:
		return _resolve_joypad_button(event.button_index, controller, forced_controller_icon_style)
	elif event is InputEventJoypadMotion:
		return _resolve_joypad_motion(event.axis, controller, forced_controller_icon_style)
	return null

# Virtual functions

# - Events
func _resolve_key(keycode: Key) -> Texture:
	return null

func _resolve_mouse_button(button_index: MouseButton) -> Texture:
	return null

func _resolve_joypad_button(joypad_button: JoyButton, controller: int, forced_controller_icon_style: ControllerSettings.Devices) -> Texture:
	return null

func _resolve_joypad_motion(joypad_axis: JoyAxis, controller: int, forced_controller_icon_style: ControllerSettings.Devices) -> Texture:
	return null

# - Joypad path

func _resolve_joypad_path(path: String, device: int, fallback: ControllerSettings.Devices, force_controller_icon_style = ControllerSettings.Devices.NONE) -> Texture:
	return null

# - Specific path

func _resolve_specific_path(path: String) -> Texture:
	return null
