extends MarginContainer

var mode_switch: CheckButton
var apply_button: Button
var revert_button: Button

var mode: Device.Mode
var styluses: Array

## TODO: Create separate scenes for each stylus found

func _ready() -> void:
	mode_switch = %ModeSwitch
	apply_button = %ApplyButton
	revert_button = %RevertButton

	styluses = SystemSettings.get_stylus_devices()
	mode_switch.set_pressed_no_signal(styluses[0].get_mode() == Device.Mode.ABSOLUTE)
	
	_disable_buttons(true)

func _disable_buttons(disable: bool) -> void:
	apply_button.set_disabled(disable)
	revert_button.set_disabled(disable)
	if disable:
		apply_button.set_focus_mode(FocusMode.FOCUS_NONE)
		revert_button.set_focus_mode(FocusMode.FOCUS_NONE)
	else:
		apply_button.set_focus_mode(FocusMode.FOCUS_ALL)
		revert_button.set_focus_mode(FocusMode.FOCUS_ALL)

func _on_mode_switch_toggled(toggled_on: bool) -> void:
	mode = Device.Mode.ABSOLUTE if toggled_on else Device.Mode.RELATIVE
	_disable_buttons(false)

func _on_apply_button_pressed() -> void:
	SystemSettings._set_mode("12", mode)
	_disable_buttons(true)
