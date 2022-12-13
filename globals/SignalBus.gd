extends Node

signal playerID(val)
#player changes
signal updatePlayerHealth(val)
signal updatePlayerMana(val)
signal healthUpdated(val)
#player upgrades / stats
signal updatePlayerMaxHealth(val)
signal updatePlayerDamage(val)
signal updatePlayerMaxMana(val)
#Game Machanics
signal updateExperience(val)
signal updateGold(val)
signal updateScore(val)
#world interaction
signal interact(val)
#Enemies
signal updateEnemiesDamage(val)
signal enemyCounter(val)
signal trauma(val,timer)
#moveplatform
signal movePlatform()
signal releaseVictim(val)

signal delayChange(val)
signal hitStop(val,time)
signal chainCollision(val)

signal exBarValue(val)
signal exTrue(val)

############debug
signal swordState(val)
signal speedUpdated(val)
signal sprintingUpdated(val)
signal swordSheathedUpdated(val)
signal playerStateName(val)
signal attackingUpdated(val)
signal exBarUpdated(val)

signal spawnEnemy(val)

