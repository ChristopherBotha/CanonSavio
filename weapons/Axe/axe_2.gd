extends CharacterBody3D

signal returned

var enemyPool = 0

@export var recall_curve: Curve
@export_flags_3d_physics var aim_collision_mask

@export var throw_force: float = 20.0
@export var spin_speed: float = 50.0
@export var recall_speed: float = 10.0

@onready var parent: Node3D = get_parent()

enum STATE {HELD, THROWN, LANDED, RECALLED}
var state: STATE = STATE.HELD

var player : CharacterBody3D

var enemyRicochetPool : Array = []
var ricochetPlease : bool = false

var enemy = null
@onready var shootCollider = null
var recall_start: Vector3
var recall_progress: float = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	SignalBus.connect("playerID", getPlayer)

	global_position = parent.global_position
	global_rotation = parent.global_rotation
	$Area3D2/CollisionShape3D.disabled = true


func _physics_process(delta: float):
	SignalBus.emit_signal("swordState", STATE.keys()[state]) ########  Debug
	
	_get_direction()
	
	if ricochetPlease == true and state != STATE.HELD:
		if enemyRicochetPool.front() != null and enemyPool != 0 and player.EX == true:
			state == STATE.THROWN
			ricochet()
		else:
			ricochetPlease = false
			recall()
	
	if state == STATE.THROWN || state == STATE.RECALLED:
		rotate_object_local(Vector3.RIGHT, deg_to_rad(spin_speed))
	
	if enemy != null:
		global_position = enemy.global_position
		global_rotation = enemy.global_rotation
	
	if state == STATE.HELD:
		$Area3D2/CollisionShape3D.disabled = true
		
	if state == STATE.THROWN:
		$Area3D2/CollisionShape3D.disabled = false
		if !is_on_floor():
			velocity.y -= gravity * delta * 0.2
		move_and_collide(velocity * delta)
		
	if state == STATE.RECALLED:
		recall_progress += recall_speed * delta
		
		if abs(global_position.distance_to(parent.global_position)) < 0.5:
#			owner.velocity = Vector3.ZERO
			$Area3D2/CollisionShape3D.disabled = false
			global_position = parent.global_position
			global_rotation = parent.global_rotation
			SignalBus.emit_signal("trauma", 2, 0.2 )
			
			player.catchAxe()
			state = STATE.HELD
			emit_signal("returned")
			if owner != null :
				if owner.sword_sheathed == false:
					owner._sheath_weapon()
			top_level = false
		else:
			var x = recall_curve.sample_baked(recall_progress / recall_start.distance_to(parent.global_position))
			var offset = player.transform.basis * Vector3(x, 0, 0)
			global_position = recall_start.move_toward(parent.global_position, recall_progress) + offset
			
	
func throw():
	if state == STATE.HELD:
		enemyPool = 4
		top_level = true
		var direction = _get_direction()
		transform = transform.looking_at(global_position + direction, Vector3.UP)
		velocity = direction * throw_force
		state = STATE.THROWN
		
func _get_direction():
	var viewport := get_viewport()
	var camera := viewport.get_camera_3d()
	var center: Vector2 = viewport.size/2
	var from: Vector3 = camera.project_ray_origin(center)
	var to: Vector3 = from + camera.project_ray_normal(center) * 1000
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	
	shootCollider = collision
#	print(shootCollider)
	
	if collision:
		return global_position.direction_to(collision.position)
	else:
		return global_position.direction_to(to)
	
func recall():
	if state == STATE.RECALLED:
		return
		
	recall_start = global_position
	recall_progress = 0.0
	state = STATE.RECALLED
	velocity = Vector3.ZERO


func _on_area_3d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if state == STATE.RECALLED:
		return
	velocity = Vector3.ZERO
	state = STATE.LANDED


func _on_area_3d_2_body_entered(body):
	if state == STATE.RECALLED:
		if body.has_method("hurt"):
			body.hurt(5000, -1, 0.1,0.01)
	
	elif body.is_in_group("Enemies"):
		velocity = Vector3.ZERO
		enemy = body
		state = STATE.LANDED
		body.hurt(5000, -1, 0.1,0.01)
		
		if body.health <= 0:
			SignalBus.emit_signal("hitStop", 0.1, 0.05)
			enemyPool -= 1
			if enemyRicochetPool.size() != 0 or state != STATE.RECALLED :
				ricochetPlease = true
				state = STATE.THROWN
			else:
				ricochetPlease = false
				recall()
				
	else:
		velocity = Vector3.ZERO
		state = STATE.LANDED


func _on_area_3d_2_body_exited(body):
	if body.is_in_group("Enemies"):
		enemy = null


func _on_ricochet_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		enemyRicochetPool.append(body)

func _on_ricochet_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		for i in enemyRicochetPool:
			if body == i:
				enemyRicochetPool.erase(i)
			else:
				print("no")

func ricochet():
	
	top_level = true
	rotate_object_local(Vector3.RIGHT, deg_to_rad(spin_speed))
	
	var directionRicochet = global_position.direction_to(enemyRicochetPool.front().global_position)
	transform = transform.looking_at(global_position + directionRicochet, Vector3.UP)
	velocity = directionRicochet * throw_force
	state = STATE.THROWN
	
func getPlayer(val):
	player = val
