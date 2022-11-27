extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
#	SignalBus.connect("movePlatform",tweeingThemApples)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	pass

func tweeingThemApples():
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property($CSGCombiner3D2/CSGBox3D4, "position:y", 20, 2).as_relative()
	tween.tween_property($CSGCombiner3D2/CSGBox3D4, "position:y", -20, 2).as_relative()



func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
#		SignalBus.emit_signal("movePlatform")
		tweeingThemApples()

