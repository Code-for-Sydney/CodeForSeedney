extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = str(Global.corn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = str(Global.corn)


func _on_button_buy_corn_pressed() -> void:
	Global.corn += 10
	Global.budget -= 10
