extends MarginContainer

var mode_switch: CheckButton
var apply_button: Button
var revert_button: Button

var stylus_ids: Array

## TODO: Create separate scenes for each stylus found

func _ready() -> void:
	mode_switch = %ModeSwitch
	apply_button = %ApplyButton
	revert_button = %RevertButton

	stylus_ids = SystemSettings.get_stylus_device_ids()
	var stylus_mode: String = SystemSettings.get_unsaved_parameter(stylus_ids[0], Device.PARAMETERS.Mode)
	mode_switch.set_pressed_no_signal(stylus_mode == Device.MODES.Absolute)

func _on_mode_switch_toggled(toggled_on: bool) -> void:
	var value: String = Device.MODES.Absolute if toggled_on else Device.MODES.Relative
	SystemSettings.set_unsaved_parameter(stylus_ids[0], Device.PARAMETERS.Mode, value)
