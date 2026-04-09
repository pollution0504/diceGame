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

var wheel_tween : Tween

const RADIUS_X := 70.0
const RADIUS_Y := 42.0
const ANGLE_STEP := 0.9
const BASE_ANGLE := -PI / 2.0
const SELECTED_SCALE := 1.25
const NORMAL_SCALE := 0.92
const FAR_SCALE := 0.78
const TWEEN_TIME := 0.14



func _ready() -> void:
	hide()
	update_visuals()

# i figured out how to do the subtext function thingy
## Opens the Combat Menu
func open():
	selected_option = 0
	is_active = true
	show()
	update_visuals()

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
		update_visuals()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("up"):
		selected_option = (selected_option - 1 + options.size()) % options.size()
		print(options[selected_option])
		update_visuals()
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
func update_visuals(instant := false) -> void:
	if wheel_tween:
		wheel_tween.kill()

	if not instant:
		wheel_tween = create_tween()
		wheel_tween.set_parallel(true)

	for i in range(labels.size()):
		var node = labels[i]
		node.text = options[i]

		var offset: int = i - selected_option

		# Wrap first
		if offset > labels.size() / 2:
			offset -= options.size()
		elif offset < -labels.size() / 2:
			offset += options.size()

		# THEN calculate angle
		var angle: float = BASE_ANGLE + offset * ANGLE_STEP

		var target_position: Vector2 = Vector2( 
			sin(angle) * RADIUS_X,   # sin for X = subtle horizontal sway
			-cos(angle) * RADIUS_Y * 0.6  # cos for Y = primary vertical movement
		)
		var depth: float = (sin(angle) + 1.0) / 2.0

		var target_scale_value: float = lerp(FAR_SCALE, SELECTED_SCALE, depth)
		if offset != 0:
			target_scale_value = min(target_scale_value, NORMAL_SCALE)

		var target_scale: Vector2 = Vector2.ONE * target_scale_value

		var target_modulate: Color = Color.WHITE
		target_modulate.a = lerp(0.45, 1.0, depth)

		if offset == 0:
			node.text = "> " + options[i] + " <"

		node.z_index = 10 if offset == 0 else 0

		if instant:
			node.position = target_position
			node.scale = target_scale
			node.modulate = target_modulate
		else:
			wheel_tween.tween_property(node, "position", target_position, TWEEN_TIME)
			wheel_tween.tween_property(node, "scale", target_scale, TWEEN_TIME)
			wheel_tween.tween_property(node, "modulate", target_modulate, TWEEN_TIME)
