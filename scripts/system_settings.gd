extends Node

signal state_modified
signal states_equalized

const XSETWACOM: String = "xsetwacom"
const XRANDR: String = "xrandr"

var system_state: State
var unsaved_state: State

func _ready() -> void:
	system_state = State.new()
	system_state.set_devices(_get_system_devices())
	system_state.set_monitors(_get_system_monitors())
	
	# We can't simply duplicate the system state because State and the contents
	# of its member dictionaries are custom Resources. There's probably a more
	# clever way of doing this, but for now we're repeating OS calls.
	unsaved_state = State.new()
	unsaved_state.set_devices(_get_system_devices())

## Compares the system state and unsaved state and returns all the keys that 
## have been changed. The returned dictionary has:
##   key = device ID
##   value = Array of changed parameter names
func _get_unsaved_keys() -> Dictionary: 
	var system_devices: Dictionary = system_state.get_devices()
	var unsaved_devices: Dictionary = unsaved_state.get_devices()
	
	var output: Dictionary = {}
	
	for device_id in system_devices:
		output[device_id] = []
		var system_device: Device = system_devices[device_id]
		var unsaved_device: Device = unsaved_devices[device_id]
		
		for parameter_name in Device.PARAMETERS:
			if system_device.get_parameter(parameter_name) == unsaved_device.get_parameter(parameter_name):
				continue
			(output[device_id] as Array).push_back(parameter_name)
	return output

func _has_unsaved_changes() -> bool:
	var unsaved_keys: Dictionary = _get_unsaved_keys()
	for device_id in unsaved_keys:
		if (unsaved_keys[device_id] as Array).is_empty():
			continue
		return true
	return false

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
		new_device.set_id((info[1] as String).substr(4))
		if device_info.has(new_device.get_id()):
			printerr("Duplicate device ID found! (%s)" % new_device.get_id())
			return {}
		
		new_device.name = info[0]
		new_device.set_type((info[2] as String).substr(6))
		var device_parameters: Dictionary = _get_device_parameters(new_device.get_id())
		new_device.set_parameters(device_parameters)
		device_info[new_device.get_id()] = new_device
	return device_info

func _get_device_parameters(device_id: String) -> Dictionary:
	var output: Array
	OS.execute(XSETWACOM, ["get", device_id, "all"], output)
	if output.size() > 1:
		printerr("Error retrieving device parameters! (%s)" % device_id)
		return {}
	var parameter_strings: Array = (output[0] as String).rstrip("\n").split("\n")
	var device_parameters: Dictionary = {}
	for parameter_string in parameter_strings:
		var words: Array[String] = []
		words.assign(parameter_string.split("\""))
		device_parameters[words[1]] = words[3]
	return device_parameters

#func _set_mode(device_id: String, mode: String) -> void:
	#var output: Array
	#OS.execute(XSETWACOM, ["set", device_id, "Mode", mode], output)
	#if output.size() > 1:
		#printerr(output[1])
		#return

func _set_system_parameter(device_id: String, parameter: String, value: String) -> void:
	var output: Array
	OS.execute(XSETWACOM, ["set", device_id, parameter, value], output)
	if output.size() > 1:
		printerr(output[1])
	
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

func get_stylus_device_ids() -> Array:
	var stylus_ids: Array = []
	var devices: Dictionary = system_state.get_devices()
	for device_key in devices:
		if (devices[device_key] as Device).get_type() == Device.Type.STYLUS:
			stylus_ids.push_back(device_key)
	return stylus_ids
	
func get_monitors() -> Dictionary:
	return system_state.get_monitors()

func set_unsaved_parameter(device_id: String, parameter: String, value: String) -> void:
	var device: Device = (unsaved_state as State).devices[device_id]
	device.set_parameter(parameter, value)
	if _has_unsaved_changes():
		state_modified.emit()
	else:
		states_equalized.emit()

func get_system_parameter(device_id: String, parameter: String) -> String:
	var device: Device = (system_state as State).devices[device_id]
	return device.get_parameter(parameter)

func get_unsaved_parameter(device_id: String, parameter: String) -> String:
	var device: Device = (unsaved_state as State).devices[device_id]
	return device.get_parameter(parameter)
