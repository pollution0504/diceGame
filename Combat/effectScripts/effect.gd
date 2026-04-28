extends Resource
class_name Effect

enum Target { SELF, ENEMY, ALL_ALLIES, ALL_ENEMIES }
@export var target_type: Target = Target.ENEMY

func apply(source: BattleEntity, target: BattleEntity):
	pass
