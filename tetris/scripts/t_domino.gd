extends Node2D

class_name TDomino


signal lock_tdomino

var bounds = {
	"min_x": -216,
	"max_x": 216,
	"max_y": 457
}

var rotation_index = 0
var wall_kicks
var tdomino_data
var is_next_domino
var dominos =[]
var other_tdominos: Array[TDomino] = []
@onready var domino_scene = preload("res://scenes/domino.tscn")
@onready var timer = $Timer

var tdomino_cells

func _ready():
	tdomino_cells = Global.cells[tdomino_data.tdomino_type]
	for cell in tdomino_cells:
		var domino = domino_scene.instantiate() as Domino
		dominos.append(domino)
		add_child(domino)
		domino.set_texture(tdomino_data.domino_texture)
		domino.position = cell * domino.get_size()
	if is_next_domino == false:
		position = tdomino_data.spawn_position
		wall_kicks = Global.wall_kicks_i if tdomino_data.tdomino_type == Global.TDomino.I else Global.wall_kicks_jlostz

func _input(event):
	if Input.is_action_just_pressed("Left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("Right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("Down"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("Hard_Drop"):
		hard_drop()
	elif Input.is_action_just_pressed("Rotate_Left"):
		rotate_tdomino(-1)
	elif Input.is_action_just_pressed("Rotate_Right"):
		rotate_tdomino(1)

func move(direction: Vector2) ->bool:
	var new_position = calculate_global_position(direction, global_position)
	if new_position:
		global_position= new_position
		return true
	return false

func hard_drop():
	while(move(Vector2.DOWN)):
		continue
	lock()

func rotate_tdomino(direction: int):
	var original_rotation_index = rotation_index
	if tdomino_data.tdomino_type== Global.TDomino.O:
		return
		
	apply_rotation(direction)
	rotation_index = wrap(rotation_index + direction, 0, 4)
	if !test_wall_kick(rotation_index, direction):
		rotation_index = original_rotation_index
		apply_rotation(-direction)

func test_wall_kick(rotation_index: int, rotation_direction: int):
	var wall_kick_index = wall_kick_index(rotation_index, rotation_direction)
	for i in wall_kicks[0].size():
		var translation= wall_kicks[wall_kick_index][i]
		if move(translation):
			return true
	return false

func wall_kick_index(rotation_index: int, rotation_direction: int):
	var wall_kick_index = rotation_index * 2
	if rotation_index < 0:
		wall_kick_index -= 1
	return wrap(wall_kick_index, 0, wall_kicks.size())
	
func apply_rotation(direction: int):
	var rotation_matrix = Global.clockwise_rotation_matrix if direction == 1 else Global.counter_clockwise_rotation_matrix
	var tdomino_cells = Global.cells[tdomino_data.tdomino_type]
	for i in tdomino_cells.size():
		var cell = tdomino_cells[i]
		var x
		var y
		var coordinates = rotation_matrix[0] * cell.x + rotation_matrix[1] * cell.y
		tdomino_cells[i] = coordinates
	for i in dominos.size():
		var domino = dominos[i]
		domino.position = tdomino_cells[i] * domino.get_size() 

func lock():
	timer.stop()
	lock_tdomino.emit(self)
	set_process_input(false)

func calculate_global_position(direction: Vector2, starting_global_position: Vector2):
	if is_colliding_with_other_tdominos(direction, starting_global_position):
		return null
	if !is_within_game_bounds(direction, starting_global_position):
		return null
	return starting_global_position + direction * dominos[0].get_size().x
	
func is_within_game_bounds(direction: Vector2, starting_global_position: Vector2):
	for domino in dominos:
		var new_position = domino.position + starting_global_position + direction * domino.get_size()
		if new_position.x < bounds.get("min_x") || new_position.x > bounds.get("max_x") || new_position.y >= bounds.get("max_y"):
			return false
	return true
	
func is_colliding_with_other_tdominos(direction: Vector2, starting_global_position: Vector2):
	for tdomino in other_tdominos:
		var tdomino_dominos = tdomino.get_children().filter(func (c): return c is Domino)
		for tdomino_domino in tdomino_dominos:
			for domino in dominos:
				if starting_global_position + domino.position + direction * domino.get_size().x == tdomino.global_position + tdomino_domino.position:
					return true
	return false

func _on_timer_timeout():
	var should_lock = !move(Vector2.DOWN)
	if should_lock:
		lock()
