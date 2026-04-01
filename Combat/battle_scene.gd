extends Node3D

#Battle Manager

const COMBAT_MENU = preload("uid://dgjar6b8g0n50")



@export var player : BattlePlayer
var ally : BattleAlly
var player_menu : CombatMenu

@export var enemies : Array[BattleEnemy]


enum TURNS {ALLIES, ENEMIES}
var current_turn = TURNS.ALLIES

var turn_queue: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	InstantiateEntities()
	StartBattle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func InstantiateEntities():
	var cm : CombatMenu = COMBAT_MENU.instantiate()
	add_child(cm)
	cm.entity = player
	player_menu = cm
	player_menu.attack_pressed.connect(Callable(self,"OnAttackDecision"))
	
# Starts the Battle
func StartBattle():
	current_turn = TURNS.ALLIES
	AdvanceTurn()

# Goes to the next turn (allies -> enemies, vice-versa) using queues
func AdvanceTurn():
	# If queue is empty after this action, flip to enemies
	if turn_queue.is_empty():
		if current_turn == TURNS.ALLIES:
			turn_queue = [player]
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
	actor.active = true
	player_menu.show()

	


func EnemyTurn(actor: BattleEnemy):
	# Enemy picks a target and attacks automatically
	var target = actor.choose_target([player])
	if target:
		var result = actor.Attack(target)

	# If queue is empty after this action, flip to allies
	if turn_queue.is_empty():
		current_turn = TURNS.ALLIES

	if not CheckBattleOver():
		AdvanceTurn()

func OnAttackDecision(source_entity : BattleEntity):
	var target_index = GetTarget()
	var target = enemies[target_index]
	# WIP attack
	source_entity.Attack(target)
	if not CheckBattleOver():
		AdvanceTurn()
		
func GetTarget():
	# WIP target
	return 0
	
func CheckBattleOver() -> bool:
	# AI put these lines for checking if all are dead... still trying to understand it lol
	var all_enemies_dead = true
	for e : BattleEntity in enemies:
		if e.is_alive():
			all_enemies_dead = false
		
	var all_allies_dead = false



	
	if all_enemies_dead:
		# Do whatever
		return true
	if all_allies_dead:
		# Again, do whatever
		return true
	return false
	
	
	
	
	
	
