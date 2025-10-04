extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = str(Global.crops["corn"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = str(Global.crops["corn"])


func _on_button_buy_corn_pressed() -> void:
	if Global.budget > 0:
		Global.crops["corn"] += 10
		Global.budget -= 10
