extends BattleAlly
class_name BattlePlayer

const SWORD_SLICE = preload("res://SFX/SwordSlice.mp3")

@onready var voice_line = $VoiceLine
const PREPARE_YOURSELF = preload("res://SFX/PrepareYourself.wav")
const RUN = preload("res://SFX/hurt.sfx.wav")
const KICK = preload("res://SFX/kick.sfx.wav")

@export var health_bar : ProgressBar
@onready var dice_debugger = $HP/SubViewport/VBoxContainer/DiceDebugger

func _ready():
	super()
	health_bar.max_value = stats.max_health
	health_bar.value = current_health

func TakeDamage(damage: int) -> int:
	voice_line.stream = KICK
	voice_line.play()
	var result = super.TakeDamage(damage)
	health_bar.value = current_health      
	return result

const INTRO_OFFSET := Vector3(-8, 0, 0)
const INTRO_DURATION := 0.8

const JUMP_TAKEOFF_DISTANCE := 3.5
const IMPACT_OFFSET_DISTANCE := 0.8
const RUN_UP_DURATION := 0.3
const JUMP_DURATION := 0.5
const JUMP_HEIGHT := 2.0
const HOP_BACK_DURATION := 0.6
const HOP_BACK_HEIGHT := 1.0
const SWORD_SLICE_START_TIME := 0.17

func Attack(target_entity: BattleEntity, allies: Array = [], enemies: Array = []):
	if stats.dice != null and current_dice_roll != -1 and not stats.dice.can_attack(current_dice_roll):
		return
	await PlayAttackAnimation(target_entity)

func Heal(amount: int):
	super.Heal(amount)
	health_bar.value = current_health

func PlayIntroAnimation():
	var original_position = global_position
	global_position = original_position + INTRO_OFFSET
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", original_position, INTRO_DURATION) \
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
	var jump_start_pos = target_pos - (dir * JUMP_TAKEOFF_DISTANCE)
	jump_start_pos.y = ground_y

	# Impact point
	var impact_pos = target_pos - (dir * IMPACT_OFFSET_DISTANCE)
	impact_pos.y = ground_y

	var tween = get_tree().create_tween()

	# 1. RUN UP
	tween.tween_property(self, "global_position", jump_start_pos, RUN_UP_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 2. PROPER PARABOLIC JUMP
	var jump_arc = func(t: float):
		var pos = jump_start_pos.lerp(impact_pos, t)
		# Parabolic formula: y = -4h(t-0.5)^2 + h
		pos.y = ground_y + (-4 * JUMP_HEIGHT * pow(t - 0.5, 2) + JUMP_HEIGHT)
		global_position = pos

	tween.chain().tween_method(jump_arc, 0.0, 1.0, JUMP_DURATION)

	# 3. IMPACT (Trigger damage and sound)
	tween.tween_callback(func(): 
		voice_line.stream = SWORD_SLICE
		voice_line.play(SWORD_SLICE_START_TIME)
		print("Impact callback fired!")
		
		# Call base Attack to handle effect logic
		super.Attack(target_entity)
	)

	# 4. PARABOLIC HOP BACK
	var hop_arc = func(t: float):
		var pos = impact_pos.lerp(original_pos, t)
		pos.y = ground_y + (-4 * HOP_BACK_HEIGHT * pow(t - 0.5, 2) + HOP_BACK_HEIGHT)
		global_position = pos

	tween.chain().tween_method(hop_arc, 0.0, 1.0, HOP_BACK_DURATION)

	await tween.finished
	return null
	
func PlayRunAnimation():
	var original_position = global_position
	# move offscreen to the left 
	var run_target = original_position + INTRO_OFFSET
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", run_target, 0.6) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN)

	voice_line.stream = RUN
	voice_line.play()
	await tween.finished

func RollDice(allies: Array = [], enemies: Array = []):
	super(allies,enemies)
	dice_debugger.text = stats.dice.get_script().get_path().get_file().get_basename() + ": " + str(current_dice_roll)
