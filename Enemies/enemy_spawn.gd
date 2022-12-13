extends Marker3D
@onready var enemy = preload("res://Enemies/enemy.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var enemies = enemy.instantiate()
	add_child(enemies)

