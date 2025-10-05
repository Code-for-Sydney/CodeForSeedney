extends Node2D

@onready var ground = $Ground
@onready var ground_mask = $GroundMask
@onready var crop_layer = $Crops
@onready var topsoil = $SoilMoisture
@onready var subsoil = $SubSoilMoisture
@onready var ndvi = $NDVI
@onready var woman_scene = preload("res://scenes/woman.tscn")
@onready var toolbar = $ToolbarInstance
@onready var season_label = toolbar.get_node("SeasonTimer/SeasonLabel")
@onready var time_label = toolbar.get_node("SeasonTimer/TimeLabel")
@onready var progress_bar = toolbar.get_node("SeasonTimer/ProgressBar")

signal toggle_topsoil_label_requested
signal toggle_subsoil_label_requested
signal toggle_ndvi_label_requested
#@onready var season_label = $SeasonTimer/SeasonLabel
#@onready var time_label = $SeasonTimer/TimeLabel
#@onready var progress_bar = $SeasonTimer/ProgressBar

var physics_timer = 0
#Key 4 shouldn't be accessible, but something keeps trying to access it, so it is needed.
var water_to_block = {0:0,4:1,5:1,10:2,15:3,20:4,25:5,30:6,35:7}

var crop : Dictionary
@export var block : Dictionary[String, BlockData]

var auto_save_timer : Timer

func _ready():
	# Add this scene to the "world" group so the toolbar can access it
	add_to_group("world")
	
	Global.set_world_scene_reference(self)
	
	load_world_state()
	
	if not Global.has_save_file() and Global.player_name == "":
		Global.start_new_game("Player", "Kansas")
	
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 30.0
	auto_save_timer.timeout.connect(_auto_save)
	auto_save_timer.autostart = true
	add_child(auto_save_timer)
	
	var woman_instance = woman_scene.instantiate()
	add_child(woman_instance)
	woman_instance.position = Vector2(100, 100)
	
	Global.initialize_water_level(topsoil)
	
	$background_audio.play()

func load_world_state():
	"""Load the world state from Global if it exists"""
	if Global.current_world_scene is SaveGame:
		var save_data = Global.current_world_scene as SaveGame
		var world_state = save_data.load_world_state()
		
		Global.water_level = world_state.water_levels
		
		crop = world_state.crop_data
		for pos in crop:
			var crop_data = crop[pos]
			var crop_name = crop_data["name"]
			var duration = crop_data["duration"]
			
			if block.has(crop_name):
				var growth_index = 0
				if duration >= 0:
					if duration >= block[crop_name].duration:
						growth_index = block[crop_name].atlas_coords.size() - 1
					else:
						growth_index = block[crop_name].growth_index(duration)
				else:
					growth_index = block[crop_name].atlas_coords.size() - 1
				
				set_tile(crop_name, pos, crop_layer, growth_index)
		
		Global.current_world_scene = null

func get_world_state() -> Dictionary:
	"""Return current world state for saving"""
	return {
		"water_levels": Global.water_level,
		"crop_data": crop
	}

func _auto_save():
	print("Auto-save triggered")
	Global.save_game()
	print("Auto-save completed")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Global.save_game()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _physics_process(delta: float) -> void:
	# Update timer UI
	update_timer_ui()
	physics_timer += delta
	
	if physics_timer > 20:
		for pos in Global.water_level:
			if Global.water_level[pos] > 0:
				Global.water_level[pos] -= 0.05
				$SoilMoisture.set_cell(pos, block["moisture"].source_id, block["moisture"].atlas_coords[water_to_block[int(Global.water_level[pos]*100)]])
		physics_timer = 0
		
	for pos in crop:
		if Global.water_level.has(pos):
			crop[pos]["duration"] += delta
			
			var duration = crop[pos]["duration"]
			var crop_name = crop[pos]["name"]
			
			if duration >= block[crop_name].duration:
				set_tile(crop_name, pos, crop_layer, block[crop_name].atlas_coords.size() - 1)
				crop[pos]["duration"] = -INF
			elif duration > 0:
				var index = block[crop_name].growth_index(duration)
				set_tile(crop_name, pos, crop_layer, index)

