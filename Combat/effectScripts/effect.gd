extends Resource
class_name Effect
## TARGET TYPE = WHO WILL GET HIT
enum Target { 
	SELF, ## Hits Self
	ENEMY, ## Hits Enemy
	ALL_ALLIES, ## Hits Ally Party
	ALL_ENEMIES, ## Hits Enemy Party
	ALLY ## Hits Ally
}
@export var target_type: Target = Target.ENEMY

func apply(source: BattleEntity, target: BattleEntity):
	pass
