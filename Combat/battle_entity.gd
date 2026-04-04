extends Node3D
class_name BattleEntity

@export var stats : BattleStats
@export var visual_component : Node3D

var entity_name: String = ""
 
var current_mp: int = 40
var current_health := 0

var active := false

signal on_death(BattleEntity)
#var items := Array[Consumable]

# Called when the node enters the scene tree for the first time.
func RollDice() -> int:
	# look for sides, if not, return 20
	var sides = stats.dice.get("sides", 20)
	var bonus = stats.dice.get("bonus", 0)
	return randi() % sides + 1 + bonus


func Attack(target_entity : BattleEntity):
	var damage_given : int = target_entity.TakeDamage(stats.attack)
	print("I hit enemy ", target_entity, " for ", damage_given)

	
func TakeDamage(damage : int) -> int:
	if randi_range(0,100) < stats.agility:
		print("dodge")
		return 0
	
	# check for buff. Apply buffs
	var real_defense = stats.defense
	
	var damage_taken = max(damage - real_defense,0)
	current_health -= damage_taken
	if !is_alive():
		die()
	print("current health: ", current_health)
	PlayHitImpactTween()
	return damage_taken
	

func is_alive() -> bool:
	return current_health > 0

func _ready():
	current_health = stats.max_health
	print("Yo ", current_health)
	
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
	tween.tween_property(visual_component, "modulate", Color.RED, 0.1)
	# Fade back to white, starting after 0.1s
	tween.chain().tween_property(visual_component, "modulate", Color.WHITE, 0.2)
	
	
	# --- PHYSICAL FEEDBACK (Position) ---
	# Calculate 'backwards' based on where the sprite is facing (local -z)
	var knockback_distance = 0.3
	var hit_pos = original_pos - (visual_component.transform.basis.z * knockback_distance)
	
	# Jump back on impact
	tween.tween_property(visual_component, "position", hit_pos, 0.05)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
	# Settle back to original position
	tween.chain().tween_property(visual_component, "position", original_pos, 0.25)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func PlayAttackAnimation(target_entity : BattleEntity):
	return null 
