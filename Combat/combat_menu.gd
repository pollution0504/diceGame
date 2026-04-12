extends Control
class_name CombatMenu

@export var entity : BattleEntity

signal attack_pressed(BattleEntity)
signal skill_pressed(BattleEntity)
signal roll_pressed(BattleEntity)
signal item_pressed(BattleEntity)
signal run_pressed(BattleEntity)

# Combat Box
@onready var carousel_container = $CarouselContainer
@onready var option_holder := $CarouselContainer/OptionHolder
@onready var option_icons := [
	$CarouselContainer/OptionHolder/AttackIcon,
	$CarouselContainer/OptionHolder/SkillIcon,
	$CarouselContainer/OptionHolder/RollIcon,
	$CarouselContainer/OptionHolder/ItemIcon,
	$CarouselContainer/OptionHolder/RunIcon,
]

var options := ["Attack", "Skill", "Roll", "Item", "Run"]
var selected_option := 0
# is the menu showing
var is_active := false

const menu_back_sfx = preload("res://SFX/menu_back_sfx.wav")
const menu_scroll_sfx = preload("res://SFX/menu_scroll_sfx.wav")
const menu_select_sfx = preload("res://SFX/menu_select_sfx.wav")

# Layout -> Transform -> Size
func _ready() -> void:
	for icon in option_icons:
		icon.custom_minimum_size = Vector2(96, 96)
		icon.size = Vector2(96, 96)
	hide()

# i figured out how to do the subtext function thingy
## Opens the Combat Menu
func open():
	selected_option = 0
	carousel_container.selected_index = 0
	is_active = true
	show()

## Closes the Combat Menu
func close():
	is_active = false
	hide()

func update_roll_button(has_active_roll: bool):
	var roll_icon = option_icons[2]  # RollIcon is index 2
	if has_active_roll:
		roll_icon.modulate = Color(0.3, 0.3, 0.3)  # grey out
	else:
		roll_icon.modulate = Color(1, 1, 1)  # normal

# Goes Up and Down on the Menu
func _unhandled_input(event):
	if not is_active:
		return
	if event.is_action_pressed("down"):
		selected_option = (selected_option + 1) % options.size()
		print(options[selected_option])
		AudioManager.play_sound(menu_scroll_sfx)
		carousel_container.selected_index = selected_option
		# no clue what this does lowkey
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("up"):
		selected_option = (selected_option - 1 + options.size()) % options.size()
		carousel_container.selected_index = selected_option
		print(options[selected_option])
		AudioManager.play_sound(menu_scroll_sfx)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		AudioManager.play_sound(menu_select_sfx)
		confirm_selection()
		

func confirm_selection():
	match options[selected_option]:
		"Attack":
			attack_pressed.emit(entity)
		"Skill":
			skill_pressed.emit(entity)
		"Roll":
			if entity.current_dice_roll == -1:
				roll_pressed.emit(entity)
			else:
				AudioManager.play_sound(menu_back_sfx)
		"Item":
			item_pressed.emit(entity)
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
