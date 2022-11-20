extends Marker3D

@onready var player = owner
var player_pos

@export var delay : float = 0.2
@export  var y_axis = 0.8
@export  var x_axis = 0.5
@export  var z_axis = 0.5

var delayed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("delayChange", delayChange)
#	var tween = get_tree().create_tween().set_loops()
#	tween.tween_property(self, "position:y", owner.global_position.y + 0.2, 2).as_relative()
#	tween.tween_property(self, "position:y", owner.global_position.y + -0.2, 2).as_relative()
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	player_pos = Vector3(owner.back.global_position.x ,owner.back.global_position.y, owner.back.global_position.z)
	
	global_position = global_position.lerp(player_pos, delay)
	rotation = owner.body.rotation

func delayChange():
	delay = 0.9
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_property(self,"delay",0.2,0.1)
	
