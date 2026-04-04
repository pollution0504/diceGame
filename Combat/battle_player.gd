extends BattleAlly
class_name BattlePlayer

const SWORD_SLICE = preload("uid://gcae02jhx2mt")

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
	var original_pos = global_position
	var target_pos = target_entity.global_position
	var ground_y = original_pos.y

	var dir = (target_pos - original_pos).normalized()
	# Takeoff point
	var jump_start_pos = target_pos - (dir * 3.5)
	jump_start_pos.y = ground_y

	# Impact point
	var impact_pos = target_pos - (dir * 0.8)
	impact_pos.y = ground_y

	var tween = get_tree().create_tween()

	# 1. RUN UP
	tween.tween_property(self, "global_position", jump_start_pos, 0.3)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 2. PROPER PARABOLIC JUMP
	var jump_height = 2.0
	var jump_arc = func(t: float):
		var pos = jump_start_pos.lerp(impact_pos, t)
		# Parabolic formula: y = -4h(t-0.5)^2 + h
		pos.y = ground_y + (-4 * jump_height * pow(t - 0.5, 2) + jump_height)
		global_position = pos

	tween.chain().tween_method(jump_arc, 0.0, 1.0, 0.5)

	# 3. IMPACT (Trigger damage and sound)
	tween.tween_callback(func(): 
		voice_line.stream = SWORD_SLICE
		voice_line.play(0.17)
		super.Attack(target_entity)
	)

	# 4. PARABOLIC HOP BACK
	var hop_height = 1.0
	var hop_arc = func(t: float):
		var pos = impact_pos.lerp(original_pos, t)
		pos.y = ground_y + (-4 * hop_height * pow(t - 0.5, 2) + hop_height)
		global_position = pos

	tween.chain().tween_method(hop_arc, 0.0, 1.0, 0.6)

	await tween.finished
	return null
