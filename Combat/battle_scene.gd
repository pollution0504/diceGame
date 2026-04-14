extends Node3D

# Signals make the flow much easier to manage
signal target_selected(index)

@onready var audio_stream_player_2d = $AudioStreamPlayer2D
const battle_music = preload("res://Music/fd_music.mp3")
const boxing_bell = preload("res://SFX/bell_sfx.mp3")
const COMBAT_MENU = preload("res://Combat/combat_menu.tscn")
const CURSOR = preload("res://Combat/cursor.tscn")

const menu_back_sfx = preload("res://SFX/menu_back_sfx.wav")
const menu_scroll_sfx = preload("res://SFX/menu_scroll_sfx.wav")
const menu_select_sfx = preload("res://SFX/menu_select_sfx.wav")
const dice_roll_sfx = preload("res://SFX/dice_roll_sfx.wav")

@export var battle_entities : Array[PackedScene]
var allies : Array[BattleAlly]
var enemies : Array[BattleEnemy]

const COMBAT_MENU_OFFSET := Vector3(150,0,0)

const BELL_TIMER_DURATION := 3.0
const DICE_TIMER_DURATION := 1.0
const ENEMY_TURN_DELAY := 1.0
const CURSOR_HEIGHT_OFFSET := 0.9
const CURSOR_LERP_DURATION := 0.1

var selection_cursor : Node3D  
var cursor_tween : Tween

enum TURNS {ALLIES, ENEMIES}
var current_turn = TURNS.ALLIES

var turn_queue: Array = []
var is_targeting := false
var selection_index := 0

var entity_spacing : Vector3 = Vector3(-2,0,2)

func _ready():
	start_battle_music()
	instantiate_entities()
	
	selection_cursor = CURSOR.instantiate()
	add_child(selection_cursor)
	selection_cursor.hide()
	
	for enemy in enemies:
		enemy.PlayIntroAnimation()
	for ally in allies:
		ally.PlayIntroAnimation()
		
	# Problem 001
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	start_battle()

func start_battle_music() -> void:
	audio_stream_player_2d.stream = boxing_bell
	audio_stream_player_2d.play()
	
	await get_tree().create_timer(BELL_TIMER_DURATION).timeout
	
	audio_stream_player_2d.stream = battle_music
	audio_stream_player_2d.play()

func instantiate_entities():
	for e in battle_entities:
		var entity = e.instantiate()
		if entity is BattleAlly:
			allies.append(entity)
		elif entity is BattleEnemy:
			enemies.append(entity)
		add_child(entity)	
	var i = 1
	for ally in allies:
		#do positioning
		if i == 1:
			ally.position += i * entity_spacing + Vector3(0,0.5,0)
		if i == 2:
			ally.position += Vector3(-4,0.5,-4)
			
		i += 1
		
		var cm : CombatMenu = COMBAT_MENU.instantiate()
		ally.add_child(cm)
		#hopefully this doesnt fuck up
		ally.combat_menu = cm
		cm.entity = ally
		cm.close()
		
		ally.combat_menu.attack_pressed.connect(_on_attack_decision)
		ally.combat_menu.skill_pressed.connect(_on_skill_decision)
		ally.combat_menu.roll_pressed.connect(_on_roll_decision)
		ally.combat_menu.item_pressed.connect(_on_item_decision)
		ally.combat_menu.run_pressed.connect(_on_run_decision)
	# Connect using the callable syntax
	i = 1
	for e in enemies:
		e.position += -1 * i * entity_spacing + Vector3(0,0.5,0)
		i += 1
		e.on_death.connect(enemy_death)

func start_battle():
	current_turn = TURNS.ALLIES
	turn_queue = allies.duplicate() # Add allies here too
	advance_turn()

func advance_turn():
	if check_battle_over():
		return
	if turn_queue.is_empty():
		if current_turn == TURNS.ALLIES:
			current_turn = TURNS.ENEMIES
			turn_queue = enemies.duplicate()
		else:
			current_turn = TURNS.ALLIES
			turn_queue = allies.duplicate() # Add allies here too
	
	var current_actor = turn_queue.pop_front()
	
	# Process status effects at the start of the turn
	current_actor.process_turn()
	
	if not current_actor.is_alive():
		advance_turn()
		return
	
	if current_actor.skip_turn:
		print(current_actor.entity_name, " skips turn!")
		advance_turn()
		return
	
	# The actor now knows how to take its own turn
	await current_actor.take_turn(allies, enemies)
	advance_turn()

