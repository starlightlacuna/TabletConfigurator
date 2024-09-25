extends MarginContainer

var monitor_option_button: OptionButton
var monitor_indexes: Array

func _ready() -> void:
	monitor_option_button = %MonitorOptionButton
	var monitors: Dictionary = SystemSettings.monitors
	for monitor_id in monitors:
		monitor_option_button.add_item(monitor_id)
