class_name State
extends Resource

var devices: Dictionary = {}
var monitors: Dictionary = {}

func get_devices() -> Dictionary:
	return devices

func set_devices(p_devices: Dictionary) -> void:
	devices = p_devices

func get_monitors() -> Dictionary:
	return monitors

func set_monitors(p_monitors: Dictionary) -> void:
	monitors = p_monitors
