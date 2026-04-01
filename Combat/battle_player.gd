extends BattleAlly
class_name BattlePlayer

@export var health_bar : ProgressBar

func _ready():
	super()
	health_bar.max_value = stats.max_health
	health_bar.value = current_health

func TakeDamage(damage : int) -> int:
	var dmg = super(damage)
	health_bar.value = current_health
	return dmg
