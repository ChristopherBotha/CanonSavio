extends Control

@onready var healthBar = $ProgressBar
@onready var exBar = $exBar

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("healthUpdated", updatehealth)
	SignalBus.connect("exBarValue", updateExBar)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updatehealth(val):
	healthBar.value = val

func updateExBar(val):
	exBar.value = val
