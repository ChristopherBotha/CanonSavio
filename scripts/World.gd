extends Node3D

var radius = 20
var angle 
var x 
var y 
var spwn 
var distance

@export_file("*.tscn") var level
@onready var player = preload("res://Player/Player.tscn")
@onready var enemy = preload("res://Enemies/enemy.tscn")

@onready var spawner = preload("res://Enemies/enemy_spawn.tscn")

var spawnEnemies : Array = []
var enemyPool = 20
var player1 : Object = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("spawnEnemy", spawnEnemy)
	
	if level:
		var currentLevel = load(level).instantiate()
		$Level.add_child(currentLevel)
		currentLevel.global_position = $Level.global_position
		
		var spawn = currentLevel.find_child("playerSpawn")
		player1 = player.instantiate()
		spawn.add_child(player1)
		player1.global_position = spawn.global_position
		
		var enemySpawner = currentLevel.find_child("enemySpawners")
		spawnEnemies = enemySpawner.get_children()
		var spanerTest = true
		
#		for i in spawnEnemies:
#			if i.get_children().size() <= 0 and enemyPool != 0:
#				var enemies = enemy.instantiate()
#				i.add_child(enemies)
#
				
		if spanerTest == true:
			for i in enemyPool:
				spwn = spawner.instantiate()
				enemySpawner.add_child(spwn)
				spawnRandom()
				spwn.global_position = Vector3(x,player1.global_position.y,y)
				enemyPool -= 1
			spanerTest = false
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.text = str(Engine.get_frames_per_second())
	SignalBus.emit_signal("playerID", player1)
	
	if player1 != null:
		get_tree().call_group("Enemies","player1",player1)
		get_tree().call_group("Enemies","update_target_location",player1.global_transform.origin)

func _on_re_spawn_pressed() -> void:
	if enemyPool == 0:
		enemyPool = 6
		
func spawnRandom():
	
	# Generate a random angle between 0 and 2 * pi
	angle = randf() * 2 * PI
	distance = radius * sqrt(randf())
	
	# Use the angle and radius to calculate the x and y coordinates of the point
	x = distance * cos(angle)
	y = distance * sin(angle)

func spawnEnemy(val):
	
	var enemies = enemy.instantiate()
	spwn.add_child(enemies)
	enemies.global_position = val
