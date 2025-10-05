extends CanvasLayer

@onready var topsoil_label = $LabelSoilMoisture
@onready var subsoil_label = $LabelSubSoilMoisture
@onready var ndvi_label = $LabelNDVI

var active_tool: String = ""

func _ready():
	# Connect to World Signals
	var world = get_parent()  # World is the parent
	world.connect("toggle_topsoil_label_requested", Callable(self, "toggle_topsoil_label"))
	world.connect("toggle_subsoil_label_requested", Callable(self, "toggle_subsoil_label"))
	world.connect("toggle_ndvi_label_requested", Callable(self, "toggle_ndvi_label"))
	
	# Labels should be hidden initially
	topsoil_label.visible = false
	subsoil_label.visible = false
	ndvi_label.visible = false
	
	# Connect toolbar buttons
	$PanelContainer/VBoxContainer/WheatButton.pressed.connect(func(): set_tool("wheat"))
	$PanelContainer/VBoxContainer/CornButton.pressed.connect(func(): set_tool("corn"))
	$PanelContainer/VBoxContainer/WaterJugButton.pressed.connect(func(): set_tool("water"))

func set_tool(tool_name: String):
	active_tool = tool_name
	Global.current_tool = tool_name
	# Update button appearances to show which is active
	update_button_states(tool_name)

func update_button_states(active_tool_name: String):
	# Reset all button modulations
	$PanelContainer/VBoxContainer/WheatButton.modulate = Color.WHITE
	$PanelContainer/VBoxContainer/CornButton.modulate = Color.WHITE
	$PanelContainer/VBoxContainer/WaterJugButton.modulate = Color.WHITE
	
	# Highlight the active tool
	match active_tool_name:
		"wheat":
			$PanelContainer/VBoxContainer/WheatButton.modulate = Color.YELLOW
		"corn":
			$PanelContainer/VBoxContainer/CornButton.modulate = Color.YELLOW
		"water":
			$PanelContainer/VBoxContainer/WaterJugButton.modulate = Color.YELLOW

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world = get_tree().get_first_node_in_group("world")
		if world and active_tool != "":
			var tile_pos = world.get_snapped_position(world.get_global_mouse_position())
			
			# Check if clicking on a valid tile (not UI elements)
			var mask_data = world.ground_mask.get_cell_tile_data(tile_pos)
			if mask_data:
				var mask_name = mask_data.get_custom_data("mask_type")
				if mask_name == "no_crops":
					return
			
			if active_tool == "water":
				# Water the tile
				var data = world.ground.get_cell_tile_data(tile_pos)
				if data:
					var tile_name = data.get_custom_data("tile_name")
					world.watering_tile(tile_name, tile_pos, 1.0)
					if Global.water > 0:
						Global.water -= 1
			elif active_tool in ["corn", "wheat"]:
				# Plant the crop
				var planted = world.plant_crop(tile_pos)
				if planted:
					world.get_node("Crops/plant_audio").pitch_scale = randf_range(0.9, 1.1)
					world.get_node("Crops/plant_audio").play()
				else:
					world.get_node("Crops/unplant_audio").pitch_scale = randf_range(0.9, 1.1)
					world.get_node("Crops/unplant_audio").play()

func toggle_topsoil_label(state: bool):
	topsoil_label.visible = state
	if state == true:
		subsoil_label.visible = false
		ndvi_label.visible = false

func toggle_subsoil_label(state: bool):
	subsoil_label.visible = state
	if state == true:
		topsoil_label.visible = false
		ndvi_label.visible = false
		
func toggle_ndvi_label(state: bool):
	ndvi_label.visible = state
	if state == true:
		topsoil_label.visible = false
		subsoil_label.visible = false

func _on_topsoil_button_pressed():
	var world_scene = get_tree().get_first_node_in_group("world")
	if world_scene:
		world_scene.subsoil.visible = false
		world_scene.topsoil.visible = true
		$LabelSubSoilMoisture.visible = false
		$LabelSoilMoisture.visible = true

func _on_subsoil_button_pressed():
	var world_scene = get_tree().get_first_node_in_group("world")
	if world_scene:
		world_scene.topsoil.visible = false
		world_scene.subsoil.visible = true
		$LabelSoilMoisture.visible = false
		$LabelSubSoilMoisture.visible = true

func _on_hide_moisture_button_pressed():
	var world_scene = get_tree().get_first_node_in_group("world")
	if world_scene:
		world_scene.topsoil.visible = false
		world_scene.subsoil.visible = false
		$LabelSoilMoisture.visible = false
		$LabelSubSoilMoisture.visible = false

func _on_settings_button_pressed():
	var settings_panel = $SettingsPanel
	if settings_panel:
		settings_panel.visible = !settings_panel.visible

func _on_close_settings_button_pressed():
	var settings_panel = $SettingsPanel
	if settings_panel:
		settings_panel.visible = false

func _on_save_quit_button_pressed():
	Global.save_game()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_export_button_pressed():
	var export_code = Global.export_game_state()
	var export_dialog = $ExportDialog
	var export_code_edit = $ExportDialog/VBoxContainer/ExportCodeEdit
	
	if export_dialog and export_code_edit:
		export_code_edit.text = export_code
		export_dialog.visible = true
		# Close settings panel
		var settings_panel = $SettingsPanel
		if settings_panel:
			settings_panel.visible = false

func _on_copy_code_button_pressed():
	var export_code_edit = $ExportDialog/VBoxContainer/ExportCodeEdit
	if export_code_edit:
		DisplayServer.clipboard_set(export_code_edit.text)
		print("Export code copied to clipboard!")

func _on_close_export_button_pressed():
	var export_dialog = $ExportDialog
	if export_dialog:
		export_dialog.visible = false

func _on_share_button_pressed():
	var share_text = Global.generate_share_text()
	# Copy to clipboard
	DisplayServer.clipboard_set(share_text)
	print("Share text copied to clipboard: ", share_text)
