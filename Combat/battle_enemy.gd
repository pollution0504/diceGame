extends BattleEntity
class_name BattleEnemy

func take_turn(allies: Array, enemies: Array):
	print(entity_name, " turn")
	# Small pause for "thinking" moved to BattleScene if needed, or here.
	# For now, let's keep it here to make it independent.
	await get_tree().create_timer(1.0).timeout 
	
	var target = choose_target(allies)
	if target:
		await UseAttack(target)
		print("ouch")

func choose_target(party: Array) -> BattleEntity:
	# makes an array that filter's out all of the dead party members
	var alive = party
	if alive.is_empty():
		return null
	# Return a random *alive* party member
	return alive[randi() % alive.size()]
	
func TakeDamage(damage: int) -> int:
	return super.TakeDamage(damage)
	
