extends Effect
class_name AttackEffect

func _init():
	target = Effect.Target.ENEMY

func apply(attacker: BattleEntity, defender: BattleEntity):
	var damage = attacker.stats.dice.get_damage_multiplier(attacker.current_dice_roll, attacker.stats.attack)
	defender.TakeDamage(damage)
