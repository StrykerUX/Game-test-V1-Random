extends Node2D

# Script para manejar los efectos visuales durante el juego de ajedrez

# Referencias a nodos
var game
var board

# Constantes para efectos
const EFFECT_DURATION = 0.8
const PARTICLE_COUNT = 20
const COLOR_CAPTURE = Color(1, 0.2, 0.2, 0.8)
const COLOR_CASTLING = Color(0.2, 0.8, 1, 0.8)
const COLOR_CHECK = Color(1, 0.5, 0, 0.8)
const COLOR_CHECKMATE = Color(1, 0, 0, 0.9)
const COLOR_SPECIAL_MOVE = Color(0.5, 0.8, 0.2, 0.8)

func _ready():
	# Obtener referencias a nodos del juego
	game = get_parent()
	board = get_parent().get_node("ChessBoard")
	
	# Conectar señales del tablero
	board.connect("piece_moved", Callable(self, "_on_piece_moved"))
	board.connect("piece_captured", Callable(self, "_on_piece_captured"))
	board.connect("check_occurred", Callable(self, "_on_check_occurred"))
	board.connect("checkmate_occurred", Callable(self, "_on_checkmate_occurred"))
	board.connect("stalemate_occurred", Callable(self, "_on_stalemate_occurred"))

func _on_piece_moved(from_pos, to_pos, piece):
	# Detectar tipos especiales de movimientos
	
	# Enroque
	if piece.type == "king" and abs(from_pos.x - to_pos.x) == 2:
		show_castling_effect(from_pos, to_pos)
	
	# Movimiento de la reina
	elif piece.type == "queen":
		show_queen_move_effect(from_pos, to_pos)
	
	# Captura al paso
	elif piece.type == "pawn" and from_pos.x != to_pos.x and board.board[to_pos.x][to_pos.y] == null:
		show_en_passant_effect(from_pos, to_pos)
	
	# Promoción de peón
	elif piece.type == "pawn" and (to_pos.y == 0 or to_pos.y == 7):
		show_promotion_effect(to_pos)

func _on_piece_captured(piece):
	# Mostrar efecto de captura
	var pos = piece.board_position
	var pixel_pos = board.board_to_pixel(pos)
	
	# Efecto de explosión para capturas
	create_explosion_effect(pixel_pos, COLOR_CAPTURE)
	
	# Efecto especial si es una captura con la reina
	if board.last_move and board.last_move.piece.type == "queen":
		create_queen_capture_effect(pixel_pos)

func _on_check_occurred(color):
	# Mostrar efecto de jaque
	var king_pos = board.find_king(color)
	if king_pos:
		var pixel_pos = board.board_to_pixel(king_pos)
		create_check_effect(pixel_pos)

func _on_checkmate_occurred(winner):
	# Mostrar efecto de jaque mate
	var loser = 1 - winner  # El color opuesto al ganador
	var king_pos = board.find_king(loser)
	if king_pos:
		var pixel_pos = board.board_to_pixel(king_pos)
		create_checkmate_effect(pixel_pos)

func _on_stalemate_occurred():
	# Mostrar efecto de tablas por ahogado
	create_stalemate_effect()

# Funciones para crear los diferentes efectos

func show_castling_effect(from_pos, to_pos):
	# Efecto para el enroque
	var king_pos = board.board_to_pixel(to_pos)
	var rook_pos
	
	# Determinar qué tipo de enroque es (corto o largo)
	if to_pos.x > from_pos.x:  # Enroque corto
		rook_pos = board.board_to_pixel(Vector2(to_pos.x - 1, to_pos.y))
	else:  # Enroque largo
		rook_pos = board.board_to_pixel(Vector2(to_pos.x + 1, to_pos.y))
	
	# Crear efecto de brillo entre el rey y la torre
	create_line_effect(king_pos, rook_pos, COLOR_CASTLING)
	
	# Crear efecto de partículas
	create_explosion_effect(king_pos, COLOR_CASTLING)
	create_explosion_effect(rook_pos, COLOR_CASTLING)
	
	# Efecto de texto
	show_floating_text("¡Enroque!", king_pos, COLOR_CASTLING)

func show_queen_move_effect(from_pos, to_pos):
	# Efecto especial para movimientos de la reina
	var from_pixel = board.board_to_pixel(from_pos)
	var to_pixel = board.board_to_pixel(to_pos)
	
	# Crear efecto de línea brillante
	create_line_effect(from_pixel, to_pixel, Color(1, 0.5, 0.8, 0.7))
	
	# Efecto de brillo en la posición destino
	create_glow_effect(to_pixel, Color(1, 0.5, 0.8, 0.5))

