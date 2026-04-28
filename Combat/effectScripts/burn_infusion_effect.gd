extends StatusEffect
class_name BurnInfusionEffect

func _init():
	target_type = Effect.Target.SELF
	status_to_apply = BurnInfusionStatus.new()
