extends Effect
class_name AttackEffect

func _init():
	target_type = Effect.Target.ENEMY

func apply(source: BattleEntity, target: BattleEntity):
	var damage = source.stats.dice.get_damage_multiplier(source.current_dice_roll, source.stats.attack)
	target.TakeDamage(damage)
