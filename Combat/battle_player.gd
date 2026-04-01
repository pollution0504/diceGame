extends BattleAlly
class_name BattlePlayer

func Attack(target_entity : BattleEntity):
	var damage_given : int = target_entity.TakeDamage(attack)
	print("I DID THIS:")
	print(damage_given)
