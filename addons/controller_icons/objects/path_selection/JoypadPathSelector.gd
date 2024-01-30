@tool
extends Panel

signal done

@onready var n_button_label := %ButtonLabel
@onready var button_nodes := [
	%LT, %RT,
	%LStick, %RStick,
	%LStickClick, %RStickClick,
	%LB, %RB, %A, %B, %X, %Y,
	%Select, %Start,
	%Home, %Share, %DPAD,
	%DPADDown, %DPADRight,
	%DPADLeft, %DPADUp
]

var _last_pressed_button : Button
var _last_pressed_timestamp : int

func populate(editor_interface: EditorInterface) -> void:
	# UPGRADE: In Godot 4.2, for-loop variables can be
	# statically typed:
	# for button:Button in button_nodes:
	for button in button_nodes:
		button.button_pressed = false

func get_icon_path() -> String:
	# UPGRADE: In Godot 4.2, for-loop variables can be
	# statically typed:
	# for button:Button in button_nodes:
	for button in button_nodes:
		if button.button_pressed:
			return button.icon.path
	return ""

func grab_focus() -> void:
	pass

func _input(event):
	if not visible: return
	
	if event is InputEventJoypadMotion:
		_input_motion(event)
	elif event is InputEventJoypadButton:
		_input_button(event)

func _input_motion(event: InputEventJoypadMotion):
	if abs(event.axis_value) < 0.5: return
	match event.axis:
		JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
			_simulate_button_press(%LStick)
		JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
			_simulate_button_press(%RStick)
		JOY_AXIS_TRIGGER_LEFT:
			_simulate_button_press(%LT)
		JOY_AXIS_TRIGGER_RIGHT:
			_simulate_button_press(%RT)

func _input_button(event: InputEventJoypadButton):
	if not event.pressed: return
	match event.button_index:
		JOY_BUTTON_A:
			_simulate_button_press(%A)
		JOY_BUTTON_B:
			_simulate_button_press(%B)
		JOY_BUTTON_X:
			_simulate_button_press(%X)
		JOY_BUTTON_Y:
			_simulate_button_press(%Y)
		JOY_BUTTON_LEFT_SHOULDER:
			_simulate_button_press(%LB)
		JOY_BUTTON_RIGHT_SHOULDER:
			_simulate_button_press(%RB)
		JOY_BUTTON_LEFT_STICK:
			_simulate_button_press(%LStickClick)
		JOY_BUTTON_RIGHT_STICK:
			_simulate_button_press(%RStickClick)
		JOY_BUTTON_DPAD_DOWN:
			_simulate_button_press(%DPADDown)
		JOY_BUTTON_DPAD_RIGHT:
			_simulate_button_press(%DPADRight)
		JOY_BUTTON_DPAD_LEFT:
			_simulate_button_press(%DPADLeft)
		JOY_BUTTON_DPAD_UP:
			_simulate_button_press(%DPADUp)
		JOY_BUTTON_BACK:
			_simulate_button_press(%Select)
		JOY_BUTTON_START:
			_simulate_button_press(%Start)
		JOY_BUTTON_GUIDE:
			_simulate_button_press(%Home)
		JOY_BUTTON_MISC1:
			_simulate_button_press(%Share)

func _simulate_button_press(button: Button):
	button.grab_focus()
	button.button_pressed = true
	button.set_meta("from_ui", false)
	button.pressed.emit()
	button.set_meta("from_ui", true)

func _on_button_pressed():
	# UPGRADE: In Godot 4.2, for-loop variables can be
	# statically typed:
	# for button:Button in button_nodes:
	for button in button_nodes:
		if button.has_meta("from_ui") and not button.get_meta("from_ui", true): return
		if button.button_pressed:
			if _last_pressed_button == button:
				if Time.get_ticks_msec() < _last_pressed_timestamp:
					done.emit()
				else:
					_last_pressed_timestamp = Time.get_ticks_msec() + 1000
			else:
				_last_pressed_button = button
				_last_pressed_timestamp = Time.get_ticks_msec() + 1000

func _on_l_stick_pressed():
	n_button_label.text = "Axis 0/1\n(Left Stick, Joystick 0)\n[joypad/l_stick]"


func _on_l_stick_click_pressed():
	n_button_label.text = "Button 7\n(Left Stick, Sony L3, Xbox L/LS)\n[joypad/l_stick_click]"


func _on_r_stick_pressed():
	n_button_label.text = "Axis 2/3\n(Right Stick, Joystick 1)\n[joypad/r_stick]"


func _on_r_stick_click_pressed():
	n_button_label.text = "Button 8\n(Right Stick, Sony R3, Xbox R/RS)\n[joypad/r_stick_click]"


func _on_lb_pressed():
	n_button_label.text = "Button 9\n(Left Shoulder, Sony L1, Xbox LB)\n[joypad/lb]"


func _on_lt_pressed():
	n_button_label.text = "Axis 4\n(Left Trigger, Sony L2, Xbox LT, Joystick 2 Right)\n[joypad/lt]"


func _on_rb_pressed():
	n_button_label.text = "Button 10\n(Right Shoulder, Sony R1, Xbox RB)\n[joypad/rb]"


func _on_rt_pressed():
	n_button_label.text = "Axis 5\n(Right Trigger, Sony R2, Xbox RT, Joystick 2 Down)\n[joypad/rt]"


func _on_a_pressed():
	n_button_label.text = "Button 0\n(Bottom Action, Sony Cross, Xbox A, Nintendo B)\n[joypad/a]"


func _on_b_pressed():
	n_button_label.text = "Button 1\n(Right Action, Sony Circle, Xbox B, Nintendo A)\n[joypad/b]"


func _on_x_pressed():
	n_button_label.text = "Button 2\n(Left Action, Sony Square, Xbox X, Nintendo Y)\n[joypad/x]"


func _on_y_pressed():
	n_button_label.text = "Button 3\n(Top Action, Sony Triangle, Xbox Y, Nintendo X)\n[joypad/y]"


func _on_select_pressed():
	n_button_label.text = "Button 4\n(Back, Sony Select, Xbox Back, Nintendo -)\n[joypad/select]"


func _on_start_pressed():
	n_button_label.text = "Button 6\n(Start, Xbox Menu, Nintendo +)\n[joypad/start]"


func _on_home_pressed():
	n_button_label.text = "Button 5\n(Guide, Sony PS, Xbox Home)\n[joypad/home]"


func _on_share_pressed():
	n_button_label.text = "Button 15\n(Xbox Share, PS5 Microphone, Nintendo Capture)\n[joypad/share]"


func _on_dpad_pressed():
	n_button_label.text = "Button 11/12/13/14\n(D-pad)\n[joypad/dpad]"


func _on_dpad_down_pressed():
	n_button_label.text = "Button 12\n(D-pad Down)\n[joypad/dpad_down]"


func _on_dpad_right_pressed():
	n_button_label.text = "Button 14\n(D-pad Right)\n[joypad/dpad_right]"


func _on_dpad_left_pressed():
	n_button_label.text = "Button 13\n(D-pad Left)\n[joypad/dpad_left]"


func _on_dpad_up_pressed():
	n_button_label.text = "Button 11\n(D-pad Up)\n[joypad/dpad_up]"
