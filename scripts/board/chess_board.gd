extends Node2D

# Constantes
const BOARD_SIZE = 8
const SQUARE_SIZE = 80
const WHITE = 0
const BLACK = 1

# Variables para el estado del juego
var board = []
var selected_piece = null
var current_turn = WHITE
var game_over = false
var winner = null
var move_history = []
var ai_thinking = false
var ai_enabled = false
var ai_difficulty = 1  # 0 = fácil, 1 = medio, 2 = difícil
var last_move = null

# Carga de recursos y escenas
var piece_scene = preload("res://scenes/chess_piece.tscn")

# Variables para las piezas capturadas
var captured_white = []
var captured_black = []

# Valores de las piezas para evaluación
var piece_values = {
	"pawn": 100,
	"knight": 320,
	"bishop": 330,
	"rook": 500,
	"queen": 900,
	"king": 20000
}

# Tablas de posición para evaluación avanzada
var pawn_table = [
	[0, 0, 0, 0, 0, 0, 0, 0],
	[50, 50, 50, 50, 50, 50, 50, 50],
	[10, 10, 20, 30, 30, 20, 10, 10],
	[5, 5, 10, 25, 25, 10, 5, 5],
	[0, 0, 0, 20, 20, 0, 0, 0],
	[5, -5, -10, 0, 0, -10, -5, 5],
	[5, 10, 10, -20, -20, 10, 10, 5],
	[0, 0, 0, 0, 0, 0, 0, 0]
]

var knight_table = [
	[-50, -40, -30, -30, -30, -30, -40, -50],
	[-40, -20, 0, 0, 0, 0, -20, -40],
	[-30, 0, 10, 15, 15, 10, 0, -30],
	[-30, 5, 15, 20, 20, 15, 5, -30],
	[-30, 0, 15, 20, 20, 15, 0, -30],
	[-30, 5, 10, 15, 15, 10, 5, -30],
	[-40, -20, 0, 5, 5, 0, -20, -40],
	[-50, -40, -30, -30, -30, -30, -40, -50]
]

var bishop_table = [
	[-20, -10, -10, -10, -10, -10, -10, -20],
	[-10, 0, 0, 0, 0, 0, 0, -10],
	[-10, 0, 10, 10, 10, 10, 0, -10],
	[-10, 5, 5, 10, 10, 5, 5, -10],
	[-10, 0, 5, 10, 10, 5, 0, -10],
	[-10, 10, 10, 10, 10, 10, 10, -10],
	[-10, 5, 0, 0, 0, 0, 5, -10],
	[-20, -10, -10, -10, -10, -10, -10, -20]
]

var rook_table = [
	[0, 0, 0, 0, 0, 0, 0, 0],
	[5, 10, 10, 10, 10, 10, 10, 5],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[0, 0, 0, 5, 5, 0, 0, 0]
]

var queen_table = [
	[-20, -10, -10, -5, -5, -10, -10, -20],
	[-10, 0, 0, 0, 0, 0, 0, -10],
	[-10, 0, 5, 5, 5, 5, 0, -10],
	[-5, 0, 5, 5, 5, 5, 0, -5],
	[0, 0, 5, 5, 5, 5, 0, -5],
	[-10, 5, 5, 5, 5, 5, 0, -10],
	[-10, 0, 5, 0, 0, 0, 0, -10],
	[-20, -10, -10, -5, -5, -10, -10, -20]
]

var king_table = [
	[-30, -40, -40, -50, -50, -40, -40, -30],
	[-30, -40, -40, -50, -50, -40, -40, -30],
	[-30, -40, -40, -50, -50, -40, -40, -30],
	[-30, -40, -40, -50, -50, -40, -40, -30],
	[-20, -30, -30, -40, -40, -30, -30, -20],
	[-10, -20, -20, -20, -20, -20, -20, -10],
	[20, 20, 0, 0, 0, 0, 20, 20],
	[20, 30, 10, 0, 0, 10, 30, 20]
]

# Señales
signal piece_moved(from_pos, to_pos, piece)
signal piece_captured(piece)
signal turn_changed(turn)
signal check_occurred(color)
signal checkmate_occurred(winner)
signal stalemate_occurred()

