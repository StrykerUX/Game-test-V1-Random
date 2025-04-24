extends Control

# Variables globales
var ai_difficulty = 1  # 0 = fácil, 1 = medio, 2 = difícil

func _ready():
	# Centrar la ventana en la pantalla
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_window().size
	get_window().position = screen_size / 2 - window_size / 2
	
	# Cargar configuración guardada
	load_settings()
	
	# Ocultar panel de dificultad al inicio
	$DifficultyPanel.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel") and $DifficultyPanel.visible:
		$DifficultyPanel.visible = false

func load_settings():
	# Comprobar si existe el archivo de configuración
	if FileAccess.file_exists("user://settings.cfg"):
		var config = ConfigFile.new()
		var err = config.load("user://settings.cfg")
		
		if err == OK:
			ai_difficulty = config.get_value("gameplay", "ai_difficulty", 1)

func save_settings():
	var config = ConfigFile.new()
	
	# Cargar configuración existente si existe
	if FileAccess.file_exists("user://settings.cfg"):
		config.load("user://settings.cfg")
	
	# Guardar configuración de juego
	config.set_value("gameplay", "ai_difficulty", ai_difficulty)
	
	# Guardar el archivo
	config.save("user://settings.cfg")

func _on_play_single_button_pressed():
	# Cambiar a la escena del juego (vs IA)
	var game_scene = load("res://scenes/game.tscn").instantiate()
	
	# Configurar modo de juego
	game_scene.ai_enabled = true
	game_scene.ai_difficulty = ai_difficulty
	
	# Cambiar escena
	get_tree().root.add_child(game_scene)
	get_tree().current_scene = game_scene
	queue_free()

func _on_play_local_button_pressed():
	# Cambiar a la escena del juego (local)
	var game_scene = load("res://scenes/game.tscn").instantiate()
	
	# Configurar modo de juego
	game_scene.ai_enabled = false
	
	# Cambiar escena
	get_tree().root.add_child(game_scene)
	get_tree().current_scene = game_scene
	queue_free()

func _on_difficulty_button_pressed():
	# Mostrar panel de dificultad
	$DifficultyPanel.visible = true
	
	# Marcar visualmente la dificultad actual
	update_difficulty_buttons()

func _on_tutorial_button_pressed():
	# Cambiar a la escena de tutorial
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_settings_button_pressed():
	# Cambiar a la escena de configuración
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_quit_button_pressed():
	# Salir del juego
	get_tree().quit()

func _on_easy_button_pressed():
	ai_difficulty = 0
	save_settings()
	update_difficulty_buttons()
	$DifficultyPanel.visible = false

func _on_medium_button_pressed():
	ai_difficulty = 1
	save_settings()
	update_difficulty_buttons()
	$DifficultyPanel.visible = false

func _on_hard_button_pressed():
	ai_difficulty = 2
	save_settings()
	update_difficulty_buttons()
	$DifficultyPanel.visible = false

func _on_difficulty_back_button_pressed():
	$DifficultyPanel.visible = false

func update_difficulty_buttons():
	# Resetear visual de todos los botones
	$DifficultyPanel/VBoxContainer/EasyButton.modulate = Color(1, 1, 1, 1)
	$DifficultyPanel/VBoxContainer/MediumButton.modulate = Color(1, 1, 1, 1)
	$DifficultyPanel/VBoxContainer/HardButton.modulate = Color(1, 1, 1, 1)
	
	# Resaltar botón seleccionado
	match ai_difficulty:
		0:
			$DifficultyPanel/VBoxContainer/EasyButton.modulate = Color(0.8, 1, 0.8, 1)
		1:
			$DifficultyPanel/VBoxContainer/MediumButton.modulate = Color(0.8, 1, 0.8, 1)
		2:
			$DifficultyPanel/VBoxContainer/HardButton.modulate = Color(0.8, 1, 0.8, 1)
