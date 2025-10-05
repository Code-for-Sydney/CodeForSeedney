extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = str(Global.water)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var water_count = Global.water
	self.text = str(water_count)
	
	# Change color to red when water count reaches zero
	if water_count <= 0:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE


func _on_button_buy_water_pressed() -> void:
	if Global.budget > 0:
		Global.water += 10
		Global.budget -= 10
