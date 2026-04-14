extends Dice
class_name WoodenDie

func _init():
	has_nat20 = false

func can_attack(result: int) -> bool:
	print("can_attack called with: ", result)
	return result > 5


func get_effects(result: int) -> Array[Effect]:
	var effects : Array[Effect] = []
	
	if result >= 0 and result <= 5:
		var heal = HealEffect.new()
		heal.amount = 15
		effects.append(heal)
	elif result > 5:
		var dmg = DamageEffect.new()
		dmg.amount = 10 # Base damage
		dmg.use_dice_multiplier = true
		effects.append(dmg)
		
		if result == 20:
			var burn = BurnEffect.new()
			effects.append(burn)
	
	return effects
