extends Effect
class_name HealEffect

var amount: int = 0
var use_percentage: bool = false  # if true, heals % of max health instead of flat

func _init():
	target = Effect.Target.SELF

func apply(attacker: BattleEntity, defender: BattleEntity = null):
	var heal_amount = 0
	
	if use_percentage:
		heal_amount = int(attacker.stats.max_health * amount / 100.0)
	else:
		heal_amount = amount
	
	attacker.Heal(heal_amount)
	print("Healed ", heal_amount, " HP! Current HP: ", attacker.current_health)
