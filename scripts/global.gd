extends Node

var current_tool : String = "corn"
var budget: int = 1000
var crops = { "corn" : 10, "wheat" : 10, "soy" : 10 }
var water = 10
var fertiliser = 10
var water_level = {}

var player_name: String = ""
var selected_state: String = ""
var game_start_time: String = ""
var session_start_time: float = 0.0

var total_crops_planted: int = 0
var total_crops_harvested: int = 0
var total_money_earned: int = 0

var current_world_scene = null

# Timing system
var game_time_elapsed: float = 0.0
var current_season: String = "spring"  # Current growing season: "spring" (corn) or "fall" (wheat)
var season_duration: float = 300.0  # 5 minutes per season
var seasons = ["spring", "fall"]  # Spring = corn planting, Autumn = wheat planting || note - it's autumn, NOT fall. But, for our American viewers/judges...hmm

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

# State-specific agricultural data
var state_data = {
	"Alabama": {"temp": 85, "moisture": 75, "sunlight": 8.5, "rainfall": 52, "difficulty": "medium"},
	"Alaska": {"temp": 45, "moisture": 45, "sunlight": 6.0, "rainfall": 22, "difficulty": "hard"},
	"Arizona": {"temp": 95, "moisture": 35, "sunlight": 9.5, "rainfall": 9, "difficulty": "hard"},
	"Arkansas": {"temp": 82, "moisture": 70, "sunlight": 8.0, "rainfall": 49, "difficulty": "easy"},
	"California": {"temp": 75, "moisture": 55, "sunlight": 9.0, "rainfall": 20, "difficulty": "medium"},
	"Colorado": {"temp": 65, "moisture": 50, "sunlight": 8.5, "rainfall": 15, "difficulty": "medium"},
	"Connecticut": {"temp": 70, "moisture": 65, "sunlight": 7.5, "rainfall": 45, "difficulty": "easy"},
	"Delaware": {"temp": 75, "moisture": 70, "sunlight": 8.0, "rainfall": 44, "difficulty": "easy"},
	"Florida": {"temp": 88, "moisture": 80, "sunlight": 8.5, "rainfall": 54, "difficulty": "medium"},
	"Georgia": {"temp": 83, "moisture": 75, "sunlight": 8.5, "rainfall": 50, "difficulty": "easy"},
	"Hawaii": {"temp": 85, "moisture": 85, "sunlight": 8.0, "rainfall": 70, "difficulty": "easy"},
	"Idaho": {"temp": 60, "moisture": 45, "sunlight": 8.0, "rainfall": 12, "difficulty": "medium"},
	"Illinois": {"temp": 75, "moisture": 70, "sunlight": 7.5, "rainfall": 37, "difficulty": "easy"},
	"Indiana": {"temp": 75, "moisture": 70, "sunlight": 7.5, "rainfall": 40, "difficulty": "easy"},
	"Iowa": {"temp": 72, "moisture": 75, "sunlight": 7.5, "rainfall": 35, "difficulty": "easy"},
	"Kansas": {"temp": 78, "moisture": 65, "sunlight": 8.5, "rainfall": 28, "difficulty": "easy"},
	"Kentucky": {"temp": 75, "moisture": 70, "sunlight": 7.5, "rainfall": 46, "difficulty": "easy"},
	"Louisiana": {"temp": 85, "moisture": 80, "sunlight": 8.0, "rainfall": 60, "difficulty": "medium"},
	"Maine": {"temp": 60, "moisture": 60, "sunlight": 7.0, "rainfall": 42, "difficulty": "medium"},
	"Maryland": {"temp": 72, "moisture": 65, "sunlight": 7.5, "rainfall": 41, "difficulty": "easy"},
	"Massachusetts": {"temp": 68, "moisture": 65, "sunlight": 7.0, "rainfall": 44, "difficulty": "medium"},
	"Michigan": {"temp": 68, "moisture": 65, "sunlight": 7.0, "rainfall": 32, "difficulty": "medium"},
	"Minnesota": {"temp": 65, "moisture": 65, "sunlight": 7.5, "rainfall": 27, "difficulty": "medium"},
	"Mississippi": {"temp": 82, "moisture": 75, "sunlight": 8.0, "rainfall": 55, "difficulty": "easy"},
	"Missouri": {"temp": 75, "moisture": 70, "sunlight": 8.0, "rainfall": 40, "difficulty": "easy"},
	"Montana": {"temp": 58, "moisture": 45, "sunlight": 8.0, "rainfall": 14, "difficulty": "hard"},
	"Nebraska": {"temp": 72, "moisture": 65, "sunlight": 8.5, "rainfall": 23, "difficulty": "easy"},
	"Nevada": {"temp": 85, "moisture": 30, "sunlight": 9.5, "rainfall": 9, "difficulty": "hard"},
	"New Hampshire": {"temp": 65, "moisture": 60, "sunlight": 7.0, "rainfall": 42, "difficulty": "medium"},
	"New Jersey": {"temp": 72, "moisture": 65, "sunlight": 7.5, "rainfall": 44, "difficulty": "easy"},
	"New Mexico": {"temp": 80, "moisture": 40, "sunlight": 9.0, "rainfall": 14, "difficulty": "hard"},
	"New York": {"temp": 68, "moisture": 65, "sunlight": 7.0, "rainfall": 39, "difficulty": "medium"},
	"North Carolina": {"temp": 78, "moisture": 70, "sunlight": 8.0, "rainfall": 44, "difficulty": "easy"},
	"North Dakota": {"temp": 60, "moisture": 55, "sunlight": 8.0, "rainfall": 17, "difficulty": "medium"},
	"Ohio": {"temp": 72, "moisture": 70, "sunlight": 7.5, "rainfall": 39, "difficulty": "easy"},
	"Oklahoma": {"temp": 80, "moisture": 60, "sunlight": 8.5, "rainfall": 36, "difficulty": "medium"},
	"Oregon": {"temp": 65, "moisture": 55, "sunlight": 7.5, "rainfall": 36, "difficulty": "medium"},
	"Pennsylvania": {"temp": 70, "moisture": 65, "sunlight": 7.5, "rainfall": 42, "difficulty": "easy"},
	"Rhode Island": {"temp": 68, "moisture": 65, "sunlight": 7.0, "rainfall": 45, "difficulty": "medium"},
	"South Carolina": {"temp": 80, "moisture": 75, "sunlight": 8.5, "rainfall": 48, "difficulty": "easy"},
	"South Dakota": {"temp": 65, "moisture": 55, "sunlight": 8.0, "rainfall": 20, "difficulty": "medium"},
	"Tennessee": {"temp": 78, "moisture": 70, "sunlight": 8.0, "rainfall": 47, "difficulty": "easy"},
	"Texas": {"temp": 85, "moisture": 55, "sunlight": 9.0, "rainfall": 28, "difficulty": "medium"},
	"Utah": {"temp": 70, "moisture": 45, "sunlight": 8.5, "rainfall": 12, "difficulty": "medium"},
	"Vermont": {"temp": 62, "moisture": 60, "sunlight": 7.0, "rainfall": 41, "difficulty": "medium"},
	"Virginia": {"temp": 75, "moisture": 70, "sunlight": 8.0, "rainfall": 43, "difficulty": "easy"},
	"Washington": {"temp": 62, "moisture": 60, "sunlight": 7.5, "rainfall": 38, "difficulty": "medium"},
	"West Virginia": {"temp": 68, "moisture": 65, "sunlight": 7.5, "rainfall": 44, "difficulty": "medium"},
	"Wisconsin": {"temp": 65, "moisture": 65, "sunlight": 7.5, "rainfall": 32, "difficulty": "medium"},
	"Wyoming": {"temp": 55, "moisture": 40, "sunlight": 8.0, "rainfall": 13, "difficulty": "hard"}
}

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
	budget = 1000
	crops = { "corn" : 10, "wheat" : 10, "soy" : 10 }
	water = 10
	water_level = {}
	fertiliser = 10
	current_tool = "corn"

	game_time_elapsed = 0.0
	current_season = "spring"  
	
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
		"water_level": water_level,
		"fertiliser": fertiliser,
		"current_tool": current_tool,
		"play_time_seconds": (Time.get_ticks_msec() / 1000.0) - session_start_time,
		"total_crops_planted": total_crops_planted,
		"total_crops_harvested": total_crops_harvested,
		"total_money_earned": total_money_earned,
		"game_time_elapsed": game_time_elapsed,
		"current_season": current_season,
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
	
	save_game_resource.game_time_elapsed = game_time_elapsed
	save_game_resource.current_season = current_season
	
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
	
	game_time_elapsed = save_game_resource.game_time_elapsed if save_game_resource.has_method("get") and save_game_resource.get("game_time_elapsed") != null else 0.0
	current_season = save_game_resource.current_season if save_game_resource.has_method("get") and save_game_resource.get("current_season") != null else "spring"
	
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
	
	game_time_elapsed = save_data.get("game_time_elapsed", 0.0)
	current_season = save_data.get("current_season", "spring")

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
	total_crops_planted += 1

