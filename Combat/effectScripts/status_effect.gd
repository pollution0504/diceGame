# WIP CLASS
extends Effect
class_name StatusEffect

@export var status_to_apply: Status
var stacks: int = 1

func _init():
	target_type = Effect.Target.ENEMY

func apply(source: BattleEntity, target: BattleEntity):
	if status_to_apply:
		# Important: We duplicate the resource so each instance 
		# tracks its own stacks and duration independently.
		var status_instance = status_to_apply.duplicate()
		status_instance.stacks = stacks
		target.apply_status(status_instance)
		print("Applied ", status_instance.status_name, " x", stacks, " to ", target.entity_name)
