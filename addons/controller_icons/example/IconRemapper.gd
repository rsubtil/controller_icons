extends Control

var base_names := []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in $Controls.get_children():
		base_names.push_back(child.get_child(0).path)


func _on_Auto_pressed():
	for i in range($Controls.get_child_count()):
		$Controls.get_child(i).get_child(0).path = base_names[i]


func _on_Luna_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_luna(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_OUYA_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_ouya(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_PS3_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_ps3(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_PS4_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_ps4(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_PS5_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_ps5(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_Stadia_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_stadia(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_Steam_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_steam(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_Switch_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_switch(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_Joycon_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_joycon(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_Vita_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_vita(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_Wii_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_wii(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_WiiU_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_wiiu(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_Xbox360_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_xbox360(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_XboxOne_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_xboxone(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text


func _on_XboxSeries_pressed():
	for i in range($Controls.get_child_count()):
		var control_text = ControllerIcons.Mapper._convert_joypad_to_xboxseries(base_names[i])
		$Controls.get_child(i).get_child(0).path = control_text
