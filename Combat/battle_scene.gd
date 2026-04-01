extends Node3D

#Battle Manager




var player : BattlePlayer
var ally : BattleAlly

var enemies : Array[BattleEnemy]


enum TURNS {ALLIES, ENEMIES}
var current_turn = TURNS.ALLIES

var turn_queue: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	StartBattle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Starts the Battle
func StartBattle():
	current_turn = TURNS.ALLIES
	AdvanceTurn()

# Goes to the next turn (allies -> enemies, vice-versa) using queues
func AdvanceTurn():
	# Refill the turn queue if empty
	if turn_queue.is_empty():
		if current_turn == TURNS.ALLIES:
			turn_queue = [player, ally]
		else:
			turn_queue = enemies.duplicate()
			
	var current_actor = turn_queue.pop_front()
	# Skip dead entities
	if not current_actor.is_alive():
		AdvanceTurn()
		return
	
	if current_actor is BattleEnemy:
		await EnemyTurn(current_actor)
	else:
		await AllyTurn(current_actor)

func AllyTurn(actor: BattleEntity):
	await OnAttackDecision(actor)
	
	# If queue is empty after this action, flip to enemies
	if turn_queue.is_empty():
		current_turn = TURNS.ENEMIES
		
	if not CheckBattleOver():
		AdvanceTurn()

func EnemyTurn(actor: BattleEnemy):
	# Enemy picks a target and attacks automatically
	var target = actor.choose_target([player, ally])
	if target:
		var result = actor.Attack(target)
		print(actor.entity_name + " attacked " + target.entity_name)
		print("Damage: " + str(result["damage"]))

	# If queue is empty after this action, flip to allies
	if turn_queue.is_empty():
		current_turn = TURNS.ALLIES

	if not CheckBattleOver():
		AdvanceTurn()

func OnAttackDecision(source_entity : BattleEntity):
	var target_index = await GetTarget()
	var target = enemies[target_index]
	# WIP attack
	source_entity.Attack(target)
		
		
func GetTarget():
	# WIP target
	await get_tree().create_timer(5.0).timeout
	return 3
	
func CheckBattleOver() -> bool:
	# AI put these lines for checking if all are dead... still trying to understand it lol
	var all_enemies_dead = enemies.all(func(e): return not e.is_alive())
	var all_allies_dead = not player.is_alive() and not ally.is_alive()
	
	if all_enemies_dead:
		# Do whatever
		return true
	if all_allies_dead:
		# Again, do whatever
		return true
	return false
	
	
	
	
	
	
