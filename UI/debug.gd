extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("speedUpdated", speed)
	SignalBus.connect("attackingUpdated", attacking)
	SignalBus.connect("swordState", swordState)
	SignalBus.connect("swordSheathedUpdated", seathed)
	SignalBus.connect("playerStateName", playerState)
	
	
func speed(val):
	$VBoxContainer2/SPeed.text = str(val)

func seathed(val):
	$VBoxContainer2/seatheState.text = str(val)

func attacking(val):
	$VBoxContainer2/Attacking.text = str(val)

func swordState(val):
	$VBoxContainer2/SwordState.text = str(val)

func playerState(val):
	$VBoxContainer2/State.text = str(val)

