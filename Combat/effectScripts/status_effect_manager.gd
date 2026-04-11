extends Resource
class_name StatusEffectManager

var active_effects: Dictionary = {}

func apply_effect(effect_name: String, stacks: int = 1):
	if active_effects.has(effect_name):
		active_effects[effect_name] = min(active_effects[effect_name] + stacks, 5)
	else:
		active_effects[effect_name] = stacks

func process_turn(entity: BattleEntity):
	for effect in active_effects.keys():
		match effect:
			"poison": entity.TakeDamage(5 * active_effects[effect])
			"bleed":  entity.TakeDamage(8 * active_effects[effect])
			"burn":   entity.TakeDamage(6 * active_effects[effect])
			"paralyzed": entity.skip_turn = true
