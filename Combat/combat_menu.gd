extends Control
class_name CombatMenu

@export var entity : BattleEntity

signal attack_pressed(BattleEntity)
signal skill_pressed(BattleEntity)
signal run_pressed(BattleEntity)

@onready var option_holder := $OptionHolder
@onready var labels := [
	$OptionHolder/AttackLabel,
	$OptionHolder/SkillLabel,
	$OptionHolder/RunLabel
]

var options := ["Attack", "Skill", "Run"]
var selected_option := 0
# is the menu showing
var is_active := false

func _ready() -> void:
	hide()

# i figured out how to do the subtext function thingy
## Opens the Combat Menu
func open():
	selected_option = 0
	is_active = true
	show()

## Closes the Combat Menu
func close():
	is_active = false
	hide()

# Goes Up and Down on the Menu
func _unhandled_input(event):
	if not is_active:
		return
	if event.is_action_pressed("down"):
		selected_option = (selected_option + 1) % options.size()
		print(options[selected_option])
		# no clue what this does lowkey
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("up"):
		selected_option = (selected_option - 1 + options.size()) % options.size()
		print(options[selected_option])
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_accept"):
		confirm_selection()
		get_viewport().set_input_as_handled()

func confirm_selection():
	# lowkey fire
	match options[selected_option]:
		"Attack":
			attack_pressed.emit(entity)
		"Skill":
			skill_pressed.emit(entity)
		"Run":
			run_pressed.emit(entity)

#func update_visuals():
	#for i in range(labels.size()):
		#var label = labels[i]
#
		#if i == selected_option:
			#label.text = "> " + options[i] + " <"
			#label.scale = Vector2(1.2, 1.2)
			#label.modulate = Color(1, 1, 0) # yellow
		#else:
			#label.text = options[i]
			#label.scale = Vector2(1, 1)
			#label.modulate = Color(1, 1, 1)
