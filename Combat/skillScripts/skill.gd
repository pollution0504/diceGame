extends Resource
class_name Skill
enum TargetType { ENEMY, ALLY, SELF, ALLIES, ENEMIES, ALL }

@export var name : String = "Default"
@export var effects : Array[Effect]

@export var animation : String = ""
@export var distance_from_enemy : float = 2.0

@export var target_type: TargetType

# wip
@export var soundEffect: AudioStream
