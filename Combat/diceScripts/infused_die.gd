extends Dice
class_name InfusedDie

func get_effects(result: int) -> Array[Effect]:
	var effects : Array[Effect] = []
	
	# Base damage effect
	var dmg = DamageEffect.new()
	dmg.amount = 10 
	dmg.use_dice_multiplier = true
	effects.append(dmg)
	
	# If roll > 10, apply Burn Infusion to all allies
	if result > 10:
		var infusion = BurnInfusionEffect.new()
		infusion.target_type = Effect.Target.ALL_ALLIES
		effects.append(infusion)
		print("Roll > 10! Applying Burn Infusion to all allies!")
	
	return effects
