extends Node3D
class_name BattleEntity

@export var stats : BattleStats
@export var visual_component : Node3D

var entity_name: String = ""

var current_dice_roll: int = -1
var dice_roll_turns_remaining: int = 0
const DICE_ROLL_DURATION: int = 3  # lasts x turns after rolling

var status_effects: StatusEffectManager = StatusEffectManager.new()

var current_mp: int = 40
var current_health := 0

var active := false
var can_attack := true

signal on_death(BattleEntity)
#var items := Array[Consumable]

# Called when the node enters the scene tree for the first time.
func RollDice():
	current_dice_roll = stats.dice.roll()


func Attack(target_entity: BattleEntity):
	if stats.dice == null or current_dice_roll == -1:
		target_entity.TakeDamage(stats.attack)
		return
	
	if not stats.dice.can_attack(current_dice_roll):
		return
	
	# Deal damage using dice multiplier
	var damage = stats.dice.get_damage_multiplier(current_dice_roll, stats.attack)
	var damage_given = target_entity.TakeDamage(damage)
	print(entity_name, " dealt ", damage_given, " damage")
	
	# Apply enemy effects (bleed, poison, etc)
	var effects: Array[Effect] = stats.dice.get_effects(current_dice_roll)
	for effect in effects:
		if effect.target == Effect.Target.ENEMY:
			effect.apply(self, target_entity)

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

func _ready():
	current_health = stats.max_health
	
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