func _ready():
	# Inicializa el tablero
	initialize_board()
	setup_pieces()
	
	# Conectar señales
	connect("piece_moved", Callable(self, "_on_piece_moved"))
	connect("piece_captured", Callable(self, "_on_piece_captured"))
	connect("turn_changed", Callable(self, "_on_turn_changed"))
	connect("check_occurred", Callable(self, "_on_check_occurred"))
	connect("checkmate_occurred", Callable(self, "_on_checkmate_occurred"))
	connect("stalemate_occurred", Callable(self, "_on_stalemate_occurred"))

func initialize_board():
	# Crear la matriz del tablero 8x8
	board = []
	for i in range(BOARD_SIZE):
		board.append([])
		for j in range(BOARD_SIZE):
			board[i].append(null)
	
	# Crear el sprite del tablero visual
	var board_texture = load("res://assets/board/chess_board.png")
	if board_texture:
		$BoardSprite.texture = board_texture
		$BoardSprite.scale = Vector2(SQUARE_SIZE * 8 / board_texture.get_width(), 
								   SQUARE_SIZE * 8 / board_texture.get_height())
	else:
		# Dibujar un tablero básico si no hay textura
		create_basic_board()

func create_basic_board():
	# Crear un tablero básico usando rectángulos coloreados
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var square = ColorRect.new()
			square.size = Vector2(SQUARE_SIZE, SQUARE_SIZE)
			square.position = Vector2(i * SQUARE_SIZE, j * SQUARE_SIZE) - Vector2(BOARD_SIZE * SQUARE_SIZE / 2, BOARD_SIZE * SQUARE_SIZE / 2)
			
			# Alternar colores blanco y negro para casillas
			if (i + j) % 2 == 0:
				square.color = Color(0.9, 0.9, 0.8) # Casilla clara
			else:
				square.color = Color(0.5, 0.4, 0.3) # Casilla oscura
			
			add_child(square)

func setup_pieces():
	# Función principal para configurar todas las piezas
	setup_pawns()
	setup_rooks()
	setup_knights()
	setup_bishops()
	setup_queens()
	setup_kings()

func setup_pawns():
	# Configurar peones
	for i in range(BOARD_SIZE):
		create_piece("pawn", BLACK, Vector2(i, 1))
		create_piece("pawn", WHITE, Vector2(i, 6))

func setup_rooks():
	# Configurar torres
	create_piece("rook", BLACK, Vector2(0, 0))
	create_piece("rook", BLACK, Vector2(7, 0))
	create_piece("rook", WHITE, Vector2(0, 7))
	create_piece("rook", WHITE, Vector2(7, 7))

func setup_knights():
	# Configurar caballos
	create_piece("knight", BLACK, Vector2(1, 0))
	create_piece("knight", BLACK, Vector2(6, 0))
	create_piece("knight", WHITE, Vector2(1, 7))
	create_piece("knight", WHITE, Vector2(6, 7))

func setup_bishops():
	# Configurar alfiles
	create_piece("bishop", BLACK, Vector2(2, 0))
	create_piece("bishop", BLACK, Vector2(5, 0))
	create_piece("bishop", WHITE, Vector2(2, 7))
	create_piece("bishop", WHITE, Vector2(5, 7))

func setup_queens():
	# Configurar reinas
	create_piece("queen", BLACK, Vector2(3, 0))
	create_piece("queen", WHITE, Vector2(3, 7))

func setup_kings():
	# Configurar reyes
	create_piece("king", BLACK, Vector2(4, 0))
	create_piece("king", WHITE, Vector2(4, 7))

func create_piece(type, color, board_pos):
	# Crea una pieza en la posición del tablero especificada
	var piece = piece_scene.instantiate()
	piece.setup(type, color)
	piece.board_position = board_pos
	piece.position = board_to_pixel(board_pos)
	
	$Pieces.add_child(piece)
	board[board_pos.x][board_pos.y] = piece
	
	# Conectar señales de la pieza
	piece.connect("piece_selected", Callable(self, "_on_piece_selected"))
	
	return piece

func board_to_pixel(board_pos):
	# Convierte posición del tablero (0-7, 0-7) a posición en píxeles
	var x = (board_pos.x - BOARD_SIZE/2) * SQUARE_SIZE + SQUARE_SIZE/2
	var y = (board_pos.y - BOARD_SIZE/2) * SQUARE_SIZE + SQUARE_SIZE/2
	return Vector2(x, y)

