extends Control

var settings_tab_container: TabContainer

func _ready() -> void:
	settings_tab_container = %SettingsTabContainer
	settings_tab_container.set_tab_title(0, "Stylus")
	settings_tab_container.set_tab_title(1, "Monitor")
	
	#var output: Array
	
	# Get system settings
	#execute(path: String, arguments: PackedStringArray, output: Array = [], read_stderr: bool = false, open_console: bool = false) 
	#OS.execute("xrandr", [], output, true) 
	#print(output)


func _process(delta: float) -> void:
	pass
