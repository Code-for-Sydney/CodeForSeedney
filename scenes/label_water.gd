extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = str(Global.water)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = str(Global.water)


func _on_button_buy_water_pressed() -> void:
	if Global.budget > 0:
		Global.water += 10
		Global.budget -= 10
