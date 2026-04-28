extends Sprite3D

@export var entity : BattleEntity
@onready var progress_bar = $SubViewport/VBoxContainer/ProgressBar
@onready var effects_label = $SubViewport/VBoxContainer/Effects


func _process(delta):
	progress_bar.value = entity.current_health
	effects_label.text = ""
	for effect in entity.active_statuses:
		effects_label.text += effect.status_name + ": x" + str(effect.stacks) + " for x" + str(effect.duration) + " turns"
