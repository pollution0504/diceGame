extends Resource
class_name Effect

enum Target { SELF, ENEMY }
var target: Target = Target.ENEMY

func apply(attacker: BattleEntity, defender: BattleEntity):
	pass
