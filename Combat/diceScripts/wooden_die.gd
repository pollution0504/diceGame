extends Dice
class_name WoodenDie

func _init():
	has_nat20 = false

func can_attack(result: int) -> bool:
	print("can_attack called with: ", result)
	return result > 5


func get_effects(result: int) -> Array[Effect]:
	if result >= 0 and result <= 5:
		var heal = HealEffect.new()
		heal.amount = 15
		return [heal]
	
	return []
