extends BattleEntity
class_name BattleAlly
signal turn_ended

var combat_menu : CombatMenu

func take_turn(allies: Array, enemies: Array):
	# Tick down roll duration
	if dice_roll_turns_remaining > 0:
		dice_roll_turns_remaining -= 1
		print(entity_name, " Roll expires in ", dice_roll_turns_remaining, " turns")
		if dice_roll_turns_remaining == 0:
			current_dice_roll = -1
			#if combat_menu:
				#combat_menu.update_button(2) # Ungrey out the Dice
			print(entity_name, " Roll expired!")
	
	print(entity_name, " turn")
	if combat_menu:
		var cam = get_viewport().get_camera_3d()
		var screen_pos = cam.unproject_position(global_position)
		combat_menu.position = screen_pos + Vector2(150, 0)
		combat_menu.open()
	
	await turn_ended
