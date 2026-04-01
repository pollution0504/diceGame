extends Node3D
class_name BattleEntity

var max_health := 100
var current_health := 0

var entity_name: String = ""
var level: int = 1
 
var max_mp: int = 40
var current_mp: int = 40
 
var attack: int = 10
var defense: int = 5
var agility: int = 10
var mana: int = 40
var luck: int = 5
 
var weapon: Dictionary = {}  # { "name": "Sword", "atk_bonus": 5 }
var armor: Dictionary = {}   # { "name": "Chestplate", "def_bonus": 3 }
var dice: Dictionary = {}    # { "sides": 20, "bonus": 0 }

var active := false
#var items := Array[Consumable]

# Called when the node enters the scene tree for the first time.
func RollDice() -> int:
	# look for sides, if not, return 20
	var sides = dice.get("sides", 20)
	var bonus = dice.get("bonus", 0)
	return randi() % sides + 1 + bonus

func Attack(target_entity : BattleEntity):
	pass
	
func TakeDamage(damage : int) -> int:
	if randi_range(0,100) < agility:
		print("dodge")
		return 0
	
	# check for buff. Apply buffs
	var real_defense = defense
	
	var damage_taken = max(damage - real_defense,0)
	current_health -= damage_taken
	if !is_alive():
		die()
	print("current health: ", current_health)
	return damage_taken
	

func is_alive() -> bool:
	return current_health > 0

func _ready():
	current_health = max_health
	
func die():
	print("dead")
	#play death animation