func enemy_death(actor: BattleEnemy):
	enemies.remove_at(enemies.find(actor))
	print("DEATH")

func get_target_selection() -> int:
	is_targeting = true
	selection_index = 0
	_highlight_enemy(selection_index)
	
	# This "waits" until the target_selected signal is emitted in _input
	var selected_index = await target_selected
	
	is_targeting = false
	_clear_highlights()
	return selected_index

func _input(event: InputEvent) -> void:
	if not is_targeting:
		return
		
	if Input.is_action_just_pressed("right"):
		selection_index = (selection_index + 1) % enemies.size()
		AudioManager.play_sound(menu_scroll_sfx)
		_update_highlights()
	elif Input.is_action_just_pressed("left"):
		AudioManager.play_sound(menu_scroll_sfx)
		selection_index = (selection_index - 1 + enemies.size()) % enemies.size()
		_update_highlights()
	elif Input.is_action_just_pressed("ui_accept"): # "Enter" or "Space"
		AudioManager.play_sound(menu_select_sfx)
		target_selected.emit(selection_index)

func _update_highlights():
	_highlight_enemy(selection_index)

## [code]_highlight_enemy(index)[/code] Moves the selection cursor to the enemy at index. 
## If the cursor is already visible, it smoothly tweens to the new position; 
## otherwise it snaps directly and shows it. Does nothing if the target is dead.
func _highlight_enemy(index):
	var target = enemies[index]
	if target.is_alive():
		var target_pos = target.global_position + Vector3(0, CURSOR_HEIGHT_OFFSET, 0)
		
		if selection_cursor.visible:
			if cursor_tween:
				cursor_tween.kill()
			cursor_tween = get_tree().create_tween()
			cursor_tween.tween_property(selection_cursor, "global_position", target_pos, CURSOR_LERP_DURATION)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			selection_cursor.global_position = target_pos
			selection_cursor.show()

func _clear_highlights():
	selection_cursor.hide()

func check_battle_over() -> bool:
	# filter() is a very clean way to check lists!
	var alive_enemies = enemies.filter(func(e): return e.is_alive())
	var alive_allies = allies.filter(func(a): return a.is_alive())
	
	if alive_enemies.is_empty():
		print("Victory!")
		end_battle()
		return true
	if alive_allies.is_empty():
		print("Game Over!")
		end_battle()
		return true
	return false
	
func _on_attack_decision(source_entity : BattleAlly):
	print("_on_attack_decision called by: ", source_entity.name)
	source_entity.combat_menu.close()
	var target_idx = await get_target_selection()
	
	if target_idx != -1:
		var target = enemies[target_idx]
		await source_entity.Attack(target, allies, enemies)
	
	source_entity.turn_ended.emit()

func _on_skill_decision(source_entity : BattleAlly):
	source_entity.combat_menu.close()
	source_entity.turn_ended.emit()
	
func _on_roll_decision(source_entity: BattleAlly):
	source_entity.combat_menu.close()
	
	AudioManager.play_sound(dice_roll_sfx)
	source_entity.RollDice(allies, enemies)
	
	await get_tree().create_timer(DICE_TIMER_DURATION).timeout
	
	source_entity.combat_menu.update_roll_button(true) # Grey out the Dice
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var cam = get_viewport().get_camera_3d()
	var screen_pos = cam.unproject_position(source_entity.global_position)
	source_entity.combat_menu.position = screen_pos + Vector2(150, 0)
	source_entity.combat_menu.open()
	
func _on_item_decision(source_entity : BattleAlly):
	source_entity.combat_menu.close()
	source_entity.turn_ended.emit()
	
func _on_run_decision(source_entity : BattleEntity):
	source_entity.combat_menu.close()
	for a in allies:
		await a.PlayRunAnimation()
	end_battle()
	
func end_battle():
	get_tree().quit()
