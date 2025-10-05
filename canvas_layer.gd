extends CanvasLayer



@onready var wheat_cursor =preload("res://images/opengameart_josehzz/WheatCursor.tres")
@onready var corn_cursor = preload("res://images/opengameart_josehzz/CornCursor.tres")
@onready var waterjug_cursor = preload("res://images/WaterJug.png")


var cursor_sprite: Sprite2D

func _ready():
	# Hide the default OS cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# Create the Sprite2D cursor
	cursor_sprite = Sprite2D.new()
	cursor_sprite.texture = wheat_cursor  # default cursor
	cursor_sprite.scale = Vector2(4, 4)
	add_child(cursor_sprite)

	# Connect toolbar buttons
	$PanelContainer/VBoxContainer/WheatButton.pressed.connect(func(): set_cursor("wheat"))
	$PanelContainer/VBoxContainer/CornButton.pressed.connect(func(): set_cursor("corn"))
	$PanelContainer/VBoxContainer/WaterJugButton.pressed.connect(func(): set_cursor("water"))

func _process(delta):
	# Make the cursor follow the mouse
	cursor_sprite.global_position = get_viewport().get_mouse_position()

func set_cursor(tool_name: String):
	match tool_name:
		"wheat":
			cursor_sprite.texture = wheat_cursor
			cursor_sprite.scale = Vector2(4, 4)
		"corn":
			cursor_sprite.texture = corn_cursor
			cursor_sprite.scale = Vector2(5, 5)
		"water":
			cursor_sprite.scale = Vector2(1.5,1.5)
			cursor_sprite.texture = waterjug_cursor