func show_en_passant_effect(from_pos, to_pos):
	# Efecto para captura al paso
	var to_pixel = board.board_to_pixel(to_pos)
	var captured_pos = Vector2(to_pos.x, from_pos.y)
	var captured_pixel = board.board_to_pixel(captured_pos)
	
	# Crear efecto de línea entre el peón y la pieza capturada
	create_line_effect(to_pixel, captured_pixel, COLOR_SPECIAL_MOVE)
	
	# Efecto de explosión en la pieza capturada
	create_explosion_effect(captured_pixel, COLOR_SPECIAL_MOVE)
	
	# Texto explicativo
	show_floating_text("¡Captura al paso!", captured_pixel, COLOR_SPECIAL_MOVE)

func show_promotion_effect(pos):
	# Efecto para promoción de peón
	var pixel_pos = board.board_to_pixel(pos)
	
	# Crear efecto de brillo en la pieza
	create_glow_effect(pixel_pos, COLOR_SPECIAL_MOVE)
	
	# Efecto de partículas ascendentes
	create_rising_particles(pixel_pos, COLOR_SPECIAL_MOVE)
	
	# Texto explicativo
	show_floating_text("¡Promoción!", pixel_pos, COLOR_SPECIAL_MOVE)

func create_explosion_effect(position, color = COLOR_CAPTURE):
	# Crear efecto de explosión de partículas
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = PARTICLE_COUNT
	particles.lifetime = EFFECT_DURATION
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 5
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.gravity = Vector2(0, 98)
	particles.initial_velocity_min = 30
	particles.initial_velocity_max = 80
	particles.scale_amount = 3
	particles.color = color
	
	add_child(particles)
	
	# Eliminar después de que termine la animación
	await get_tree().create_timer(EFFECT_DURATION * 1.2).timeout
	particles.queue_free()

func create_line_effect(start_pos, end_pos, color):
	# Crear una línea brillante que conecta dos posiciones
	var line = Line2D.new()
	line.add_point(start_pos)
	line.add_point(end_pos)
	line.width = 5
	line.default_color = color
	
	add_child(line)
	
	# Animación de desvanecimiento
	var tween = create_tween()
	tween.tween_property(line, "modulate", Color(1, 1, 1, 0), EFFECT_DURATION)
	tween.tween_callback(Callable(line, "queue_free"))

func create_glow_effect(position, color):
	# Crear un efecto de brillo
	var glow = ColorRect.new()
	glow.size = Vector2(80, 80)
	glow.position = position - Vector2(40, 40)
	glow.color = color
	
	add_child(glow)
	
	# Animación de pulsación y desvanecimiento
	var tween = create_tween()
	tween.tween_property(glow, "size", Vector2(100, 100), EFFECT_DURATION / 2)
	tween.parallel().tween_property(glow, "position", position - Vector2(50, 50), EFFECT_DURATION / 2)
	tween.parallel().tween_property(glow, "color", Color(color.r, color.g, color.b, 0), EFFECT_DURATION)
	tween.tween_callback(Callable(glow, "queue_free"))

func create_rising_particles(position, color):
	# Crea partículas que suben
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.7
	particles.amount = PARTICLE_COUNT
	particles.lifetime = EFFECT_DURATION
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 5
	particles.direction = Vector2(0, -1)
	particles.spread = 30
	particles.gravity = Vector2(0, -50)
	particles.initial_velocity_min = 30
	particles.initial_velocity_max = 50
	particles.scale_amount = 3
	particles.color = color
	
	add_child(particles)
	
	# Eliminar después de que termine la animación
	await get_tree().create_timer(EFFECT_DURATION * 1.2).timeout
	particles.queue_free()

func create_queen_capture_effect(position):
	# Efecto especial cuando la reina captura
	create_explosion_effect(position, Color(1, 0, 0.8, 0.8))
	show_floating_text("¡Captura Real!", position, Color(1, 0, 0.8))
	
	# Crear ondas expansivas
	for i in range(3):
		var circle = create_circle(position, 5, Color(1, 0, 0.8, 0.8 - i * 0.2))
		var tween = create_tween()
		tween.tween_property(circle, "scale", Vector2(3, 3) * (i + 1), EFFECT_DURATION * 0.8)
		tween.parallel().tween_property(circle, "modulate", Color(1, 1, 1, 0), EFFECT_DURATION * 0.8)
		tween.tween_callback(Callable(circle, "queue_free"))
		await get_tree().create_timer(EFFECT_DURATION * 0.2).timeout

