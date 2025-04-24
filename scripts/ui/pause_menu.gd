extends Control

func _ready():
	# Pausar el juego al mostrar el menú
	get_tree().paused = true

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Tecla Escape
		_on_resume_button_pressed()

func _on_resume_button_pressed():
	# Reanudar el juego
	get_tree().paused = false
	queue_free()

func _on_save_button_pressed():
	# Mostrar diálogo de guardado
	# En una implementación completa, aquí mostrarías un diálogo para nombrar la partida
	save_game("partida_guardada")

func _on_load_button_pressed():
	# Mostrar diálogo de carga
	# En una implementación completa, aquí mostrarías un diálogo para seleccionar la partida
	load_game("partida_guardada")

func _on_settings_button_pressed():
	# Ir a la pantalla de configuración
	# Primero despausa el juego para permitir la navegación
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_main_menu_button_pressed():
	# Mostrar diálogo de confirmación
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Volver al Menú Principal"
	confirm_dialog.dialog_text = "¿Estás seguro de que quieres volver al menú principal? Perderás el progreso no guardado."
	confirm_dialog.get_ok_button().text = "Sí"
	confirm_dialog.get_cancel_button().text = "No"
	confirm_dialog.connect("confirmed", Callable(self, "_confirm_main_menu"))
	
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _confirm_main_menu():
	# Volver al menú principal
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func save_game(save_name):
	# Implementación básica de guardado
	var save_game = FileAccess.open("user://" + save_name + ".save", FileAccess.WRITE)
	
	# Obtener el nodo del tablero
	var board = get_node("/root/Game/ChessBoard")
	
	# Crear un diccionario con los datos a guardar
	var save_data = {
		"current_turn": board.current_turn,
		"board_state": get_board_state(board),
		"move_history": board.move_history
	}
	
	# Guardar como JSON
	save_game.store_line(JSON.stringify(save_data))
	
	# Notificar al usuario
	var notification = Label.new()
	notification.text = "Partida guardada correctamente"
	notification.add_theme_font_size_override("font_size", 20)
	notification.position = Vector2(400, 600)
	notification.modulate = Color(1, 1, 1, 1)
	
	add_child(notification)
	
	# Animación de desvanecimiento
	var tween = create_tween()
	tween.tween_property(notification, "modulate", Color(1, 1, 1, 0), 2.0)
	tween.tween_callback(Callable(notification, "queue_free"))

func load_game(save_name):
	# Verificar si existe el archivo de guardado
	if not FileAccess.file_exists("user://" + save_name + ".save"):
		# Notificar al usuario que no hay partida guardada
		var notification = Label.new()
		notification.text = "No se encontró ninguna partida guardada"
		notification.add_theme_font_size_override("font_size", 20)
		notification.position = Vector2(400, 600)
		
		add_child(notification)
		
		# Animación de desvanecimiento
		var tween = create_tween()
		tween.tween_property(notification, "modulate", Color(1, 1, 1, 0), 2.0)
		tween.tween_callback(Callable(notification, "queue_free"))
		
		return
	
	# Cargar el archivo de guardado
	var save_game = FileAccess.open("user://" + save_name + ".save", FileAccess.READ)
	var json_string = save_game.get_line()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Error al analizar el archivo de guardado")
		return
	
	var save_data = json.get_data()
	
	# Reiniciar la escena del juego
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
	# Esperar a que se cargue la escena
	await get_tree().process_frame
	
	# Obtener el nodo del tablero
	var board = get_node("/root/Game/ChessBoard")
	
	# Restaurar el estado del tablero (esto requeriría una implementación completa)
	# Esta es una simplificación
	board.current_turn = save_data.current_turn
	board.move_history = save_data.move_history
	restore_board_state(board, save_data.board_state)
	
	# Notificar al usuario
	var notification = Label.new()
	notification.text = "Partida cargada correctamente"
	notification.add_theme_font_size_override("font_size", 20)
	notification.position = Vector2(400, 600)
	
	get_node("/root/Game").add_child(notification)
	
	# Animación de desvanecimiento
	var tween = create_tween()
	tween.tween_property(notification, "modulate", Color(1, 1, 1, 0), 2.0)
	tween.tween_callback(Callable(notification, "queue_free"))
	
	# Destruir el menú de pausa
	queue_free()

func get_board_state(board):
	# Crear una representación del estado del tablero para guardar
	var state = []
	
	for i in range(board.BOARD_SIZE):
		var row = []
		for j in range(board.BOARD_SIZE):
			var piece = board.board[i][j]
			if piece:
				row.append({
					"type": piece.type,
					"color": piece.color,
					"position": {"x": i, "y": j}
				})
			else:
				row.append(null)
		state.append(row)
	
	return state

func restore_board_state(board, state):
	# Limpiar el tablero actual
	for i in range(board.BOARD_SIZE):
		for j in range(board.BOARD_SIZE):
			if board.board[i][j]:
				board.board[i][j].queue_free()
			board.board[i][j] = null
	
	# Recrear las piezas según el estado guardado
	for i in range(board.BOARD_SIZE):
		for j in range(board.BOARD_SIZE):
			var piece_data = state[i][j]
			if piece_data:
				var piece = board.create_piece(piece_data.type, piece_data.color, Vector2(i, j))
