class_name Monitor
extends Resource

## String ID of the display. This is what we pass into the `xsetwacom` command.
var id: String
## This is what we show to the user.
var name: String
var resolution: Vector2i
var offset: Vector2i
