extends Control

# Variables para el cronómetro
var white_time = 0
var black_time = 0
var current_player_time = 0
var timer_active = false
const GAME_TIME_LIMIT = 30 * 60  # 30 minutos en segundos
var remaining_time = GAME_TIME_LIMIT

# Referencia al tablero
@onready var board = $"../ChessBoard"

func _ready():
	# Inicializar el temporizador
	remaining_time = GAME_TIME_LIMIT
	update_timer_display()
	
	# Conectar señales del tablero
	board.connect("turn_changed", Callable(self, "_on_turn_changed"))
	board.connect("piece_captured", Callable(self, "_on_piece_captured"))
	board.connect("check_occurred", Callable(self, "_on_check_occurred"))
	board.connect("checkmate_occurred", Callable(self, "_on_checkmate_occurred"))
	board.connect("stalemate_occurred", Callable(self, "_on_stalemate_occurred"))
	board.connect("piece_moved", Callable(self, "_on_piece_moved"))
	
	# Iniciar el cronómetro
	start_timer()

func _process(delta):
	if timer_active:
		# Actualizar el temporizador global de la partida
		remaining_time -= delta
		
		# Actualizar el tiempo del jugador actual
		if board.current_turn == board.WHITE:
			white_time += delta
			current_player_time = white_time
		else:
			black_time += delta
			current_player_time = black_time
		
		# Actualizar la etiqueta del cronómetro y la barra
		update_timer_display()
		
		# Verificar si se acabó el tiempo
		if remaining_time <= 0:
			time_over()

func start_timer():
	timer_active = true
	current_player_time = white_time

func stop_timer():
	timer_active = false

func update_timer_display():
	# Actualizar texto del temporizador
	var minutes = int(remaining_time) / 60
	var seconds = int(remaining_time) % 60
	$TimerLabel.text = "%02d:%02d" % [minutes, seconds]
	
	# Actualizar barra de progreso
	var percentage = (remaining_time / GAME_TIME_LIMIT) * 100
	$TimerBar.value = percentage
	
	# Cambiar color según el tiempo restante
	if remaining_time < 60:  # Último minuto
		$TimerLabel.add_theme_color_override("font_color", Color(1, 0, 0))
		$TimerBar.modulate = Color(1, 0, 0)
	elif remaining_time < 300:  # Últimos 5 minutos
		$TimerLabel.add_theme_color_override("font_color", Color(1, 0.5, 0))
		$TimerBar.modulate = Color(1, 0.5, 0)
	else:
		$TimerLabel.add_theme_color_override("font_color", Color(1, 1, 1))
		$TimerBar.modulate = Color(0, 0.7, 0)

func update_turn_label():
	$TurnLabel.text = "Turno: " + ("Blancas" if board.current_turn == board.WHITE else "Negras")

func add_move_to_history(piece, from_pos, to_pos, captured = null):
	var piece_symbol = get_piece_symbol(piece.type)
	var from_notation = get_algebraic_notation(from_pos)
	var to_notation = get_algebraic_notation(to_pos)
	var capture_symbol = "x" if captured else "-"
	
	var move_text = piece_symbol + from_notation + capture_symbol + to_notation
	
	$MoveHistory.text += move_text + "\n"

func get_piece_symbol(type):
	match type:
		"pawn": return ""
		"knight": return "N"
		"bishop": return "B"
		"rook": return "R"
		"queen": return "Q"
		"king": return "K"
		_: return ""

func get_algebraic_notation(pos):
	var file = char(97 + pos.x) # a, b, c, ...
	var rank = str(8 - pos.y) # 8, 7, 6, ...
	return file + rank

func show_game_over(message):
	$GameOverPanel.visible = true
	$GameOverPanel/ResultLabel.text = message
	stop_timer()

func show_time_over():
	$TimeoutPanel.visible = true
	
	# Determinar el ganador por puntuación
	var white_score = calculate_score(board.WHITE)
	var black_score = calculate_score(board.BLACK)
	
	var winner_text = ""
	if white_score > black_score:
		winner_text = "Victoria para las Blancas"
	elif black_score > white_score:
		winner_text = "Victoria para las Negras"
	else:
		winner_text = "¡Empate!"
	
	$TimeoutPanel/TimeoutInfoLabel.text = winner_text
	stop_timer()

func calculate_score(color):
	# Calcular puntuación basada en piezas restantes
	var score = 0
	for i in range(board.BOARD_SIZE):
		for j in range(board.BOARD_SIZE):
			var piece = board.board[i][j]
			if piece and piece.color == color:
				match piece.type:
					"pawn": score += 1
					"knight": score += 3
					"bishop": score += 3
					"rook": score += 5
					"queen": score += 9
					"king": score += 0  # El rey no suma puntos
	
	return score

func update_captured_pieces(piece):
	var container = $WhiteCaptured if piece.color == board.BLACK else $BlackCaptured
	
	var piece_sprite = TextureRect.new()
	# Aquí normalmente cargarías el sprite de la pieza
	# piece_sprite.texture = load("res://assets/pieces/" + piece.type + ".png")
	piece_sprite.custom_minimum_size = Vector2(40, 40)
	
	container.add_child(piece_sprite)

func time_over():
	remaining_time = 0
	update_timer_display()
	show_time_over()
	board.game_over = true

# Funciones de eventos

func _on_menu_button_pressed():
	# Mostrar menú de pausa
	var pause_menu = load("res://scenes/pause_menu.tscn").instantiate()
	add_child(pause_menu)
	stop_timer()

func _on_undo_button_pressed():
	# Deshacer el último movimiento
	if board.undo_last_move():
		# Actualizar UI después de deshacer
		update_turn_label()
		# También se debería actualizar el historial de movimientos

func _on_resign_button_pressed():
	# El jugador actual se rinde
	var winner = "Blancas" if board.current_turn == board.BLACK else "Negras"
	show_game_over(winner + " ganan por rendición")

func _on_new_game_button_pressed():
	# Reiniciar el juego
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	# Volver al menú principal
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Callbacks para señales del tablero

func _on_turn_changed(turn):
	update_turn_label()

func _on_piece_captured(piece):
	update_captured_pieces(piece)

func _on_check_occurred(color):
	var player = "Blancas" if color == board.WHITE else "Negras"
	$TurnLabel.text = "¡Jaque al rey " + player + "!"

func _on_checkmate_occurred(winner):
	var winner_text = "Blancas" if winner == board.WHITE else "Negras"
	show_game_over("¡Jaque Mate! Ganan las " + winner_text)

func _on_stalemate_occurred():
	show_game_over("¡Tablas por ahogado!")

func _on_piece_moved(from_pos, to_pos, piece):
	# Buscar si alguna pieza fue capturada en este movimiento
	var captured = null
	if board.move_history.size() > 0:
		var last_move = board.move_history.back()
		captured = last_move.captured
	
	add_move_to_history(piece, from_pos, to_pos, captured)
