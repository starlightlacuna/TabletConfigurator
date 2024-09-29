extends Node

const XSETWACOM: String = "xsetwacom"
const XRANDR: String = "xrandr"

var system_state: State
var unsaved_state: State

func _ready() -> void:
	system_state = State.new()
	
	system_state.set_devices(_get_system_devices())
	system_state.set_monitors(_get_system_monitors())

func _get_system_devices() -> Dictionary:
	var output: Array
	OS.execute(XSETWACOM, ["list", "devices"], output, true)
	if output.size() > 1:
		printerr(output[1])
		return {}
	var device_strings: Array = (output[0] as String).split("\n")
	device_strings.remove_at(device_strings.size() - 1)
	var device_info: Dictionary = {}
	for device in device_strings:
		var info: Array = device.split("\t")
		for index in info.size():
			info[index] = (info[index] as String).rstrip(" ")
		var new_device: Device = Device.new()
		new_device.name = info[0]
		new_device.id = (info[1] as String).substr(4)
		new_device.set_type((info[2] as String).substr(6))
		new_device.set_mode(_get_mode(new_device.id))
		if device_info.has(new_device.id):
			printerr("Duplicate device ID found! (%s)" % new_device.id)
			return {}
		device_info[new_device.id] = new_device
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
	
func _get_system_monitors() -> Dictionary:
	var output: Array
	OS.execute(XRANDR, [], output, true)
	if output.size() > 1:
		printerr(output[1])
		return {}
	var monitor_lines: Array = (output[0] as String).split("\n")
	
	var monitors_found: Dictionary = {}
	for index in monitor_lines.size() - 1:
		var line: Array = (monitor_lines[index] as String).split(" ", false)
		
		var monitor: Monitor = Monitor.new()
		
		if index == 0:
			monitor.id = "desktop"
			monitor.name = "All"
			monitor.resolution = Vector2i(int(line[7]), int(line[9]))
			monitors_found[monitor.id] = monitor
			continue
			
		if line[1] != "connected":
			continue
		
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
		monitors_found[monitor.id] = monitor
	return monitors_found

func get_stylus_devices() -> Array:
	var stylus_devices: Array = []
	var devices: Dictionary = system_state.get_devices()
	for device_key in devices:
		if (devices[device_key] as Device).get_type() == Device.Type.STYLUS:
			stylus_devices.push_back(devices[device_key])
	return stylus_devices
	
func get_monitors() -> Dictionary:
	return system_state.get_monitors()
