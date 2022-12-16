extends Player

# Combo counter
var combo_count = 0
var rank

# Enum to represent ranks
enum Rank{
	F = 0,
	D = 1,
	C = 2,
	B = 3,
	A = 4,
	S = 5,
	SS = 6,}

# Function called when the player successfully lands an attack
func attack_landed():
	# Increment combo counter
	combo_count += 1
	# Determine rank based on combo count
	if combo_count <= 6:
		rank = Rank.keys()[combo_count]
	else:
		rank = Rank.keys()[6]
	SignalBus.emit_signal("comboRankCount", rank, combo_count)

# Function called when the player takes damage
func player_damaged():
	# Reset combo counter
	combo_count = 0
	rank = Rank.keys()[combo_count]
	
	SignalBus.emit_signal("comboRankCount", rank, combo_count)
	
	
# Function called when the player lands a combo finisher move
func combo_timeout():
	# Reset combo counter
	combo_count = 0
	rank = Rank.keys()[combo_count]
	
	SignalBus.emit_signal("comboRankCount", rank, combo_count)
	
# signals to trigger events coming from player  
func _on_player_player_hurt() -> void:
	player_damaged()


func _ready()-> void:
	print(Rank.keys()[0])
	SignalBus.connect("attackLanded", attack_landed)
	SignalBus.connect("player_damaged", player_damaged)
	SignalBus.connect("comboTimeout", combo_timeout)
