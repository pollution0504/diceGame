extends Resource
class_name BattleStats

@export var level: int = 1

@export var max_health := 100
@export var max_mp: int = 40

@export var attack: int = 10
@export var defense: int = 5
@export var agility: int = 10
@export var luck: int = 5

@export var weapon: Dictionary = {}  # { "name": "Sword", "atk_bonus": 5 }
@export var armor: Dictionary = {}   # { "name": "Chestplate", "def_bonus": 3 }
@export var dice: Dice
