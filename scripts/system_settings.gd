extends Node

const XSETWACOM: String = "xsetwacom"
const XRANDR: String = "xrandr"

var current_mode: Device.Mode

## Array containing Device resources with info about Wacom devices.
var devices: Array
## Array containing Monitor resources. 
var monitors: Dictionary

func _ready() -> void:
	devices = _get_devices()
	monitors = _get_monitors()

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
	
func _get_monitors() -> Dictionary:
	var output: Array
	OS.execute(XRANDR, [], output, true)
	if output.size() > 1:
		printerr(output[1])
		return {}
	var monitor_lines: Array = (output[0] as String).split("\n")
	
	var monitors: Dictionary = {}
	for index in monitor_lines.size() - 1:
		var line: Array = (monitor_lines[index] as String).split(" ", false)
		
		# TODO: Try to refactor this into guard clauses
		if index == 0:
			var monitor: Monitor = Monitor.new()
			monitor.id = "desktop"
			monitor.name = "All"
			monitor.resolution = Vector2i(int(line[7]), int(line[9]))
			monitors[monitor.id] = monitor
			continue
		if line[1] == "connected":
			var monitor: Monitor = Monitor.new()
			monitor.id = line[0]
			monitor.name = monitor.id
			var resolution_array: Array
			if line[2] == "primary":
				resolution_array = line[3].split("x")
			else:
				resolution_array = line[2].split("x")
			var temp: Array = resolution_array.pop_back().split("+")
			for element in temp:
				resolution_array.push_back(int(element))
			resolution_array[0] = int(resolution_array[0])
			monitor.resolution = Vector2i(resolution_array[0], resolution_array[1])
			monitor.offset = Vector2i(resolution_array[2], resolution_array[3])
			monitors[monitor.id] = monitor
			continue
	return monitors

func get_stylus_devices() -> Array:
	var stylus_devices: Array = []
	for device in devices:
		if device.get_type() == Device.Type.STYLUS:
			stylus_devices.push_back(device)
	return stylus_devices
