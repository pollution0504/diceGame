extends Node3D
class_name BattleEntity

var health_max := 10
var health_current := 0
 
#var items := Array[Consumable]

# Called when the node enters the scene tree for the first time.
func _ready():
	health_current = health_max
