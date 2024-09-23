extends MarginContainer

var mode_switch: CheckButton

func _ready() -> void:
	mode_switch = %ModeSwitch
	
	
	mode_switch.set_pressed(SystemSettings._get_mode("11") == SystemSettings.Mode.ABSOLUTE)
