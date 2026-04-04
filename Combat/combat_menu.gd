extends Control
class_name CombatMenu

@export var entity : BattleEntity

signal attack_pressed(BattleEntity)
signal run_pressed(BattleEntity)

func _on_attack_pressed() -> void:
	attack_pressed.emit(entity)

func _on_item_pressed():
	pass # Replace with function body.

func _on_run_pressed():
	run_pressed.emit(entity)
