extends Status
class_name BurnInfusionStatus

func _init():
	status_name = "burn_infusion"

func modify_attack_effects(entity: BattleEntity, effects: Array[Effect]) -> Array[Effect]:
	var modified_effects = effects.duplicate()
	var burn_effect = BurnEffect.new()
	modified_effects.append(burn_effect)
	print("Burn Infusion adds Burn Effect to the attack!")
	return modified_effects