func pixel_to_board(pixel_pos):
	# Convierte posición en píxeles a posición del tablero (0-7, 0-7)
	var local_pos = pixel_pos - position
	var x = floor((local_pos.x / SQUARE_SIZE) + BOARD_SIZE/2)
	var y = floor((local_pos.y / SQUARE_SIZE) + BOARD_SIZE/2)
	
	# Verificar que está dentro del tablero
	if x >= 0 and x < BOARD_SIZE and y >= 0 and y < BOARD_SIZE:
		return Vector2(x, y)
	return null

func _input(event):
	if game_over or ai_thinking:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_click(event.position)

func handle_click(position):
	# Maneja los clics del ratón para la selección y movimiento de piezas
	var board_pos = pixel_to_board(position)
	
	if board_pos == null:
		return
	
	if selected_piece:
		# Si ya hay una pieza seleccionada, intentar moverla
		move_piece(selected_piece, board_pos)
	else:
		# Si no hay pieza seleccionada, intentar seleccionar una
		var piece = board[board_pos.x][board_pos.y]
		if piece and piece.color == current_turn:
			select_piece(piece)

func select_piece(piece):
	# Seleccionar una pieza
	selected_piece = piece
	piece.select()
	
	# Mostrar movimientos válidos
	var valid_moves = get_valid_moves(piece)
	highlight_valid_moves(valid_moves)

func move_piece(piece, to_pos):
	# Verificar si el movimiento es válido
	var from_pos = piece.board_position
	var valid_moves = get_valid_moves(piece)
	
	if valid_moves.has(to_pos):
		# Capturar pieza si hay una en la posición destino
		var captured = board[to_pos.x][to_pos.y]
		if captured:
			capture_piece(captured)
		
		# Actualizar la matriz del tablero
		board[from_pos.x][from_pos.y] = null
		board[to_pos.x][to_pos.y] = piece
		
		# Actualizar la posición de la pieza
		piece.board_position = to_pos
		piece.position = board_to_pixel(to_pos)
		
		# Deseleccionar la pieza
		piece.deselect()
		selected_piece = null
		clear_highlights()
		
		# Registrar movimiento en el historial
		record_move(piece, from_pos, to_pos, captured)
		
		# Emitir señal de movimiento
		emit_signal("piece_moved", from_pos, to_pos, piece)
		
		# Cambiar turno
		current_turn = BLACK if current_turn == WHITE else WHITE
		emit_signal("turn_changed", current_turn)
		
		# Verificar jaque, jaque mate o tablas
		check_game_state()
		
		# Si el modo AI está habilitado y es el turno de la IA, hacer que la IA juegue
		if ai_enabled and current_turn == BLACK and !game_over:
			ai_make_move()
	else:
		# Si el movimiento no es válido, deseleccionar la pieza
		piece.deselect()
		selected_piece = null
		clear_highlights()
		
		# Si el jugador hizo clic en otra de sus piezas, seleccionarla
		var new_piece = board[to_pos.x][to_pos.y]
		if new_piece and new_piece.color == current_turn:
			select_piece(new_piece)

func get_valid_moves(piece):
	# Implementar la lógica de ajedrez para obtener movimientos válidos
	# Esta es una función simplificada; la implementación real sería más compleja
	var valid_moves = []
	var pos = piece.board_position
	
	match piece.type:
		"pawn":
			valid_moves = get_pawn_moves(piece)
		"rook":
			valid_moves = get_rook_moves(piece)
		"knight":
			valid_moves = get_knight_moves(piece)
		"bishop":
			valid_moves = get_bishop_moves(piece)
		"queen":
			valid_moves = get_queen_moves(piece)
		"king":
			valid_moves = get_king_moves(piece)
	
	# Filtrar movimientos que pondrían al rey en jaque
	valid_moves = filter_check_moves(piece, valid_moves)
	
	return valid_moves

# Funciones de movimientos válidos para cada tipo de pieza
# Estas son versiones simplificadas; la implementación real sería más compleja

