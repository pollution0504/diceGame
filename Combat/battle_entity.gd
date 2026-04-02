extends Node3D
class_name BattleEntity

@export var stats : BattleStats
@export var visual_component : Node3D

var entity_name: String = ""
 
var current_mp: int = 40
var current_health := 0





var active := false
#var items := Array[Consumable]

# Called when the node enters the scene tree for the first time.
func RollDice() -> int:
	# look for sides, if not, return 20
	var sides = stats.dice.get("sides", 20)
	var bonus = stats.dice.get("bonus", 0)
	return randi() % sides + 1 + bonus


func Attack(target_entity : BattleEntity):
	var damage_given : int = target_entity.TakeDamage(stats.attack)
	print("I hit enemy ", target_entity, " for ", damage_given)

	
func TakeDamage(damage : int) -> int:
	if randi_range(0,100) < stats.agility:
		print("dodge")
		return 0
	
	# check for buff. Apply buffs
	var real_defense = stats.defense
	
	var damage_taken = max(damage - real_defense,0)
	current_health -= damage_taken
	if !is_alive():
		die()
	print("current health: ", current_health)
	return damage_taken
	

func is_alive() -> bool:
	return current_health > 0

func _ready():
	current_health = stats.max_health
	
func die():
	print("dead")
	#play death animation
