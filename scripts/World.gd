extends Node3D

@export_file("*.tscn") var level
@onready var player = preload("res://Player/Player.tscn")
@onready var enemy = preload("res://Enemies/enemy.tscn")

var spawnEnemies : Array = []
var enemyPool = 6
var player1 : Object = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

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
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.text = str(Engine.get_frames_per_second())
	
	for i in spawnEnemies:
		if i.get_children().size() <= 0 and enemyPool != 0:
			var enemies = enemy.instantiate()
			i.add_child(enemies)
			enemyPool -= 1
			
	SignalBus.emit_signal("playerID", player1)
	
	if player1 != null:
		get_tree().call_group("Enemies","playerPos",player1)

func _on_re_spawn_pressed() -> void:
	if enemyPool == 0:
		enemyPool = 6
