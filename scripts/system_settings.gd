extends Node


const XSETWACOM: String = "xsetwacom"

enum Mode { ABSOLUTE, RELATIVE, ERROR }

var current_mode: Mode

# TODO: Convert this mixed array into an array of custom Device objects
## String array containing info about Wacom devices
## 0: Name
## 1: ID
## 2: type
## 3: Mode
var devices: Array

func _ready() -> void:
	# 1. Get the devices.
	devices = _get_devices()
	# 2. Get the mode.
	for device in devices:
		(device as Array).push_back(_get_mode(device[1]))
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
		info[1] = (info[1] as String).substr(4)
		info[2] = (info[2] as String).substr(6)
		device_info.push_back(info)
		
	return device_info

func _get_mode(device_id: String) -> Mode:
	var output: Array
	OS.execute(XSETWACOM, ["get", device_id, "Mode"], output)
	if output.size() > 1:
		printerr(output[1])
		# THIS IS A HACK. DON'T LEAVE THIS LIKE THIS PLEASE.
		return Mode.ERROR
	if output[0] == "Absolute\n":
		return Mode.ABSOLUTE
	if output[0] == "Relative\n":
		return Mode.RELATIVE
	return Mode.ERROR

func _set_mode(device_id: String, mode: Mode) -> void:
	var mode_string: String = "Absolute" if mode == Mode.ABSOLUTE else "Relative"
	var output: Array
	OS.execute(XSETWACOM, ["set", device_id, "Mode", mode_string], output)
	if output.size() > 1:
		printerr(output[1])
		return
	print(output)

func get_stylus_devices() -> Array:
	var stylus_devices: Array = []
	for device in devices:
		if device[2] == "STYLUS":
			stylus_devices.push_back(device)
	return stylus_devices
