extends Resource
class_name Skill
# TARGET TYPE = WHO YOU CAN CHOOSE FROM
enum TargetType { 
	ENEMY, ## Choose a single enemy from enemies
	ALLY, ## Choose a single ally from party
	SELF, ## Choose yourself only
	ALLIES, ## Choose all allies
	ENEMIES, ## Choose all enemies
	ALL, ## Choose from everyone
	NONE ## Don't get to choose
}

@export var name : String = "Default"
@export var effects : Array[Effect]

@export var animation : String = ""
@export var distance_from_enemy : float = 2.0

@export var target_type: TargetType

# wip
@export var soundEffect: AudioStream
