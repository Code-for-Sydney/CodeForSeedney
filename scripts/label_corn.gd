extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = str(Global.crops["corn"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var corn_count = Global.crops["corn"]
	self.text = str(corn_count)
	
	# Change color to red when corn count reaches zero
	if corn_count <= 0:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE


func _on_button_buy_corn_pressed() -> void:
	if Global.budget > 0:
		Global.crops["corn"] += 10
		Global.budget -= 10
