extends Node

var current_tool : String = "corn"
var budget: int = 1000
var crops = { "corn" : 10, "wheat" : 10, "soy" : 10 }
var water = 10
var fertiliser = 10

var player_name: String = ""
var selected_state: String = ""
var game_start_time: String = ""
var session_start_time: float = 0.0

var total_crops_planted: int = 0
var total_crops_harvested: int = 0
var total_money_earned: int = 0

var current_world_scene = null

const SAVE_FILE_PATH = "user://savegame.tres"

var us_states = [
	"Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
	"Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
	"Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
	"Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
	"Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
	"New Hampshire", "New Jersey", "New Mexico", "New York",
	"North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
	"Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
	"Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
	"West Virginia", "Wisconsin", "Wyoming"
]

func _ready():
	session_start_time = Time.get_ticks_msec() / 1000.0
	
	var user_dir = OS.get_user_data_dir()
	print("User data directory: ", user_dir)
	print("Full save path will be: ", ProjectSettings.globalize_path(SAVE_FILE_PATH))
	
	test_file_access()

func start_new_game(player_name_input: String, state_input: String):
	"""Initialize a new game with player data and record start time"""
	player_name = player_name_input
	selected_state = state_input
	game_start_time = Time.get_datetime_string_from_system()
	session_start_time = Time.get_ticks_msec() / 1000.0
	
	# Reset game state for new game
	budget = 1000
	crops = { "corn" : 10, "wheat" : 10, "soy" : 10 }
	water = 10
	fertiliser = 10
	current_tool = "corn"
	
	save_game()

func save_game():
	"""Save the current game state"""
	print("Attempting to save game...")
	
	var save_data = {
		"player_name": player_name,
		"selected_state": selected_state,
		"game_start_time": game_start_time,
		"budget": budget,
		"crops": crops,
		"water": water,
		"fertiliser": fertiliser,
		"current_tool": current_tool,
		"play_time_seconds": (Time.get_ticks_msec() / 1000.0) - session_start_time,
		"total_crops_planted": total_crops_planted,
		"total_crops_harvested": total_crops_harvested,
		"total_money_earned": total_money_earned,
		"save_date": Time.get_datetime_string_from_system()
	}
	
	if current_world_scene and current_world_scene.has_method("get_world_state"):
		var world_state = current_world_scene.get_world_state()
		save_data["world_water_levels"] = {}
		save_data["world_crops"] = {}
		
		for pos in world_state.water_levels:
			save_data["world_water_levels"][str(pos.x) + "," + str(pos.y)] = world_state.water_levels[pos]
		
		for pos in world_state.crop_data:
			save_data["world_crops"][str(pos.x) + "," + str(pos.y)] = world_state.crop_data[pos]
			
		print("World state saved: ", save_data["world_crops"].size(), " crops, ", save_data["world_water_levels"].size(), " water tiles")
	
	var json_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if json_file:
		json_file.store_string(JSON.stringify(save_data))
		json_file.close()
		print("JSON save successful")
	else:
		print("JSON save failed")
	
	var save_game_resource = SaveGame.new()
	save_game_resource.player_name = player_name
	save_game_resource.selected_state = selected_state
	save_game_resource.game_start_time = game_start_time
	save_game_resource.budget = budget
	save_game_resource.crops = crops
	save_game_resource.water = water
	save_game_resource.fertiliser = fertiliser
	save_game_resource.current_tool = current_tool
	save_game_resource.play_time_seconds = (Time.get_ticks_msec() / 1000.0) - session_start_time
	save_game_resource.total_crops_planted = total_crops_planted
	save_game_resource.total_crops_harvested = total_crops_harvested
	save_game_resource.total_money_earned = total_money_earned
	
	if current_world_scene and current_world_scene.has_method("get_world_state"):
		var world_state = current_world_scene.get_world_state()
		save_game_resource.save_world_state(world_state.water_levels, world_state.crop_data)
	
	var error = ResourceSaver.save(save_game_resource, SAVE_FILE_PATH)
	if error == OK:
		print("Game saved successfully to: ", SAVE_FILE_PATH)
	else:
		print("Failed to save game. Error code: ", error)

func load_game() -> bool:
	"""Load the game state from save file. Returns true if successful."""
	print("Attempting to load game from: ", SAVE_FILE_PATH)
	
	# Try loading the resource file first
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var save_game_resource = load(SAVE_FILE_PATH) as SaveGame
		if save_game_resource != null:
			print("Successfully loaded resource save file")
			restore_game_state_from_resource(save_game_resource)
			return true
		else:
			print("Resource save file exists but failed to load")
	
	if FileAccess.file_exists("user://savegame.json"):
		print("Trying JSON save file...")
		var json_file = FileAccess.open("user://savegame.json", FileAccess.READ)
		if json_file:
			var json_string = json_file.get_as_text()
			json_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var save_data = json.data
				restore_game_state_from_dict(save_data)
				print("Successfully loaded JSON save file")
				return true
			else:
				print("Failed to parse JSON save file")
		else:
			print("Failed to open JSON save file")
	
	print("No valid save file found")
	return false

