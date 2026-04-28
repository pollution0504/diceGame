extends Status
class_name BurnStatus

func _init():
	status_name = "burn"

func on_turn_start(entity: BattleEntity):
	var damage = 6 * stacks
	entity.TakeDamage(damage)
	print(entity.entity_name, " burned for ", damage)