func get_pawn_moves(piece):
	var moves = []
	var pos = piece.board_position
	var direction = 1 if piece.color == BLACK else -1
	var start_row = 1 if piece.color == BLACK else 6
	
	# Movimiento hacia adelante
	var forward = Vector2(pos.x, pos.y + direction)
	if is_valid_position(forward) and board[forward.x][forward.y] == null:
		moves.append(forward)
		
		# Doble movimiento desde la posición inicial
		if pos.y == start_row:
			var double_forward = Vector2(pos.x, pos.y + 2 * direction)
			if board[double_forward.x][double_forward.y] == null:
				moves.append(double_forward)
	
	# Captura diagonal
	var diagonals = [Vector2(pos.x - 1, pos.y + direction), Vector2(pos.x + 1, pos.y + direction)]
	for diag in diagonals:
		if is_valid_position(diag) and board[diag.x][diag.y] != null and board[diag.x][diag.y].color != piece.color:
			moves.append(diag)
	
	return moves

func get_rook_moves(piece):
	return get_line_moves(piece, [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)])

func get_bishop_moves(piece):
	return get_line_moves(piece, [Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)])

func get_queen_moves(piece):
	return get_line_moves(piece, [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
								Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)])

func get_line_moves(piece, directions):
	var moves = []
	var pos = piece.board_position
	
	for dir in directions:
		var current = pos + dir
		while is_valid_position(current):
			if board[current.x][current.y] == null:
				moves.append(current)
			elif board[current.x][current.y].color != piece.color:
				moves.append(current)
				break
			else:
				break
			current += dir
	
	return moves

func get_knight_moves(piece):
	var moves = []
	var pos = piece.board_position
	var offsets = [
		Vector2(1, 2), Vector2(2, 1),
		Vector2(-1, 2), Vector2(-2, 1),
		Vector2(1, -2), Vector2(2, -1),
		Vector2(-1, -2), Vector2(-2, -1)
	]
	
	for offset in offsets:
		var new_pos = pos + offset
		if is_valid_position(new_pos) and (board[new_pos.x][new_pos.y] == null or board[new_pos.x][new_pos.y].color != piece.color):
			moves.append(new_pos)
	
	return moves

func get_king_moves(piece):
	var moves = []
	var pos = piece.board_position
	
	# Movimientos normales en las 8 direcciones
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			
			var new_pos = Vector2(pos.x + i, pos.y + j)
			if is_valid_position(new_pos) and (board[new_pos.x][new_pos.y] == null or board[new_pos.x][new_pos.y].color != piece.color):
				moves.append(new_pos)
	
	# Implementar enroque (castling) aquí
	
	return moves

func is_valid_position(pos):
	return pos.x >= 0 and pos.x < BOARD_SIZE and pos.y >= 0 and pos.y < BOARD_SIZE

func filter_check_moves(piece, moves):
	# Filtrar movimientos que dejarían al rey en jaque
	var filtered_moves = []
	var original_pos = piece.board_position
	var player_color = piece.color
	
	for move in moves:
		# Simular movimiento
		var captured = board[move.x][move.y]
		board[original_pos.x][original_pos.y] = null
		board[move.x][move.y] = piece
		
		# Verificar si el rey está en jaque después del movimiento
		if !is_king_in_check(player_color):
			filtered_moves.append(move)
		
		# Revertir movimiento simulado
		board[original_pos.x][original_pos.y] = piece
		board[move.x][move.y] = captured
	
	return filtered_moves

func is_king_in_check(color):
	# Encontrar posición del rey
	var king_pos = find_king(color)
	if king_pos == null:
		return false
	
	# Verificar si alguna pieza enemiga puede capturar al rey
	var opponent_color = BLACK if color == WHITE else WHITE
	
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece and piece.color == opponent_color:
				var moves = []
				match piece.type:
					"pawn":
						moves = get_pawn_moves(piece)
					"rook":
						moves = get_rook_moves(piece)
					"knight":
						moves = get_knight_moves(piece)
					"bishop":
						moves = get_bishop_moves(piece)
					"queen":
						moves = get_queen_moves(piece)
					"king":
						moves = get_king_moves(piece)
				
				if moves.has(king_pos):
					return true
	
	return false

func find_king(color):
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece and piece.type == "king" and piece.color == color:
				return Vector2(i, j)
	return null

func highlight_valid_moves(moves):
	for move in moves:
		var highlight = ColorRect.new()
		highlight.size = Vector2(SQUARE_SIZE, SQUARE_SIZE)
		highlight.position = board_to_pixel(move) - Vector2(SQUARE_SIZE/2, SQUARE_SIZE/2)
		highlight.color = Color(0, 1, 0, 0.3)  # Verde semitransparente
		highlight.name = "highlight"
		add_child(highlight)

