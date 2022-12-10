@tool
extends Node3D

@onready var player = owner
var player_pos
@onready var tip = $"../Body/cherry/Armature/Skeleton3D/Marker3D"
@export var delay : float = 0.2
@export  var y_axis = 0.8
@export  var x_axis = 0.5
@export  var z_axis = 0.5

var delayed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	top_level = true
	SignalBus.connect("delayChange", delayChange)
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	player_pos = Vector3(tip.global_position.x ,tip.global_position.y, tip.global_position.z)
	
	global_position = global_position.lerp(player_pos, 0.05)
	rotation = owner.body.rotation

func delayChange():
	delay = 0.9
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_property(self,"delay",0.2,0.1)
