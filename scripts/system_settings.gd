extends Node


const XSETWACOM: String = "xsetwacom"

var current_mode: Device.Mode

## String array containing info about Wacom devices
## 0: Name
## 1: ID
## 2: type
## 3: Mode
var devices: Array

func _ready() -> void:
	devices = _get_devices()
	print(devices)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_devices() -> Array:
	var output: Array
	OS.execute(XSETWACOM, ["list", "devices"], output, true)
	if output.size() > 1:
		printerr(output[1])
		return []
	var devices: Array = (output[0] as String).split("\n")
	devices.remove_at(devices.size() - 1)
	var device_info: Array = []
	for device in devices:
		var info: Array = device.split("\t")
		for index in info.size():
			info[index] = (info[index] as String).rstrip(" ")
		var new_device: Device = Device.new()
		new_device.name = info[0]
		new_device.id = (info[1] as String).substr(4)
		new_device.set_type((info[2] as String).substr(6))
		new_device.set_mode(_get_mode(new_device.id))
		device_info.push_back(new_device)
	return device_info

func _get_mode(device_id: String) -> String:
	var output: Array
	OS.execute(XSETWACOM, ["get", device_id, "Mode"], output)
	if output.size() > 1:
		printerr(output[1])
		return ""
	return output[0].rstrip("\n")

func _set_mode(device_id: String, mode: Device.Mode) -> void:
	var mode_string: String = "Absolute" if mode == Device.Mode.ABSOLUTE else "Relative"
	var output: Array
	OS.execute(XSETWACOM, ["set", device_id, "Mode", mode_string], output)
	if output.size() > 1:
		printerr(output[1])
		return
	print(output)

func get_stylus_devices() -> Array:
	var stylus_devices: Array = []
	for device in devices:
		if device.get_type() == Device.Type.STYLUS:
			stylus_devices.push_back(device)
	return stylus_devices
