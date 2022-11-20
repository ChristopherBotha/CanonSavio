extends Camera3D

@onready var trauma : float = 0.0
var max_shake = 0.005

var player_pos 

@export var delay : float = 0.05
@export  var y_axis = 10
@export  var x_axis = 0
@export  var z_axis = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("trauma",traumas)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
#	player_pos = Vector3(owner.global_position.x + x_axis,owner.global_position.y + y_axis, owner.global_position.z + z_axis )
#	global_position = global_position.lerp(player_pos, delay)
	
	trauma = min(max(0, trauma - delta*2), 1)
	frustum_offset = Vector2((2*randf() - 1)*max_shake*trauma*trauma, (2*randf() - 1)*max_shake*trauma*trauma)
	


func traumas(val,timer):
	trauma = val
	await get_tree().create_timer(timer).timeout
	trauma = 0.0
