extends Control
class_name CombatMenu

@export var entity : BattleEntity

signal attack_pressed(BattleEntity)

func _on_attack_pressed() -> void:
	attack_pressed.emit(entity)
