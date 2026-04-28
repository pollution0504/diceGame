extends Effect
class_name DamageEffect

@export var base_damage: int = 10
@export var attack_scaling: float = 1.0
@export var defense_scaling: float = 0.0
@export var agility_scaling: float = 0.0
@export var magic_scaling: float = 0.0
@export var luck_scaling: float = 0.0

@export var mana_cost : int = 20

@export var multiplicitive : bool = false
@export var use_dice_multiplier: bool = true

func _init():
	target_type = Effect.Target.ENEMY

func apply(source: BattleEntity, target: BattleEntity):
	var damage = base_damage
	if use_dice_multiplier and source.stats.dice:
		damage = source.stats.dice.get_damage_multiplier(source.current_dice_roll, damage)
	if multiplicitive:
		damage = damage * _get_stat_mult(source.stats)
	else:
		damage = damage + _get_stat_add(source.stats)
	
	var damage_dealt = target.TakeDamage(damage)
	print(source.entity_name, " dealt ", damage_dealt, " damage to ", target.entity_name)

func _get_stat_mult(stats : BattleStats) -> float:
	var mult : float = 1.0
	if attack_scaling != 0:
		mult *= attack_scaling * stats.attack
	if defense_scaling != 0:
		mult *= defense_scaling * stats.defense
	if agility_scaling != 0:
		mult *= agility_scaling * stats.agility
	if magic_scaling != 0:
		mult *= magic_scaling * stats.magic
	if luck_scaling != 0:
		mult *= luck_scaling * stats.luck
		
	return mult

func _get_stat_add(stats : BattleStats) -> float:
	var damage_add = attack_scaling * stats.attack +\
	defense_scaling * stats.defense +\
	agility_scaling * stats.agility +\
	magic_scaling * stats.magic +\
	luck_scaling * stats.luck
		
	return int(damage_add)
