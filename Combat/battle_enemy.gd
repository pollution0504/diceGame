extends BattleEntity
class_name BattleEnemy

func Attack(target_entity : BattleEntity):
	pass

func choose_target(party: Array) -> BattleEntity:
	# makes an array that filter's out all of the dead party members
	var alive = party.filter(func(entity): return entity.is_alive())
	if alive.is_empty():
		return null
	# Return a random *alive* party member
	return alive[randi() % alive.size()]
