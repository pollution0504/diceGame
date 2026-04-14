extends Resource
class_name Status

@export var status_name: String = ""
@export var stacks: int = 1
@export var duration: int = 3 # Turns remaining, -1 for infinite

func on_turn_start(entity: BattleEntity):
	pass

func on_turn_end(entity: BattleEntity):
	if duration > 0:
		duration -= 1

func modify_attack_effects(entity: BattleEntity, effects: Array[Effect]) -> Array[Effect]:
	return effects

func on_damage_taken(entity: BattleEntity, damage: int):
	pass
