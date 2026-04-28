extends StatusEffect
class_name BurnEffect

func _init():
	target_type = Effect.Target.ENEMY
	status_to_apply = BurnStatus.new()
