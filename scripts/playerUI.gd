extends Control

@onready var healthBar = $ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("healthUpdated", updatehealth)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updatehealth(val):
	healthBar.value = val
