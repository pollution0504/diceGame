extends BattleEntity
class_name BattleEnemy


func choose_target(party: Array) -> BattleEntity:
	# makes an array that filter's out all of the dead party members
	var alive = party
	if alive.is_empty():
		return null
	# Return a random *alive* party member
	return alive[randi() % alive.size()]
	
func TakeDamage(damage: int) -> int:
	return super.TakeDamage(damage)
	
