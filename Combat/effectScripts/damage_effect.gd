extends Effect
class_name DamageEffect

@export var amount: int = 10
@export var use_dice_multiplier: bool = true

func _init():
	target_type = Effect.Target.ENEMY

func apply(source: BattleEntity, target: BattleEntity):
	var damage = amount
	if use_dice_multiplier and source.stats.dice:
		damage = source.stats.dice.get_damage_multiplier(source.current_dice_roll, amount)
	
	var damage_dealt = target.TakeDamage(damage)
	print(source.entity_name, " dealt ", damage_dealt, " damage to ", target.entity_name)