func restore_game_state_from_resource(save_game_resource: SaveGame):
	"""Restore game state from SaveGame resource"""
	player_name = save_game_resource.player_name
	selected_state = save_game_resource.selected_state
	game_start_time = save_game_resource.game_start_time
	budget = save_game_resource.budget
	crops = save_game_resource.crops
	water = save_game_resource.water
	fertiliser = save_game_resource.fertiliser
	current_tool = save_game_resource.current_tool
	total_crops_planted = save_game_resource.total_crops_planted
	total_crops_harvested = save_game_resource.total_crops_harvested
	total_money_earned = save_game_resource.total_money_earned
	
	current_world_scene = save_game_resource
	print("Loaded player: ", player_name, " from ", selected_state)

func restore_game_state_from_dict(save_data: Dictionary):
	"""Restore game state from dictionary"""
	player_name = save_data.get("player_name", "")
	selected_state = save_data.get("selected_state", "")
	game_start_time = save_data.get("game_start_time", "")
	budget = save_data.get("budget", 1000)
	crops = save_data.get("crops", {"corn": 10, "wheat": 10, "soy": 10})
	water = save_data.get("water", 10)
	fertiliser = save_data.get("fertiliser", 10)
	current_tool = save_data.get("current_tool", "corn")
	total_crops_planted = save_data.get("total_crops_planted", 0)
	total_crops_harvested = save_data.get("total_crops_harvested", 0)
	total_money_earned = save_data.get("total_money_earned", 0)

	var fake_save = SaveGame.new()
	fake_save.player_name = player_name
	fake_save.selected_state = selected_state
	fake_save.game_start_time = game_start_time
	fake_save.world_water_levels = save_data.get("world_water_levels", {})
	fake_save.world_crops = save_data.get("world_crops", {})
	
	current_world_scene = fake_save
	print("Loaded player from JSON: ", player_name, " from ", selected_state)

func has_save_file() -> bool:
	"""Check if a save file exists"""
	var resource_exists = FileAccess.file_exists(SAVE_FILE_PATH)
	var json_exists = FileAccess.file_exists("user://savegame.json")
	var exists = resource_exists or json_exists
	print("Checking for save files - Resource: ", resource_exists, " JSON: ", json_exists, " - Has save: ", exists)
	return exists

func delete_save_file():
	"""Delete the current save file"""
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)

func get_save_file_info() -> Dictionary:
	"""Get information about the save file for display"""
	# Try resource file first
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var save_game_resource = load(SAVE_FILE_PATH) as SaveGame
		if save_game_resource != null:
			return {
				"player_name": save_game_resource.player_name,
				"selected_state": save_game_resource.selected_state,
				"game_start_time": save_game_resource.game_start_time,
				"save_date": save_game_resource.save_date,
				"play_time_seconds": save_game_resource.play_time_seconds,
				"budget": save_game_resource.budget,
				"total_crops_planted": save_game_resource.total_crops_planted,
				"total_crops_harvested": save_game_resource.total_crops_harvested,
				"total_money_earned": save_game_resource.total_money_earned
			}
	
	if FileAccess.file_exists("user://savegame.json"):
		var json_file = FileAccess.open("user://savegame.json", FileAccess.READ)
		if json_file:
			var json_string = json_file.get_as_text()
			json_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var save_data = json.data
				return {
					"player_name": save_data.get("player_name", ""),
					"selected_state": save_data.get("selected_state", ""),
					"game_start_time": save_data.get("game_start_time", ""),
					"save_date": save_data.get("save_date", ""),
					"play_time_seconds": save_data.get("play_time_seconds", 0.0),
					"budget": save_data.get("budget", 1000),
					"total_crops_planted": save_data.get("total_crops_planted", 0),
					"total_crops_harvested": save_data.get("total_crops_harvested", 0),
					"total_money_earned": save_data.get("total_money_earned", 0)
				}
	
	return {}

func track_crop_planted():
	"""Increment crop planting counter"""
	total_crops_planted += 1

func track_crop_harvested(money_gained: int = 100):
	"""Increment harvest counter and money earned"""
	total_crops_harvested += 1
	total_money_earned += money_gained

func set_world_scene_reference(world_scene):
	"""Set reference to current world scene for state saving"""
	current_world_scene = world_scene

func test_file_access():
	"""Test if we can write to the save directory"""
	var test_path = "user://test_write.txt"
	var file = FileAccess.open(test_path, FileAccess.WRITE)
	if file:
		file.store_string("test")
		file.close()
		print("Write test successful")
		# Clean up
		DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	else:
		print("Write test failed - cannot access user directory")
