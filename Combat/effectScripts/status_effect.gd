# WIP CLASS
extends Effect
class_name StatusEffect

var effect_name: String = ""
var stacks: int = 1

func _init():
	target = Effect.Target.ENEMY

func apply(attacker: BattleEntity, defender: BattleEntity):
	# Just registers with the manager, doesn't do damage itself
	defender.status_effects.apply_effect(effect_name, stacks)
	print("Applied ", effect_name, " x", stacks)
