extends MarginContainer


var mode: SystemSettings.Mode
var styluses: Array
var mode_switch: CheckButton


## TODO: Create separate scenes for each stylus found

func _ready() -> void:
	styluses = SystemSettings.get_stylus_devices()
	mode_switch = %ModeSwitch
	mode_switch.set_pressed_no_signal(styluses[0][3] == SystemSettings.Mode.ABSOLUTE)

## TODO: Disable apply and revert buttons if there are no changes

func _on_mode_switch_toggled(toggled_on: bool) -> void:
	mode = SystemSettings.Mode.ABSOLUTE if toggled_on else SystemSettings.Mode.RELATIVE

func _on_apply_button_pressed() -> void:
	SystemSettings._set_mode("12", mode)
