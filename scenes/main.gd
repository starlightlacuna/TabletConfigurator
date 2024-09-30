extends Control

var settings_tab_container: TabContainer
var revert_button: Button
var apply_button: Button

func _ready() -> void:
	settings_tab_container = %SettingsTabContainer
	settings_tab_container.set_tab_title(0, "Stylus")
	settings_tab_container.set_tab_title(1, "Monitor")
	
	revert_button = %RevertButton
	apply_button = %ApplyButton
	
	SystemSettings.state_modified.connect(func () -> void:
		_disable_buttons(false)
	)
	
	SystemSettings.states_equalized.connect(func () -> void:
		_disable_buttons(true)
	)
	
	_disable_buttons(true)

func _disable_buttons(disable: bool) -> void:
	apply_button.set_disabled(disable)
	revert_button.set_disabled(disable)
	if disable:
		apply_button.set_focus_mode(FocusMode.FOCUS_NONE)
		revert_button.set_focus_mode(FocusMode.FOCUS_NONE)
	else:
		apply_button.set_focus_mode(FocusMode.FOCUS_ALL)
		revert_button.set_focus_mode(FocusMode.FOCUS_ALL)

func _on_close_button_pressed() -> void:
	get_tree().quit()

func _on_revert_button_pressed() -> void:
	_disable_buttons(true)

func _on_apply_button_pressed() -> void:
	_disable_buttons(true)
	
