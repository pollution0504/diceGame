extends Node3D
class_name BattleEntity

@export var stats : BattleStats
@export var visual_component : Node3D

var entity_name: String = ""

var current_dice_roll: int = -1
var dice_roll_turns_remaining: int = 0
const DICE_ROLL_DURATION: int = 3  # lasts x turns after rolling

var active_statuses: Array[Status] = []

var current_mp: int = 40
var current_health := 0

var active := false
var can_attack := true
var skip_turn := false

signal on_death(BattleEntity)
#var items := Array[Consumable]

func _ready():
	current_health = stats.max_health

func apply_status(new_status: Status):
	for status in active_statuses:
		if status.status_name == new_status.status_name:
			status.stacks += new_status.stacks
			# Potentially refresh duration
			status.duration = max(status.duration, new_status.duration)
			return
	
	active_statuses.append(new_status)

func process_turn():
	skip_turn = false
	
	# Create a duplicate list to iterate through while potentially 
	# removing items from the main list
	var current_statuses = active_statuses.duplicate()
	for status in current_statuses:
		status.on_turn_start(self)
		status.on_turn_end(self)
		
		if status.duration == 0:
			active_statuses.erase(status)
			print(entity_name, " lost status: ", status.status_name)
	
	if !is_alive():
		die()

func take_turn(allies: Array, enemies: Array):
	# Base implementation does nothing
	pass

func RollDice(allies: Array = [], enemies: Array = []):
	current_dice_roll = stats.dice.roll()
	dice_roll_turns_remaining = DICE_ROLL_DURATION
	
	# Apply self/ally effects immediately on roll
	if stats.dice != null:
		var effects: Array[Effect] = stats.dice.get_effects(current_dice_roll)
		var roll_effects = effects.filter(func(e): 
			return e.target_type == Effect.Target.SELF or e.target_type == Effect.Target.ALL_ALLIES
		)
		apply_effect_array(roll_effects, self, allies, enemies)


func Attack(target_entity: BattleEntity, allies: Array = [], enemies: Array = []):
	# If the entity hasn't rolled or has no dice, use base attack
	var effects: Array[Effect] = []
	
	if stats.dice == null or current_dice_roll == -1:
		var dmg = DamageEffect.new()
		dmg.amount = stats.attack
		dmg.use_dice_multiplier = false
		effects.append(dmg)
	else:
		if not stats.dice.can_attack(current_dice_roll):
			return
		effects = stats.dice.get_effects(current_dice_roll)
		if effects.is_empty():
			var dmg = DamageEffect.new()
			dmg.amount = stats.attack
			dmg.use_dice_multiplier = true
			effects.append(dmg)
	
	# Passives are applied here
	effects = _modify_attack_effects(effects)
	
	# Only apply enemy-targeted effects during the attack hit
	var attack_effects = effects.filter(func(e):
		return e.target_type == Effect.Target.ENEMY or e.target_type == Effect.Target.ALL_ENEMIES
	)
	
	apply_effect_array(attack_effects, target_entity, allies, enemies)

func _modify_attack_effects(effects: Array[Effect]) -> Array[Effect]:
	var modified_effects = effects.duplicate()
	
	for status in active_statuses:
		modified_effects = status.modify_attack_effects(self, modified_effects)
	
	return modified_effects

func apply_effect_array(effects: Array[Effect], target_entity: BattleEntity, allies: Array = [], enemies: Array = []):
	for effect in effects:
		match effect.target_type:
			Effect.Target.SELF:
				effect.apply(self, self)
			Effect.Target.ENEMY:
				effect.apply(self, target_entity)
			Effect.Target.ALL_ALLIES:
				for ally in allies:
					effect.apply(self, ally)
			Effect.Target.ALL_ENEMIES:
				for enemy in enemies:
					effect.apply(self, enemy)

func Heal(amount: int):
	current_health = min(current_health + amount, stats.max_health)


func TakeDamage(damage: int) -> int:
	if randi_range(0, 100) < stats.agility:
		print(entity_name, " dodged")
		return 0
	
	var real_defense = stats.defense
	var damage_taken = max(damage - real_defense, 0)
	current_health -= damage_taken
	
	if !is_alive():
		die()
	
	print(entity_name, " took ", damage_taken, " damage (", current_health, "/", stats.max_health, " HP)")
	PlayHitImpactTween()
	return damage_taken

	

func is_alive() -> bool:
	return current_health > 0

const HIT_FLASH_DURATION := 0.1
const HIT_FADE_DURATION := 0.2
const KNOCKBACK_DISTANCE := 0.3
const KNOCKBACK_DURATION := 0.05
const SETTLE_DURATION := 0.25

func die():
	print("dead")
	on_death.emit(self)
	#play death animation
	
func PlayHitImpactTween():
	var tween = get_tree().create_tween().set_parallel(true)
	
	# Keep track of where the sprite should be
	var original_pos = visual_component.position 
	
	# --- VISUAL FEEDBACK (Color) ---
	# Flash red quickly
	tween.tween_property(visual_component, "modulate", Color.RED, HIT_FLASH_DURATION)
	# Fade back to white, starting after HIT_FLASH_DURATION
	tween.chain().tween_property(visual_component, "modulate", Color.WHITE, HIT_FADE_DURATION)
	
	
	# --- PHYSICAL FEEDBACK (Position) ---
	# Calculate 'backwards' based on where the sprite is facing (local -z)
	var hit_pos = original_pos - (visual_component.transform.basis.z * KNOCKBACK_DISTANCE)
	
	# Jump back on impact
	tween.tween_property(visual_component, "position", hit_pos, KNOCKBACK_DURATION)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
	# Settle back to original position
	tween.chain().tween_property(visual_component, "position", original_pos, SETTLE_DURATION)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func PlayAttackAnimation(target_entity : BattleEntity):
	return null 

func PlayIntroAnimation():
	return null
