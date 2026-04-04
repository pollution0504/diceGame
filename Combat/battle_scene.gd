extends Node3D

# Signals make the flow much easier to manage
signal target_selected(index)

@onready var audio_stream_player_2d = $AudioStreamPlayer2D
const battle_music = preload("uid://8qdwmyo1p1t8")
const boxing_bell = preload("uid://bn56vppj5kewb")
const COMBAT_MENU = preload("uid://dgjar6b8g0n50")

@export var player : BattlePlayer
@export var enemies : Array[BattleEnemy]
var player_menu

enum TURNS {ALLIES, ENEMIES}
var current_turn = TURNS.ALLIES

var turn_queue: Array = []
var is_targeting := false
var selection_index := 0

func _ready():
	start_battle_music()
	player.PlayIntroAnimation()
	instantiate_entities()
	start_battle()

func start_battle_music() -> void:
	audio_stream_player_2d.stream = boxing_bell
	audio_stream_player_2d.play()
	
	await get_tree().create_timer(3).timeout
	
	audio_stream_player_2d.stream = battle_music
	audio_stream_player_2d.play()

func instantiate_entities():
	var cm : CombatMenu = COMBAT_MENU.instantiate()
	add_child(cm)
	cm.entity = player
	player_menu = cm
	# Connect using the callable syntax
	for e in enemies:
		e.on_death.connect(enemy_death)
	player_menu.attack_pressed.connect(_on_attack_decision)

func start_battle():
	current_turn = TURNS.ALLIES
	turn_queue = [player] # Add allies here too
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
			turn_queue = [player] # Add allies here too
	
	var current_actor = turn_queue.pop_front()
	
	if not current_actor.is_alive():
		advance_turn()
		return
	
	if current_actor is BattleEnemy:
		await enemy_turn(current_actor)
	else:
		await ally_turn(current_actor)

func ally_turn(actor: BattleEntity):
	print("ally turn")
	player_menu.show()
	# The menu will trigger _on_attack_decision via signal

func enemy_turn(actor: BattleEnemy):
	print("enemy turn")
	await get_tree().create_timer(1.0).timeout # Small pause for "thinking"
	var target = actor.choose_target([player])
	if target:
		await actor.Attack(target)
		
		
		print("ouch")
	advance_turn()

func enemy_death(actor: BattleEnemy):
	enemies.remove_at(enemies.find(actor))
	print("DEATH")

func _on_attack_decision(source_entity : BattleEntity):
	player_menu.hide()
	var target_idx = await get_target_selection()
	
	if target_idx != -1:
		var target = enemies[target_idx]
		await source_entity.Attack(target)
		
	
	advance_turn()

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
		_update_highlights()
	elif Input.is_action_just_pressed("left"):
		selection_index = (selection_index - 1 + enemies.size()) % enemies.size()
		_update_highlights()
	elif Input.is_action_just_pressed("ui_accept"): # "Enter" or "Space"
		target_selected.emit(selection_index)

func _update_highlights():
	_clear_highlights()
	_highlight_enemy(selection_index)

func _highlight_enemy(index):
	# Using modulate for now; if 3D, you might want to toggle a Mesh visibility
	if enemies[index].is_alive():
		enemies[index].modulate = Color.RED 

func _clear_highlights():
	for e in enemies:
		e.modulate = Color.WHITE

func check_battle_over() -> bool:
	# filter() is a very clean way to check lists!
	var alive_enemies = enemies.filter(func(e): return e.is_alive())
	var alive_allies = [player].filter(func(a): return a.is_alive())
	
	if alive_enemies.is_empty():
		print("Victory!")
		return true
	if alive_allies.is_empty():
		print("Game Over!")
		return true
	return false
