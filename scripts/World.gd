extends Node3D

@export_file("*.tscn") var level
@onready var player = preload("res://Player/Player.tscn")
@onready var enemy = preload("res://Enemies/enemy.tscn")

var spawnEnemies = []

# Called when the node enters the scene tree for the first time.
func _ready():

	if level:
		var currentLevel = load(level).instantiate()
		$Level.add_child(currentLevel)
		currentLevel.global_position = $Level.global_position
		
		var spawn = currentLevel.find_child("playerSpawn")
		var player1 = player.instantiate()
		spawn.add_child(player1)
		player1.global_position = spawn.global_position
		
		var enemySpawner = currentLevel.find_child("enemySpawners")
		spawnEnemies = enemySpawner.get_children()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	for i in spawnEnemies:
		if i.get_children().size() <= 0 :
			var enemies = enemy.instantiate()
			i.add_child(enemies)
		
	pass