func _input(event):
	
	if event.is_action_pressed("toggle_SMAPTop"):
		var new_state = !topsoil.visible   # calculate new visibility
		topsoil.visible = new_state
		subsoil.visible = false
		ndvi.visible = false
		emit_signal("toggle_topsoil_label_requested", new_state)  # pass new_state
	
	if event.is_action_pressed("toggle_Subsoil"):
		var new_state = !subsoil.visible
		subsoil.visible = new_state
		topsoil.visible = false
		ndvi.visible = false
		emit_signal("toggle_subsoil_label_requested", new_state)
		
	if event.is_action_pressed("toggle_NDVI"):
		var new_state = !ndvi.visible
		ndvi.visible = new_state
		topsoil.visible = false
		subsoil.visible = false
		emit_signal("toggle_ndvi_label_requested", new_state)
		
	if event is InputEventMouseButton and event.is_pressed():
		var tile_pos = get_snapped_position(get_global_mouse_position())
		
		var mask_data = ground_mask.get_cell_tile_data(tile_pos)
		if mask_data:
			var mask_name = mask_data.get_custom_data("mask_type")
			if mask_name == "no_crops":
				return
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			var data = ground.get_cell_tile_data(tile_pos)
			if data:
				var tile_name = data.get_custom_data("tile_name")
				watering_tile(tile_name, tile_pos, 1.0)
				
			var harvested = harvesting(tile_pos)
			if harvested:
				Global.save_game()
			
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var planted = plant_crop(tile_pos)
			if planted:
				$Crops/plant_audio.pitch_scale = randf_range(0.9, 1.1)
				$Crops/plant_audio.play()
			else:
				$Crops/unplant_audio.pitch_scale = randf_range(0.8, 1.1)
				$Crops/unplant_audio.play()

func plant_crop(tile_pos: Vector2i) -> bool:
	"""Plant a crop and track the action"""
	if Global.crops.has(Global.current_tool) and Global.crops[Global.current_tool] > 0:
		if not Global.can_plant_crop(Global.current_tool):
			return false
		
		set_tile(Global.current_tool, tile_pos, crop_layer)
		crop[tile_pos] = { "name" : Global.current_tool, "duration" : 0 }
		Global.crops[Global.current_tool] -= 1
		Global.track_crop_planted()
		
		Global.save_game()
		return true
	else:
		return false

func get_snapped_position(global_pos: Vector2) -> Vector2i:
	var local_pos = crop_layer.to_local(global_pos)
	var tile_pos = crop_layer.local_to_map(local_pos)
	return tile_pos

func set_tile(tile_name: String, cell_pos: Vector2i, layer: TileMapLayer, coord: int = 0):
	if block.has(tile_name):
		layer.set_cell(cell_pos, block[tile_name].source_id, block[tile_name].atlas_coords[coord])

func watering_tile(tile_name: String, pos: Vector2i, _amount: float = 1.0):
	
	if not Global.water_level.has(pos):
		return
	if  Global.water_level[pos] < 0.34:
		Global.water_level[pos] += 0.05
	
	$SoilMoisture.set_cell(pos, block["moisture"].source_id, block["moisture"].atlas_coords[water_to_block[int(Global.water_level[pos]*100)]])

func drying_tile(pos):
	var tile_pos = get_snapped_position(pos)
	var data = ground.get_cell_tile_data(tile_pos)

func harvesting(pos) -> bool:
	if crop_layer.get_cell_source_id(pos) != -1 and crop.has(pos) and crop[pos]["duration"] < 0:
		crop_layer.erase_cell(pos)
		crop.erase(pos)
		var money_gained = 100
		Global.budget += money_gained
		Global.track_crop_harvested(money_gained)
		return true
	return false

func update_timer_ui():
	if season_label:
		season_label.text = Global.get_current_season_name()
	
	if time_label:
		var time_remaining = Global.get_season_time_remaining()
		time_label.text = Global.format_time(time_remaining)
	
	if progress_bar:
		progress_bar.value = Global.get_season_progress()
