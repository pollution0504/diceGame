extends BattleEnemy
class_name BattleMinion

func Attack(target_entity : BattleEntity):
	await PlayAttackAnimation(target_entity)
	super(target_entity)
	
func PlayAttackAnimation(target_entity : BattleEntity):
	var original_position = global_position
	var target_position = target_entity.global_position
	var tween = get_tree().create_tween()
	
	var offset = (original_position - target_position).normalized() * 1.5
	var dash_to = target_position + offset
	
	tween.tween_property(self, "global_position", dash_to, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# We use two parallel tweens: one for horizontal, one for the vertical "hop"
	tween.tween_property(self, "global_position:y", global_position.y + 1.5, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "global_position:y", global_position.y, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# 3. Return to base
	tween.chain().tween_property(self, "global_position", original_position, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		
	# Wait for the whole sequence to finish
	await tween.finished
	return null

func die():
	super()
	hide()