func track_crop_harvested(money_gained: int = 100):
	total_crops_harvested += 1
	total_money_earned += money_gained

func set_world_scene_reference(world_scene):
	current_world_scene = world_scene

func test_file_access():
	var test_path = "user://test_write.txt"
	var file = FileAccess.open(test_path, FileAccess.WRITE)
	if file:
		file.store_string("test")
		file.close()
		print("Write test successful")
		DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	else:
		print("Write test failed - cannot access user directory")

func _process(delta):
	"""Update game time and handle season transitions"""
	game_time_elapsed += delta
	
	if game_time_elapsed >= season_duration:
		advance_season()

func advance_season():
	"""Advance to the next growing season"""
	game_time_elapsed = 0.0
	if current_season == "spring":
		current_season = "fall"
	else:
		current_season = "spring"
	
	print("Season changed to: ", current_season)

func get_season_time_remaining() -> float:
	return season_duration - game_time_elapsed

func get_season_progress() -> float:
	return game_time_elapsed / season_duration

func format_time(seconds: float) -> String:
	var minutes = int(seconds / 60)
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func can_plant_crop(crop_name: String) -> bool:
	if crop_name == "corn":
		return current_season == "spring"  # Corn: April-September
	elif crop_name == "wheat":
		return current_season == "fall"    # Wheat: September-April
	else:
		return true  # Other crops can be planted anytime for now

func get_current_season_name() -> String:
	if current_season == "spring":
		return "Corn Season (Apr-Sep)"
	else:
		return "Wheat Season (Sep-Apr)"

func get_state_info(state_name: String) -> Dictionary:
	if state_data.has(state_name):
		return state_data[state_name]
	else:
		return {"temp": 70, "moisture": 60, "sunlight": 8.0, "rainfall": 35, "difficulty": "medium"}

func initialize_water_level(layer):
	print("initializing water")
	for cell_pos in layer.get_used_cells():
		var topsoil_data = layer.get_cell_tile_data(cell_pos)
		var topsoil_waterlevel = topsoil_data.get_custom_data("water_level")
		water_level[Vector2i(cell_pos)] = topsoil_waterlevel
	print("initializedd")
	print(water_level)
