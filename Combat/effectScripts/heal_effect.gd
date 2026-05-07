extends Effect
class_name HealEffect

@export var amount: int = 0
@export var use_percentage: bool = false  # if true, heals % of max health instead of flat

func _init():
	target_type = Effect.Target.SELF

func apply(source: BattleEntity, target: BattleEntity):
	var heal_target = target if target else source
	var heal_amount = 0
	
	if use_percentage:
		heal_amount = int(heal_target.stats.max_health * amount / 100.0)
	else:
		heal_amount = amount
	
	heal_target.Heal(heal_amount)
	print(heal_target.entity_name, " healed ", heal_amount, " HP! Current HP: ", heal_target.current_health)
