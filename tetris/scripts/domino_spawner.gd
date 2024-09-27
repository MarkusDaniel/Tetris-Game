extends Node

var current_t_domino
var next_t_domino 

@onready var table = $"../Table" as Table
@onready var ui = $"../UI" as UI


var is_game_over = false

func _ready():
	current_t_domino = Global.TDomino.values().pick_random()	
	next_t_domino = Global.TDomino.values().pick_random()	
	table.spawn_tdomino(current_t_domino, false, null)
	table.tdomino_locked.connect(on_tdomino_locked)
	table.game_over.connect(on_game_over)

func on_tdomino_locked():
	if is_game_over:
		return
	var new_tdomino = Global.TDomino.values().pick_random()
	table.spawn_tdomino(new_tdomino, false, null)

func on_game_over():
	is_game_over = true
	Global.score = 0
	ui.show_game_over()
	
