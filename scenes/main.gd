extends Control

var settings_tab_container: TabContainer

func _ready() -> void:
	settings_tab_container = %SettingsTabContainer
	settings_tab_container.set_tab_title(0, "Stylus")
	settings_tab_container.set_tab_title(1, "Monitor")


func _on_close_button_pressed() -> void:
	get_tree().quit()

func _on_revert_button_pressed() -> void:
	pass # Replace with function body.

func _on_apply_button_pressed() -> void:
	pass # Replace with function body.
