@abstract class_name ControllerIconPack extends RefCounted

func _get_folder_name() -> String:
	# UPGRADE: In Godot 4.5, with abstract classes, this hack is no longer needed
	assert(false, "_get_folder_name must be implemented in the icon pack script!")
	return ""

func _get_root_asset_path() -> String:
	# UPGRADE: In Godot 4.5, with abstract classes, this hack is no longer needed
	assert(false, "_get_root_asset_path must be implemented in the icon pack script!")
	return ""

func _convert_key_to_path(scancode: int) -> String:
	# UPGRADE: In Godot 4.5, with abstract classes, this hack is no longer needed
	assert(false, "_convert_key_to_path must be implemented in the icon pack script!")
	return ""

func _convert_mouse_button_to_path(button_index: int) -> String:
	# UPGRADE: In Godot 4.5, with abstract classes, this hack is no longer needed
	assert(false, "_convert_mouse_button_to_path must be implemented in the icon pack script!")
	return ""

func _convert_joypad_path(path: String, device: ControllerIcons.Devices) -> String:
	# UPGRADE: In Godot 4.5, with abstract classes, this hack is no longer needed
	assert(false, "_convert_joypad_path must be implemented in the icon pack script!")
	return ""

func _convert_asset_path(asset: String) -> String:
	# UPGRADE: In Godot 4.5, with abstract classes, this hack is no longer needed
	assert(false, "_convert_asset_path must be implemented in the icon pack script!")
	return ""
