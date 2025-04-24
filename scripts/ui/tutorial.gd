extends Control

# Constantes para el tamaño del tablero
const BOARD_SIZE = 8
const SQUARE_SIZE = 60
const WHITE = 0
const BLACK = 1

# Variables para el tutorial
var current_lesson = 0
var current_step = 0
var lessons = []
var board = []
var piece_scene = preload("res://scenes/chess_piece.tscn")

func _ready():
	# Inicializar el tablero
	initialize_board()
	
	# Definir las lecciones
	setup_lessons()
	
	# Comenzar con el tutorial vacío
	$ContentContainer/InfoPanel/Description.text = "Selecciona una lección para comenzar."
	
	# Desactivar botones de navegación al inicio
	update_navigation_buttons()

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
		$ContentContainer/BoardContainer/ChessBoard/BoardSprite.texture = board_texture
		$ContentContainer/BoardContainer/ChessBoard/BoardSprite.scale = Vector2(SQUARE_SIZE * 8 / board_texture.get_width(), 
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
			
			$ContentContainer/BoardContainer/ChessBoard.add_child(square)

func create_piece(type, color, board_pos):
	# Crea una pieza en la posición del tablero especificada
	var piece = piece_scene.instantiate()
	piece.setup(type, color)
	piece.board_position = board_pos
	piece.position = board_to_pixel(board_pos)
	
	$ContentContainer/BoardContainer/ChessBoard/Pieces.add_child(piece)
	board[board_pos.x][board_pos.y] = piece
	
	return piece

func board_to_pixel(board_pos):
	# Convierte posición del tablero (0-7, 0-7) a posición en píxeles
	var x = (board_pos.x - BOARD_SIZE/2) * SQUARE_SIZE + SQUARE_SIZE/2
	var y = (board_pos.y - BOARD_SIZE/2) * SQUARE_SIZE + SQUARE_SIZE/2
	return Vector2(x, y)

func clear_board():
	# Eliminar todas las piezas del tablero
	for child in $ContentContainer/BoardContainer/ChessBoard/Pieces.get_children():
		child.queue_free()
	
	# Resetear matriz del tablero
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			board[i][j] = null
	
	# Eliminar todos los destacados
	for child in $ContentContainer/BoardContainer/ChessBoard/Highlights.get_children():
		child.queue_free()

func highlight_square(board_pos, color = Color(0, 1, 0, 0.3)):
	# Resaltar una casilla específica del tablero
	var highlight = ColorRect.new()
	highlight.size = Vector2(SQUARE_SIZE, SQUARE_SIZE)
	highlight.position = board_to_pixel(board_pos) - Vector2(SQUARE_SIZE/2, SQUARE_SIZE/2)
	highlight.color = color
	$ContentContainer/BoardContainer/ChessBoard/Highlights.add_child(highlight)

func setup_lessons():
	# Lección 1: Movimientos básicos
	var lesson1 = {
		"title": "Movimientos básicos",
		"steps": [
			{
				"description": "[b]Movimiento del peón[/b]\n\nLos peones se mueven hacia adelante 1 casilla. Desde su posición inicial pueden avanzar 2 casillas.\n\nLos peones capturan en diagonal.",
				"board_setup": funcref(self, "setup_pawn_lesson")
			},
			{
				"description": "[b]Movimiento de la torre[/b]\n\nLas torres se mueven en línea recta horizontal o vertical, tantas casillas como desees.",
				"board_setup": funcref(self, "setup_rook_lesson")
			},
			{
				"description": "[b]Movimiento del caballo[/b]\n\nLos caballos se mueven en forma de 'L': 2 casillas en una dirección y luego 1 casilla perpendicular.\n\nEs la única pieza que puede saltar sobre otras.",
				"board_setup": funcref(self, "setup_knight_lesson")
			},
			{
				"description": "[b]Movimiento del alfil[/b]\n\nLos alfiles se mueven en diagonal, tantas casillas como desees.",
				"board_setup": funcref(self, "setup_bishop_lesson")
			},
			{
				"description": "[b]Movimiento de la reina[/b]\n\nLa reina combina los movimientos de la torre y el alfil: puede moverse en línea recta o en diagonal, tantas casillas como desees.",
				"board_setup": funcref(self, "setup_queen_lesson")
			},
			{
				"description": "[b]Movimiento del rey[/b]\n\nEl rey se mueve 1 casilla en cualquier dirección.",
				"board_setup": funcref(self, "setup_king_lesson")
			}
		]
	}
	
	# Lección 2: Enroque
	var lesson2 = {
		"title": "Enroque",
		"steps": [
			{
				"description": "[b]Enroque[/b]\n\nEs un movimiento especial que involucra al rey y a una torre.\n\nEl rey se mueve 2 casillas hacia la torre y la torre salta sobre el rey al otro lado.",
				"board_setup": funcref(self, "setup_castling_lesson_1")
			},
			{
				"description": "[b]Condiciones para el enroque[/b]\n\n1. El rey y la torre no deben haberse movido.\n2. No debe haber piezas entre el rey y la torre.\n3. El rey no debe estar en jaque.\n4. El rey no debe pasar por casillas atacadas.",
				"board_setup": funcref(self, "setup_castling_lesson_2")
			},
			{
				"description": "[b]Tipos de enroque[/b]\n\n- Enroque corto (hacia el flanco de rey)\n- Enroque largo (hacia el flanco de dama)\n\nAmbos tipos de enroque mueven al rey 2 casillas.",
				"board_setup": funcref(self, "setup_castling_lesson_3")
			}
		]
	}
	
	# Lección 3: Captura al paso
	var lesson3 = {
		"title": "Captura al paso (En passant)",
		"steps": [
			{
				"description": "[b]Captura al paso[/b]\n\nEs un movimiento especial del peón.\n\nSi un peón avanza 2 casillas desde su posición inicial y queda junto a un peón enemigo, este último puede capturarlo 'al paso', como si hubiera avanzado solo 1 casilla.",
				"board_setup": funcref(self, "setup_en_passant_lesson_1")
			},
			{
				"description": "[b]Condiciones para la captura al paso[/b]\n\n1. Solo puede realizarse inmediatamente después de que el peón enemigo avance 2 casillas.\n2. Si no se realiza inmediatamente, se pierde la oportunidad.",
				"board_setup": funcref(self, "setup_en_passant_lesson_2")
			}
		]
	}
	
	# Lección 4: Promoción de peón
	var lesson4 = {
		"title": "Promoción de peón",
		"steps": [
			{
				"description": "[b]Promoción de peón[/b]\n\nCuando un peón llega a la última fila del tablero, se 'promociona' y debe ser sustituido por una dama, torre, alfil o caballo del mismo color, según la elección del jugador.",
				"board_setup": funcref(self, "setup_promotion_lesson_1")
			},
			{
				"description": "[b]Estrategia de promoción[/b]\n\nNormalmente se elige la dama por ser la pieza más poderosa, pero a veces puede ser útil elegir otra pieza (como un caballo) para evitar un jaque mate por ahogado.",
				"board_setup": funcref(self, "setup_promotion_lesson_2")
			}
		]
	}
	
	# Lección 5: Jaque y jaque mate
	var lesson5 = {
		"title": "Jaque y jaque mate",
		"steps": [
			{
				"description": "[b]Jaque[/b]\n\nUn rey está en jaque cuando está amenazado por una pieza enemiga. El jugador debe mover el rey, capturar la pieza atacante o interponer una pieza.",
				"board_setup": funcref(self, "setup_check_lesson")
			},
			{
				"description": "[b]Jaque mate[/b]\n\nEl jaque mate ocurre cuando un rey está en jaque y no puede escapar de la amenaza. El juego termina con la victoria del jugador que da jaque mate.",
				"board_setup": funcref(self, "setup_checkmate_lesson")
			},
			{
				"description": "[b]Tablas por ahogado[/b]\n\nLas tablas por ahogado ocurren cuando un jugador no está en jaque pero no tiene movimientos legales disponibles. El juego termina en empate.",
				"board_setup": funcref(self, "setup_stalemate_lesson")
			}
		]
	}
	
	# Añadir todas las lecciones al array
	lessons = [lesson1, lesson2, lesson3, lesson4, lesson5]

# Funciones para configurar el tablero en cada lección
func setup_pawn_lesson():
	clear_board()
	
	# Crear peones para mostrar movimiento
	create_piece("pawn", WHITE, Vector2(3, 6))
	create_piece("pawn", WHITE, Vector2(4, 4))
	create_piece("pawn", BLACK, Vector2(3, 3))
	create_piece("pawn", BLACK, Vector2(5, 3))
	
	# Resaltar casillas para movimiento de peón blanco inicial
	highlight_square(Vector2(3, 5), Color(0, 0.7, 0, 0.3))
	highlight_square(Vector2(3, 4), Color(0, 0.7, 0, 0.3))
	
	# Resaltar casillas para movimiento de peón blanco avanzado
	highlight_square(Vector2(4, 3), Color(0, 0.7, 0, 0.3))
	
	# Resaltar capturas de peón
	highlight_square(Vector2(3, 3), Color(1, 0, 0, 0.3))
	highlight_square(Vector2(5, 3), Color(1, 0, 0, 0.3))

func setup_rook_lesson():
	clear_board()
	
	# Crear torre en el centro
	create_piece("rook", WHITE, Vector2(3, 3))
	
	# Crear algunas piezas para limitar movimiento
	create_piece("pawn", BLACK, Vector2(3, 1))
	create_piece("pawn", WHITE, Vector2(5, 3))
	
	# Resaltar casillas de movimiento
	for i in range(8):
		if i != 3:
			if i > 3 and i < 5:  # Posición vertical disponible
				highlight_square(Vector2(3, i))
			elif i < 3:  # Posición vertical bloqueada por peón negro
				highlight_square(Vector2(3, i), Color(0.7, 0.7, 0, 0.3))
		
		if i != 3:
			if i < 5:  # Posición horizontal disponible
				highlight_square(Vector2(i, 3))
			elif i > 3:  # Posición horizontal bloqueada por peón blanco
				highlight_square(Vector2(i, 3), Color(0.7, 0.7, 0, 0.3))

func setup_knight_lesson():
	clear_board()
	
	# Crear caballo en el centro
	create_piece("knight", WHITE, Vector2(4, 4))
	
	# Crear algunas piezas para mostrar que puede saltar
	create_piece("pawn", WHITE, Vector2(3, 4))
	create_piece("pawn", BLACK, Vector2(5, 4))
	create_piece("pawn", WHITE, Vector2(4, 3))
	create_piece("pawn", BLACK, Vector2(4, 5))
	
	# Resaltar casillas de movimiento
	highlight_square(Vector2(2, 3))
	highlight_square(Vector2(2, 5))
	highlight_square(Vector2(3, 2))
	highlight_square(Vector2(3, 6))
	highlight_square(Vector2(5, 2))
	highlight_square(Vector2(5, 6))
	highlight_square(Vector2(6, 3))
	highlight_square(Vector2(6, 5))

func setup_bishop_lesson():
	clear_board()
	
	# Crear alfil en el centro
	create_piece("bishop", WHITE, Vector2(4, 4))
	
	# Crear algunas piezas para limitar movimiento
	create_piece("pawn", BLACK, Vector2(2, 2))
	create_piece("pawn", WHITE, Vector2(6, 6))
	
	# Resaltar casillas para movimiento diagonal
	for i in range(1, 8):
		if 4-i >= 0 and 4-i < 8:
			if 4-i > 2:  # Diagonal inferior izquierda
				highlight_square(Vector2(4-i, 4-i))
		
		if 4+i < 8:
			if 4+i < 6:  # Diagonal superior derecha
				highlight_square(Vector2(4+i, 4+i))
		
		if 4-i >= 0 and 4+i < 8:
			highlight_square(Vector2(4-i, 4+i))
		
		if 4+i < 8 and 4-i >= 0:
			highlight_square(Vector2(4+i, 4-i))

func setup_queen_lesson():
	clear_board()
	
	# Crear reina en el centro
	create_piece("queen", WHITE, Vector2(4, 4))
	
	# Crear algunas piezas para limitar movimiento
	create_piece("pawn", BLACK, Vector2(4, 1))
	create_piece("pawn", WHITE, Vector2(7, 4))
	
	# Resaltar casillas para movimiento (combinación de torre y alfil)
	# Movimiento horizontal
	for i in range(8):
		if i != 4:
			if i < 7:  # Posición horizontal disponible
				highlight_square(Vector2(i, 4))
	
	# Movimiento vertical
	for i in range(8):
		if i != 4:
			if i > 1:  # Posición vertical disponible
				highlight_square(Vector2(4, i))
	
	# Movimiento diagonal (como el alfil)
	for i in range(1, 8):
		if 4-i >= 0 and 4-i < 8:
			highlight_square(Vector2(4-i, 4-i))
		
		if 4+i < 8:
			highlight_square(Vector2(4+i, 4+i))
		
		if 4-i >= 0 and 4+i < 8:
			highlight_square(Vector2(4-i, 4+i))
		
		if 4+i < 8 and 4-i >= 0:
			highlight_square(Vector2(4+i, 4-i))

func setup_king_lesson():
	clear_board()
	
	# Crear rey en el centro
	create_piece("king", WHITE, Vector2(4, 4))
	
	# Resaltar casillas para movimiento del rey (1 casilla en todas direcciones)
	highlight_square(Vector2(3, 3))
	highlight_square(Vector2(3, 4))
	highlight_square(Vector2(3, 5))
	highlight_square(Vector2(4, 3))
	highlight_square(Vector2(4, 5))
	highlight_square(Vector2(5, 3))
	highlight_square(Vector2(5, 4))
	highlight_square(Vector2(5, 5))

func setup_castling_lesson_1():
	clear_board()
	
	# Crear rey y torres en posición inicial
	create_piece("king", WHITE, Vector2(4, 7))
	create_piece("rook", WHITE, Vector2(0, 7))  # Torre para enroque largo
	create_piece("rook", WHITE, Vector2(7, 7))  # Torre para enroque corto
	
	# Resaltar casillas de enroque
	highlight_square(Vector2(2, 7), Color(0, 0.7, 0.7, 0.3))  # Posición final del rey (enroque largo)
	highlight_square(Vector2(3, 7), Color(0, 0.7, 0.7, 0.3))  # Posición final de la torre (enroque largo)
	
	highlight_square(Vector2(6, 7), Color(0, 0.7, 0, 0.3))  # Posición final del rey (enroque corto)
	highlight_square(Vector2(5, 7), Color(0, 0.7, 0, 0.3))  # Posición final de la torre (enroque corto)

func setup_castling_lesson_2():
	clear_board()
	
	# Configuración para mostrar condiciones de enroque
	create_piece("king", WHITE, Vector2(4, 7))
	create_piece("rook", WHITE, Vector2(0, 7))  # Torre para enroque largo
	create_piece("rook", WHITE, Vector2(7, 7))  # Torre para enroque corto
	
	# Añadir piezas que bloquean enroque largo
	create_piece("bishop", WHITE, Vector2(2, 7))
	
	# Resaltar casillas de enroque válido (solo corto)
	highlight_square(Vector2(6, 7), Color(0, 0.7, 0, 0.3))
	highlight_square(Vector2(5, 7), Color(0, 0.7, 0, 0.3))
	
	# Mostrar razón por la que no se puede enrocar largo
	highlight_square(Vector2(2, 7), Color(1, 0, 0, 0.3))

func setup_castling_lesson_3():
	clear_board()
	
	# Configuración para mostrar ambos tipos de enroque
	create_piece("king", WHITE, Vector2(4, 7))
	create_piece("rook", WHITE, Vector2(0, 7))  # Torre para enroque largo
	create_piece("rook", WHITE, Vector2(7, 7))  # Torre para enroque corto
	
	# Piezas negras atacando
	create_piece("rook", BLACK, Vector2(3, 0))  # Atacando la casilla de paso del enroque largo
	
	# Resaltar enroque corto (disponible)
	highlight_square(Vector2(6, 7), Color(0, 0.7, 0, 0.3))  # Posición final del rey
	highlight_square(Vector2(5, 7), Color(0, 0.7, 0, 0.3))  # Posición final de la torre
	
	# Mostrar por qué no se puede enrocar largo
	highlight_square(Vector2(3, 7), Color(1, 0, 0, 0.3))  # Casilla bajo ataque

func setup_en_passant_lesson_1():
	clear_board()
	
	# Configuración para captura al paso
	create_piece("pawn", WHITE, Vector2(3, 3))
	create_piece("pawn", BLACK, Vector2(4, 1))  # Peón que avanzará 2 casillas
	
	# Crear flechas para indicar movimiento
	# Godot 4 no soporta Drawing2D directamente, tendríamos que usar Line2D o Polygon2D
	
	# Resaltar el movimiento del peón negro
	highlight_square(Vector2(4, 3), Color(0, 0, 1, 0.3))
	
	# Resaltar la captura al paso
	highlight_square(Vector2(4, 2), Color(1, 0, 0, 0.3))

func setup_en_passant_lesson_2():
	clear_board()
	
	# Configuración para mostrar la limitación temporal
	create_piece("pawn", WHITE, Vector2(3, 3))
	create_piece("pawn", BLACK, Vector2(4, 3))  # Peón que ya ha avanzado 2 casillas
	
	# Añadir texto en la escena que indica "Movimiento anterior"
	var label = Label.new()
	label.text = "Último movimiento: peón negro de d7 a d5"
	label.position = Vector2(50, 50)
	$ContentContainer/BoardContainer/ChessBoard/Highlights.add_child(label)
	
	# Resaltar la captura al paso
	highlight_square(Vector2(4, 2), Color(1, 0, 0, 0.3))

func setup_promotion_lesson_1():
	clear_board()
	
	# Configuración para promoción
	create_piece("pawn", WHITE, Vector2(3, 1))  # Peón a punto de promocionar
	
	# Resaltar la casilla de promoción
	highlight_square(Vector2(3, 0), Color(0, 0.7, 0, 0.3))
	
	# Mostrar las opciones de promoción
	create_piece("queen", WHITE, Vector2(5, 2))
	create_piece("rook", WHITE, Vector2(5, 3))
	create_piece("bishop", WHITE, Vector2(5, 4))
	create_piece("knight", WHITE, Vector2(5, 5))

func setup_promotion_lesson_2():
	clear_board()
	
	# Configuración para caso especial de promoción
	create_piece("king", BLACK, Vector2(7, 0))
	create_piece("pawn", WHITE, Vector2(6, 1))  # Peón a punto de promocionar
	
	# Resaltar la casilla de promoción
	highlight_square(Vector2(6, 0), Color(0, 0.7, 0, 0.3))
	
	# Mostrar las opciones de promoción
	create_piece("queen", WHITE, Vector2(1, 2))
	highlight_square(Vector2(1, 2), Color(1, 0, 0, 0.3))  # Rojo para indicar que causaría ahogado
	
	create_piece("knight", WHITE, Vector2(3, 2))
	highlight_square(Vector2(3, 2), Color(0, 0.7, 0, 0.3))  # Verde para indicar buena elección

func setup_check_lesson():
	clear_board()
	
	# Configuración para jaque
	create_piece("king", WHITE, Vector2(4, 7))
	create_piece("queen", BLACK, Vector2(4, 5))  # Reina dando jaque
	
	# Resaltar el rey en jaque
	highlight_square(Vector2(4, 7), Color(1, 0, 0, 0.3))
	
	# Resaltar opciones para salir del jaque
	highlight_square(Vector2(3, 7), Color(0, 0.7, 0, 0.3))  # Mover rey
	highlight_square(Vector2(5, 7), Color(0, 0.7, 0, 0.3))  # Mover rey
	highlight_square(Vector2(4, 6), Color(0, 0.7, 0.7, 0.3))  # Interponer pieza
	highlight_square(Vector2(4, 5), Color(0, 0.7, 0, 0.3))  # Capturar atacante

func setup_checkmate_lesson():
	clear_board()
	
	# Configuración para jaque mate
	create_piece("king", WHITE, Vector2(7, 7))
	create_piece("queen", BLACK, Vector2(7, 5))  # Reina dando jaque
	create_piece("rook", BLACK, Vector2(6, 0))  # Torre bloqueando escape
	
	# Resaltar el rey en jaque mate
	highlight_square(Vector2(7, 7), Color(1, 0, 0, 0.5))
	
	# Resaltar las casillas que cubren el escape
	highlight_square(Vector2(7, 6), Color(1, 0, 0, 0.3))
	highlight_square(Vector2(6, 6), Color(1, 0, 0, 0.3))
	highlight_square(Vector2(6, 7), Color(1, 0, 0, 0.3))

func setup_stalemate_lesson():
	clear_board()
	
	# Configuración para ahogado
	create_piece("king", BLACK, Vector2(7, 7))
	create_piece("queen", WHITE, Vector2(5, 6))  # Reina controlando casillas
	
	# Resaltar el rey ahogado
	highlight_square(Vector2(7, 7), Color(0.7, 0.7, 0, 0.3))
	
	# Resaltar las casillas controladas que causan el ahogado
	highlight_square(Vector2(7, 6), Color(1, 0, 0, 0.3))
	highlight_square(Vector2(6, 6), Color(1, 0, 0, 0.3))
	highlight_square(Vector2(6, 7), Color(1, 0, 0, 0.3))

func start_lesson(lesson_index):
	if lesson_index >= 0 and lesson_index < lessons.size():
		current_lesson = lesson_index
		current_step = 0
		show_current_step()
		update_navigation_buttons()

func show_current_step():
	if current_lesson >= 0 and current_lesson < lessons.size():
		var lesson = lessons[current_lesson]
		
		if current_step >= 0 and current_step < lesson.steps.size():
			var step = lesson.steps[current_step]
			
			# Actualizar descripción
			$ContentContainer/InfoPanel/Description.text = step.description
			
			# Configurar tablero para esta lección
			step.board_setup.call_func()

func update_navigation_buttons():
	# Desactivar botón "Anterior" si estamos en el primer paso
	$ContentContainer/InfoPanel/NavigationContainer/PrevButton.disabled = (current_step <= 0)
	
	# Desactivar botón "Siguiente" si estamos en el último paso
	var last_step = false
	if current_lesson >= 0 and current_lesson < lessons.size():
		last_step = (current_step >= lessons[current_lesson].steps.size() - 1)
	
	$ContentContainer/InfoPanel/NavigationContainer/NextButton.disabled = last_step

# Funciones de eventos

func _on_lesson1_pressed():
	start_lesson(0)

func _on_lesson2_pressed():
	start_lesson(1)

func _on_lesson3_pressed():
	start_lesson(2)

func _on_lesson4_pressed():
	start_lesson(3)

func _on_lesson5_pressed():
	start_lesson(4)

func _on_prev_button_pressed():
	if current_step > 0:
		current_step -= 1
		show_current_step()
		update_navigation_buttons()

func _on_next_button_pressed():
	if current_lesson >= 0 and current_lesson < lessons.size():
		if current_step < lessons[current_lesson].steps.size() - 1:
			current_step += 1
			show_current_step()
			update_navigation_buttons()

func _on_reset_button_pressed():
	show_current_step()

func _on_back_button_pressed():
	# Volver al menú principal
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
