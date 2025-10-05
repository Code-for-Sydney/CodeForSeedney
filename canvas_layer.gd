extends CanvasLayer



@onready var wheat_cursor =preload("res://images/opengameart_josehzz/WheatCursor.tres")
@onready var corn_cursor = preload("res://images/opengameart_josehzz/CornCursor.tres")
@onready var waterjug_cursor = preload("res://images/WaterJug.png")
@onready var topsoil_label = $LabelSoilMoisture
@onready var subsoil_label = $LabelSubSoilMoisture
@onready var ndvi_label = $LabelNDVI

var cursor_sprite: Sprite2D

func _ready():
	# Connect to World Signals
	var world = get_parent()  # World is the parent
	world.connect("toggle_topsoil_label_requested", Callable(self, "toggle_topsoil_label"))
	world.connect("toggle_subsoil_label_requested", Callable(self, "toggle_subsoil_label"))
	world.connect("toggle_ndvi_label_requested", Callable(self, "toggle_subsoil_label"))
	#labels shold be hidden initially
	topsoil_label.visible=false
	subsoil_label.visible=false
	ndvi_label.visible=false
	# Hide the default OS cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# Create the Sprite2D cursor
	cursor_sprite = Sprite2D.new()
	cursor_sprite.texture = wheat_cursor  # default cursor
	cursor_sprite.scale = Vector2(2, 2)
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
			cursor_sprite.scale = Vector2(2, 2)
		"corn":
			cursor_sprite.texture = corn_cursor
			cursor_sprite.scale = Vector2(2.5, 2.5)
		"water":
			cursor_sprite.scale = Vector2(0.7,0.7)
			cursor_sprite.texture = waterjug_cursor
func toggle_topsoil_label(state: bool):
	topsoil_label.visible = state
	if topsoil_label.visible==true:
		subsoil_label.visible=false
		ndvi_label.visible=false

func toggle_subsoil_label(state: bool):
	subsoil_label.visible = state
	if subsoil_label.visible==true:
		topsoil_label.visible=false
		ndvi_label.visible=false
		
func toggle_ndvi_label(state: bool):
	ndvi_label.visible = state
	if ndvi_label.visible==true:
		topsoil_label.visible=false
		subsoil_label.visible=false
	
