extends Control

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var import_button: Button = $VBoxContainer/ImportButton
@onready var delete_save_button: Button = $VBoxContainer/DeleteSaveButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

@onready var new_game_panel: Panel = $NewGamePanel
@onready var import_panel: Panel = $ImportPanel
@onready var player_name_input: LineEdit = $NewGamePanel/VBoxContainer/PlayerNameInput
@onready var state_dropdown: OptionButton = $NewGamePanel/VBoxContainer/StateDropdown
@onready var state_info_label: RichTextLabel = $NewGamePanel/VBoxContainer/StateInfoLabel
@onready var start_game_button: Button = $NewGamePanel/VBoxContainer/ButtonContainer/StartGameButton
@onready var back_button: Button = $NewGamePanel/VBoxContainer/ButtonContainer/BackButton

@onready var import_code_input: TextEdit = $ImportPanel/VBoxContainer/ImportCodeInput
@onready var import_load_button: Button = $ImportPanel/VBoxContainer/ImportButtonContainer/ImportLoadButton
@onready var import_back_button: Button = $ImportPanel/VBoxContainer/ImportButtonContainer/ImportBackButton

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var save_info_label: Label = $VBoxContainer/SaveInfoLabel

func _ready():
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if import_button:
		import_button.pressed.connect(_on_import_pressed)
	if delete_save_button:
		delete_save_button.pressed.connect(_on_delete_save_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if start_game_button:
		start_game_button.pressed.connect(_on_start_game_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if import_load_button:
		import_load_button.pressed.connect(_on_import_load_pressed)
	if import_back_button:
		import_back_button.pressed.connect(_on_import_back_pressed)
	
	$background_audio.pitch_scale = randf_range(0.9, 1.1)
	$background_audio.play()
	
	setup_state_dropdown()
	
	setup_save_info()
	
	if new_game_panel:
		new_game_panel.visible = false
	if import_panel:
		import_panel.visible = false
	
	if player_name_input:
		player_name_input.placeholder_text = "Enter your name"

func setup_save_info():
	"""Setup save file information display and continue button state"""
	var has_save = Global.has_save_file()
	
	if continue_button:
		continue_button.disabled = not has_save
		
	if delete_save_button:
		delete_save_button.disabled = not has_save
	
	if save_info_label:
		if has_save:
			var save_info = Global.get_save_file_info()
			if save_info.size() > 0:
				var play_time_float = float(save_info.play_time_seconds)
				var play_hours = int(play_time_float / 3600.0)
				var play_minutes = int(fmod(play_time_float, 3600.0) / 60.0)
				var time_text = ""
				if play_hours > 0:
					time_text = str(play_hours) + "h " + str(play_minutes) + "m"
				else:
					time_text = str(play_minutes) + "m"
				
				save_info_label.text = "Last Save: %s (%s)\nBudget: $%s | Planted: %s | Harvested: %s\nState: %s" % [
					str(save_info.player_name),
					str(time_text),
					str(save_info.budget),
					str(save_info.total_crops_planted),
					str(save_info.total_crops_harvested),
					str(save_info.selected_state)
				]
				save_info_label.visible = true
			else:
				save_info_label.visible = false
		else:
			save_info_label.text = "No saved games found"
			save_info_label.visible = true

func setup_state_dropdown():
	"""Populate the state dropdown with US states"""
	if not state_dropdown:
		return
		
	state_dropdown.clear()
	for state in Global.us_states:
		state_dropdown.add_item(state)
	
	var default_index = Global.us_states.find("Kansas")
	if default_index != -1:
		state_dropdown.selected = default_index
	
	if not state_dropdown.item_selected.is_connected(_on_state_selected):
		state_dropdown.item_selected.connect(_on_state_selected)
	
	update_state_info()

func _on_new_game_pressed():
	"""Show the new game setup panel"""
	if new_game_panel:
		new_game_panel.visible = true
	if player_name_input:
		player_name_input.grab_focus()
	update_state_info()

func _on_state_selected(index: int):
	"""Called when a state is selected from the dropdown"""
	update_state_info()

func update_state_info():
	"""Update the state information display"""
	if not state_dropdown or not state_info_label:
		return
	
	if state_dropdown.selected >= 0:
		var selected_state = Global.us_states[state_dropdown.selected]
		var state_info = Global.get_state_info(selected_state)
		
		var difficulty_color = ""
		match state_info.difficulty:
			"easy": difficulty_color = "[color=green]"
			"medium": difficulty_color = "[color=orange]"
			"hard": difficulty_color = "[color=red]"
		
		var info_text = """[center]Temperature: %d°F | Moisture: %d%%
Sunlight: %.1fh | Rainfall: %d"
Difficulty: %s%s[/color][/center]""" % [
			state_info.temp,
			state_info.moisture,
			state_info.sunlight,
			state_info.rainfall,
			difficulty_color,
			state_info.difficulty.capitalize()
		]
		
		state_info_label.text = info_text

func _on_continue_pressed():
	"""Load existing save and start the game"""
	if Global.load_game():
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	else:
		if continue_button:
			continue_button.disabled = true
		push_error("Failed to load save file")

func _on_quit_pressed():
	"""Quit the application"""
	get_tree().quit()

func _on_delete_save_pressed():
	"""Delete the current save file"""
	Global.delete_save_file()
	setup_save_info()
	print("Save file deleted")

func _on_start_game_pressed():
	"""Start a new game with the provided player data"""
	if not player_name_input or not state_dropdown:
		show_error("UI elements not properly initialized!")
		return
		
	var player_name = player_name_input.text.strip_edges()
	
	if player_name.length() == 0:
		show_error("Please enter your name!")
		return
	
	if player_name.length() < 2:
		show_error("Name must be at least 2 characters long!")
		return
	
	var selected_state = Global.us_states[state_dropdown.selected]
	
	Global.start_new_game(player_name, selected_state)
	
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_back_pressed():
	"""Return to main menu from new game setup"""
	if new_game_panel:
		new_game_panel.visible = false
	if player_name_input:
		player_name_input.text = ""

func _on_import_pressed():
	"""Show the import panel"""
	if import_panel:
		import_panel.visible = true
	if import_code_input:
		import_code_input.grab_focus()

func _on_import_back_pressed():
	"""Return to main menu from import panel"""
	if import_panel:
		import_panel.visible = false
	if import_code_input:
		import_code_input.text = ""

func _on_import_load_pressed():
	"""Load game from import code"""
	if not import_code_input:
		show_error("Import input not available!")
		return
	
	var import_code = import_code_input.text.strip_edges()
	
	if import_code.length() == 0:
		show_error("Please enter an import code!")
		return
	
	if Global.import_game_state(import_code):
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	else:
		show_error("Invalid import code! Please check the code and try again.")

func show_error(message: String):
	"""Display an error message to the user"""
	push_error(message)

func _input(event):
	"""Handle keyboard input"""
	if event is InputEventKey and event.pressed:
		if new_game_panel and new_game_panel.visible and event.keycode == KEY_ENTER:
			_on_start_game_pressed()
		elif new_game_panel and new_game_panel.visible and event.keycode == KEY_ESCAPE:
			_on_back_pressed()
		elif import_panel and import_panel.visible and event.keycode == KEY_ESCAPE:
			_on_import_back_pressed()
