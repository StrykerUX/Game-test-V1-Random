extends Control

func _ready():
	# Centrar la ventana en la pantalla
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_window().size
	get_window().position = screen_size / 2 - window_size / 2

func _on_play_single_button_pressed():
	# Cambiar a la escena del juego (vs IA)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	# El modo de juego se configurará en la escena del juego

func _on_play_local_button_pressed():
	# Cambiar a la escena del juego (local)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	# El modo de juego se configurará en la escena del juego

func _on_settings_button_pressed():
	# Cambiar a la escena de configuración
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_quit_button_pressed():
	# Salir del juego
	get_tree().quit()
