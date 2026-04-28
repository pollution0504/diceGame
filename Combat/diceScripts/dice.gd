extends Resource
class_name Dice

var sides: int = 20
var has_nat20: bool = true
var blood_counter: int = 0  # for Bloodthirst

func roll() -> int:
	return randi_range(1, sides)


func can_attack(result: int) -> bool:
	return true  # default, all rolls allow attack

func roll_with_advantage() -> int:
	return maxi(roll(), roll())

func roll_with_disadvantage() -> int:
	return mini(roll(), roll())

func get_damage_multiplier(result: int, base_dmg: int) -> float:
	if result <= 1 and result >= 0:   return 0
	elif result <= 10: return base_dmg
	elif result <= 15: return base_dmg * 1.5
	elif result <= 19: return base_dmg * 2
	elif result == 20 : return base_dmg * 3
	# This is if you haven't rolled dice yet (dice_roll = -1)
	return 1

func get_effects(result: int) -> Array[Effect]:
	var dmg = DamageEffect.new()
	dmg.amount = 10 
	dmg.use_dice_multiplier = true
	return [dmg]

func get_effect(result: int) -> Dictionary:
	return { "type": "attack", "damage": get_damage_multiplier(result, 10) }
