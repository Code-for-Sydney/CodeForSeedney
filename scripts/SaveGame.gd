extends Resource
class_name SaveGame

@export var player_name: String = ""
@export var selected_state: String = ""
@export var game_start_time: String = ""
@export var save_date: String = ""
@export var play_time_seconds: float = 0.0

@export var budget: int = 1000
@export var crops: Dictionary = {"corn": 10, "wheat": 10, "soy": 10}
@export var water: int = 10
@export var fertiliser: int = 10
@export var current_tool: String = "corn"

@export var world_water_levels: Dictionary = {} 
@export var world_crops: Dictionary = {}

@export var total_crops_planted: int = 0
@export var total_crops_harvested: int = 0
@export var total_money_earned: int = 0

@export var game_time_elapsed: float = 0.0
@export var current_season: String = "spring"

func _init():
	save_date = Time.get_datetime_string_from_system()

func vector2i_to_string(pos: Vector2i) -> String:
	return str(pos.x) + "," + str(pos.y)

func string_to_vector2i(pos_string: String) -> Vector2i:
	var parts = pos_string.split(",")
	return Vector2i(int(parts[0]), int(parts[1]))

func save_world_state(water_levels: Dictionary, crop_data: Dictionary):
	"""Convert world state dictionaries to serializable format"""
	world_water_levels.clear()
	world_crops.clear()
	
	for pos in water_levels:
		var pos_string = vector2i_to_string(pos)
		world_water_levels[pos_string] = water_levels[pos]
	
	for pos in crop_data:
		var pos_string = vector2i_to_string(pos)
		world_crops[pos_string] = {
			"name": crop_data[pos]["name"],
			"duration": crop_data[pos]["duration"]
		}

func load_world_state() -> Dictionary:
	var water_levels = {}
	var crop_data = {}
	
	for pos_string in world_water_levels:
		var pos = string_to_vector2i(pos_string)
		water_levels[pos] = world_water_levels[pos_string]
	
	for pos_string in world_crops:
		var pos = string_to_vector2i(pos_string)
		crop_data[pos] = {
			"name": world_crops[pos_string]["name"],
			"duration": world_crops[pos_string]["duration"]
		}
	
	return {
		"water_levels": water_levels,
		"crop_data": crop_data
	}