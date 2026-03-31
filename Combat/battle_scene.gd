extends Node3D

#Battle Manager




var player : BattlePlayer
var ally : BattleAlly

var enemies : Array[BattleEnemy]




enum TURNS {ALLIES, ENEMIES}
var current_turn = TURNS.ALLIES


# Called when the node enters the scene tree for the first time.
func _ready():
	OnAttackDecision(null,10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func OnAttackDecision(source_entity : BattleEntity, attack_damage : int):
	var target_index = await GetTarget()
	print(target_index)
	
	


func GetTarget():
	await get_tree().create_timer(5.0).timeout
	return 3
	