func create_check_effect(position):
	# Efecto para el jaque
	show_floating_text("¡JAQUE!", position, COLOR_CHECK)
	
	# Efecto de destello rojo en el rey
	var flash = ColorRect.new()
	flash.size = Vector2(80, 80)
	flash.position = position - Vector2(40, 40)
	flash.color = COLOR_CHECK
	
	add_child(flash)
	
	# Animación de destello
	var tween = create_tween()
	tween.tween_property(flash, "color", Color(COLOR_CHECK.r, COLOR_CHECK.g, COLOR_CHECK.b, 0), 0.3)
	tween.tween_property(flash, "color", COLOR_CHECK, 0.3)
	tween.tween_property(flash, "color", Color(COLOR_CHECK.r, COLOR_CHECK.g, COLOR_CHECK.b, 0), 0.3)
	tween.tween_callback(Callable(flash, "queue_free"))

func create_checkmate_effect(position):
	# Efecto para el jaque mate
	show_floating_text("¡JAQUE MATE!", position, COLOR_CHECKMATE, 32)
	
	# Gran explosión
	create_explosion_effect(position, COLOR_CHECKMATE)
	
	# Ondas expansivas
	for i in range(5):
		var circle = create_circle(position, 5, COLOR_CHECKMATE)
		var tween = create_tween()
		tween.tween_property(circle, "scale", Vector2(5, 5) * (i + 1), EFFECT_DURATION)
		tween.parallel().tween_property(circle, "modulate", Color(1, 1, 1, 0), EFFECT_DURATION)
		tween.tween_callback(Callable(circle, "queue_free"))
		await get_tree().create_timer(EFFECT_DURATION * 0.1).timeout
	
	# Partículas en todo el tablero
	for i in range(5):
		var rand_pos = Vector2(
			randf_range(-board.SQUARE_SIZE * 4, board.SQUARE_SIZE * 4),
			randf_range(-board.SQUARE_SIZE * 4, board.SQUARE_SIZE * 4)
		)
		create_explosion_effect(position + rand_pos, COLOR_CHECKMATE)
		await get_tree().create_timer(0.1).timeout

func create_stalemate_effect():
	# Efecto para el ahogado (tablas)
	var center_pos = Vector2(0, 0)  # Centro del tablero
	show_floating_text("¡TABLAS!", center_pos, Color(0.7, 0.7, 0.7), 32)
	
	# Efecto de desvanecimiento en el tablero
	var overlay = ColorRect.new()
	overlay.size = Vector2(board.SQUARE_SIZE * 8, board.SQUARE_SIZE * 8)
	overlay.position = center_pos - Vector2(board.SQUARE_SIZE * 4, board.SQUARE_SIZE * 4)
	overlay.color = Color(0.7, 0.7, 0.7, 0)
	
	add_child(overlay)
	
	# Animación de desvanecimiento
	var tween = create_tween()
	tween.tween_property(overlay, "color", Color(0.7, 0.7, 0.7, 0.5), EFFECT_DURATION)
	tween.tween_property(overlay, "color", Color(0.7, 0.7, 0.7, 0), EFFECT_DURATION)
	tween.tween_callback(Callable(overlay, "queue_free"))

func create_circle(position, radius, color):
	# Crear un círculo para efectos
	var circle = Node2D.new()
	circle.position = position
	
	add_child(circle)
	
	var draw_circle = func():
		var center = Vector2.ZERO
		var points = 32
		var arc_angle = 2 * PI
		var angle_offset = 0
		
		for i in range(points + 1):
			var angle = angle_offset + arc_angle * i / points
			var point = center + Vector2(cos(angle), sin(angle)) * radius
			if i == 0:
				circle.draw_line(point, point, color, 2)
			else:
				circle.draw_line(circle.get_point(i-1), point, color, 2)
	
	circle.draw = draw_circle
	
	return circle

func show_floating_text(text, position, color, font_size = 24):
	# Mostrar texto flotante
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.position = position - Vector2(label.size.x / 2, 20)
	
	add_child(label)
	
	# Animación de subida y desvanecimiento
	var tween = create_tween()
	tween.tween_property(label, "position", label.position - Vector2(0, 40), EFFECT_DURATION)
	tween.parallel().tween_property(label, "modulate", Color(1, 1, 1, 0), EFFECT_DURATION)
	tween.tween_callback(Callable(label, "queue_free"))
