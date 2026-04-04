extends BattleAlly
class_name BattlePlayer

const sword_slice = preload("uid://gcae02jhx2mt")
@onready var voice_line = $VoiceLine
const PREPARE_YOURSELF = preload("uid://d2obg761t54y7")

@export var health_bar : ProgressBar

func _ready():
	super()
	print("max health: ", stats.max_health)
	print("current health: ", current_health)
	health_bar.max_value = stats.max_health
	health_bar.value = current_health
	print("bar percent-ish value: ", health_bar.value, "/", health_bar.max_value)

func TakeDamage(damage : int) -> int:
	var dmg = super(damage)
	health_bar.value = current_health
	return dmg

func Attack(target_entity : BattleEntity):
	await PlayAttackAnimation(target_entity)
	super(target_entity)
	
func PlayIntroAnimation():
	var original_position = global_position
	global_position = original_position + Vector3(-8, 0, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", original_position, 0.8) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)
	voice_line.stream = PREPARE_YOURSELF
	voice_line.play()
	await tween.finished
	
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
