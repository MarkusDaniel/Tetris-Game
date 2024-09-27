extends Node

class_name Table
@onready var score_sound = $Score_Sound



signal tdomino_locked
signal game_over

const ROWS_COUNT =20
const COLUMN_COUNT =10

var tdominos: Array[TDomino] = []
@export var t_domino_scene: PackedScene

func spawn_tdomino(type: Global.TDomino, is_next_domino, spawn_position):
	var tdomino_data = Global.data[type]
	var tdomino = t_domino_scene.instantiate() as TDomino
	
	tdomino.tdomino_data = tdomino_data
	tdomino.is_next_domino = is_next_domino
	
	if is_next_domino == false:
		tdomino.position = tdomino_data.spawn_position
		tdomino.other_tdominos = tdominos
		tdomino.lock_tdomino.connect(on_tdomino_locked)
		add_child(tdomino)
	

func on_tdomino_locked(tdomino: TDomino):
	tdominos.append(tdomino)
	tdomino_locked.emit()
	Global.score += 1
	check_game_over()
	clear_lines()

func check_game_over():
	for tdomino in tdominos:
		var dominos = tdomino.get_children().filter(func (c): return c is Domino)
		for domino in dominos:
			var y_location = domino.global_position.y
			if y_location == -456:
				
				game_over.emit()

func clear_lines():
	var table_dominos= fill_table_dominos()
	clear_table_dominos(table_dominos)
	
func fill_table_dominos():
	var table_dominos =[]
	for i in ROWS_COUNT:
		table_dominos.append([])
	for tdomino in tdominos:
		var tdomino_dominos = tdomino.get_children().filter(func (c): return c is Domino)
		for domino in tdomino_dominos:
			var row =(domino.global_position.y + domino.get_size().y / 2) / domino.get_size().y +ROWS_COUNT / 2
			table_dominos[row - 1].append(domino)
	return table_dominos
	
func clear_table_dominos(table_dominos):
	var i = ROWS_COUNT
	while i > 0:
		var row_to_analyze= table_dominos[i-1]
		if row_to_analyze.size() == COLUMN_COUNT:
			score_sound.play()
			Global.score += 10
			 
			clear_row(row_to_analyze)
			table_dominos[i - 1].clear()
			move_all_row_dominos_down(table_dominos, i)
		i-= 1

func clear_row(row):
	for domino in row:
		domino.queue_free()

func move_all_row_dominos_down(table_dominos, cleared_row_number):
	for i in range(cleared_row_number -1, 1, -1):
		var row_to_move = table_dominos[i-1]
		if row_to_move.size() == 0:
			return false
		for domino in row_to_move:
			domino.position.y += domino.get_size().y
			table_dominos[cleared_row_number -1].append(domino)
		table_dominos[i-1].clear()