func clear_highlights():
	for child in get_children():
		if child.name == "highlight":
			child.queue_free()

func capture_piece(piece):
	# Agregar a la lista de piezas capturadas
	if piece.color == WHITE:
		captured_white.append(piece)
	else:
		captured_black.append(piece)
	
	emit_signal("piece_captured", piece)
	piece.queue_free()

func record_move(piece, from_pos, to_pos, captured):
	var move = {
		"piece": piece,
		"type": piece.type,
		"color": piece.color,
		"from": from_pos,
		"to": to_pos,
		"captured": captured.type if captured else null
	}
	
	move_history.append(move)
	last_move = move

func check_game_state():
	# Verificar jaque
	if is_king_in_check(current_turn):
		emit_signal("check_occurred", current_turn)
		
		# Verificar jaque mate
		if is_checkmate(current_turn):
			game_over = true
			winner = BLACK if current_turn == WHITE else WHITE
			emit_signal("checkmate_occurred", winner)
	# Verificar tablas por ahogado
	elif is_stalemate(current_turn):
		game_over = true
		emit_signal("stalemate_occurred")

func is_checkmate(color):
	# Verificar si hay algún movimiento legal que saque al rey del jaque
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece and piece.color == color:
				var valid_moves = get_valid_moves(piece)
				if valid_moves.size() > 0:
					return false
	
	return true

func is_stalemate(color):
	# El rey no está en jaque pero no hay movimientos legales
	if is_king_in_check(color):
		return false
	
	# Verificar si hay algún movimiento legal
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece and piece.color == color:
				var valid_moves = get_valid_moves(piece)
				if valid_moves.size() > 0:
					return false
	
	return true

func undo_last_move():
	if move_history.size() > 0:
		var move = move_history.pop_back()
		
		# Revertir movimiento
		var piece = board[move.to.x][move.to.y]
		board[move.to.x][move.to.y] = null
		board[move.from.x][move.from.y] = piece
		
		piece.board_position = move.from
		piece.position = board_to_pixel(move.from)
		
		# Restaurar pieza capturada si la hubo
		if move.captured:
			var captured_piece = create_piece(move.captured, 1 - move.color, move.to)
		
		# Cambiar turno
		current_turn = 1 - current_turn
		emit_signal("turn_changed", current_turn)
		
		# Restaurar estado del juego
		game_over = false
		winner = null
		
		# Actualizar último movimiento
		last_move = move_history.back() if move_history.size() > 0 else null
		
		return true
	
	return false

func ai_make_move():
	ai_thinking = true
	
	var ai_move
	
	# Elegir algoritmo basado en dificultad
	match ai_difficulty:
		0:  # Fácil - movimiento aleatorio
			ai_move = get_random_ai_move()
		1:  # Medio - minimax con profundidad 2
			ai_move = get_minimax_move(2)
		2:  # Difícil - minimax con profundidad 4
			ai_move = get_minimax_move(4)
	
	if ai_move:
		# Hacer movimiento después de pequeña pausa para simular "pensamiento"
		await get_tree().create_timer(1.0).timeout
		move_piece(ai_move.piece, ai_move.to)
	
	ai_thinking = false

func get_random_ai_move():
	var possible_moves = []
	
	# Encontrar todas las piezas de la IA y sus movimientos válidos
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece and piece.color == current_turn:
				var valid_moves = get_valid_moves(piece)
				for move in valid_moves:
					possible_moves.append({"piece": piece, "to": move})
	
	# Seleccionar un movimiento aleatorio
	if possible_moves.size() > 0:
		return possible_moves[randi() % possible_moves.size()]
	
	return null

func get_minimax_move(depth):
	var best_move = null
	var best_score = -9999
	var possible_moves = []
	
	# Encontrar todas las piezas de la IA y sus movimientos válidos
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece and piece.color == current_turn:
				var valid_moves = get_valid_moves(piece)
				for move in valid_moves:
					possible_moves.append({"piece": piece, "to": move})
	
	# Evaluar cada movimiento
	for move in possible_moves:
		var piece = move.piece
		var to_pos = move.to
		var from_pos = piece.board_position
		
		# Simular movimiento
		var captured = board[to_pos.x][to_pos.y]
		board[from_pos.x][from_pos.y] = null
		board[to_pos.x][to_pos.y] = piece
		
		# Evaluar tablero después del movimiento
		var score = -minimax(depth - 1, -10000, 10000, 1 - current_turn)
		
		# Revertir movimiento
		board[from_pos.x][from_pos.y] = piece
		board[to_pos.x][to_pos.y] = captured
		
		# Actualizar el mejor movimiento
		if score > best_score:
			best_score = score
			best_move = move
	
	return best_move

