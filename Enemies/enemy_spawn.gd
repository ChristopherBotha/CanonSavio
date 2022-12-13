extends Marker3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.emit_signal("spawnEnemy",global_position)
	
