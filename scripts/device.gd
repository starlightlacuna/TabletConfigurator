class_name Device
extends Resource

const PARAMETERS: Dictionary = {
	Mode = "Mode",
}

const MODES: Dictionary = {
	Absolute = "Absolute",
	Relative = "Relative"
}

enum Type { STYLUS, PAD }

var name: String
var _id: String
var type: Type

# Parameters are retrieved from the `xsetwacom get [id] All` command.
var _parameters: Dictionary = {}

func get_id() -> String:
	return _id

func set_id(p_id: String) -> void:
	_id = p_id

func get_type() -> Type:
	return type

func set_type(p_type_string: String) -> void:
	if p_type_string == "STYLUS":
		type = Type.STYLUS
	elif p_type_string == "PAD":
		type = Type.PAD
	else:
		printerr("Unknown device type!")

func set_parameters(p_parameters: Dictionary) -> void:
	_parameters = p_parameters

func get_parameter(key: String) -> String:
	return _parameters[key]

func set_parameter(key: String, value: String) -> void:
	match key:
		PARAMETERS.Mode:
			if not (value == MODES.Absolute or value == MODES.Relative):
				return
	
	_parameters[key] = value