func minimax(depth, alpha, beta, color):
	# Si llegamos a la profundidad máxima, evaluar el tablero
	if depth == 0:
		return evaluate_board(color)
	
	# Si es jaque mate o tablas, retornar un valor extremo
	if is_checkmate(color):
		return -9000  # Perdió el color actual
	
	if is_stalemate(color):
		return 0  # Empate
	
	var possible_moves = []
	
	# Encontrar todas las piezas y sus movimientos válidos
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece and piece.color == color:
				var valid_moves = get_valid_moves(piece)
				for move in valid_moves:
					possible_moves.append({"piece": piece, "to": move})
	
	# Si no hay movimientos, retornar un valor de empate
	if possible_moves.size() == 0:
		return 0
	
	var best_score = -10000
	
	# Evaluar cada movimiento
	for move in possible_moves:
		var piece = move.piece
		var to_pos = move.to
		var from_pos = piece.board_position
		
		# Simular movimiento
		var captured = board[to_pos.x][to_pos.y]
		board[from_pos.x][from_pos.y] = null
		board[to_pos.x][to_pos.y] = piece
		
		# Recursión minimax con poda alfa-beta
		var score = -minimax(depth - 1, -beta, -alpha, 1 - color)
		
		# Revertir movimiento
		board[from_pos.x][from_pos.y] = piece
		board[to_pos.x][to_pos.y] = captured
		
		# Actualizar mejor puntuación
		best_score = max(best_score, score)
		alpha = max(alpha, score)
		
		# Poda alfa-beta
		if alpha >= beta:
			break
	
	return best_score

func evaluate_board(color):
	var score = 0
	
	# Sumar puntos por cada pieza según su valor
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece:
				var piece_value = piece_values[piece.type]
				var position_value = get_position_value(piece, Vector2(i, j))
				
				# Sumar para el color actual, restar para el oponente
				if piece.color == color:
					score += piece_value + position_value
				else:
					score -= piece_value + position_value
	
	# Bonus por jaque (ligero)
	if is_king_in_check(1 - color):
		score += 50
	
	# Bonus por movimientos disponibles (movilidad)
	var mobility = count_mobility(color) - count_mobility(1 - color)
	score += mobility * 10
	
	return score

func get_position_value(piece, pos):
	# Valor posicional según tabla de posición
	var table
	var x = pos.x
	var y = pos.y
	
	# Para piezas negras, invertir la tabla
	if piece.color == BLACK:
		y = 7 - y
	
	match piece.type:
		"pawn":
			table = pawn_table
		"knight":
			table = knight_table
		"bishop":
			table = bishop_table
		"rook":
			table = rook_table
		"queen":
			table = queen_table
		"king":
			table = king_table
		_:
			return 0
	
	return table[y][x]

func count_mobility(color):
	# Contar número total de movimientos disponibles
	var count = 0
	
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece and piece.color == color:
				count += get_valid_moves(piece).size()
	
	return count

# Funciones de señales
func _on_piece_moved(from_pos, to_pos, piece):
	# Implementar efectos o lógica adicional después de mover una pieza
	pass

func _on_piece_captured(piece):
	# Implementar efectos o lógica adicional después de capturar una pieza
	pass

func _on_turn_changed(turn):
	# Implementar efectos o lógica adicional al cambiar de turno
	pass

func _on_check_occurred(color):
	# Implementar efectos o lógica adicional cuando ocurre un jaque
	pass

func _on_checkmate_occurred(winner):
	# Implementar efectos o lógica adicional cuando ocurre un jaque mate
	pass

func _on_stalemate_occurred():
	# Implementar efectos o lógica adicional cuando ocurre un ahogado (tablas)
	pass

func _on_piece_selected(piece):
	# Callback para cuando se selecciona una pieza
	select_piece(piece)
