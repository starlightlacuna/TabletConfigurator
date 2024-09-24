class_name Device
extends Resource

enum Type { STYLUS, PAD }
enum Mode { ABSOLUTE, RELATIVE, ERROR }

var name: String
var id: String
var type: Type
var mode: Mode

func set_type(p_type_string: String) -> void:
	if p_type_string == "STYLUS":
		type = Type.STYLUS
	elif p_type_string == "PAD":
		type = Type.PAD
	else:
		printerr("Unknown device type!")
		
func get_type() -> Type:
	return type

func set_mode(mode_string: String) -> void:
	if mode_string == "Absolute":
		mode = Mode.ABSOLUTE
	elif mode_string == "Relative":
		mode = Mode.RELATIVE
	else:
		printerr("Unknown mode!")

func get_mode() -> Mode:
	return mode
