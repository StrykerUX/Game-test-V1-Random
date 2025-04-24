extends Control

# Variables para almacenar la configuración
var music_volume = 0.8
var sfx_volume = 0.8
var ai_difficulty = 1  # 0 = fácil, 1 = medio, 2 = difícil
var animation_speed = 1.0
var fullscreen = false

# Señales
signal settings_applied

func _ready():
	# Cargar configuración guardada
	load_settings()
	
	# Inicializar UI con los valores cargados
	$SettingsContainer/SoundSection/MusicVolume/Slider.value = music_volume
	$SettingsContainer/SoundSection/SfxVolume/Slider.value = sfx_volume
	$SettingsContainer/GameplaySection/AIDifficulty/OptionButton.selected = ai_difficulty
	$SettingsContainer/GameplaySection/AnimationSpeed/Slider.value = animation_speed
	$SettingsContainer/DisplaySection/Fullscreen/CheckBox.button_pressed = fullscreen

func load_settings():
	# Comprobar si existe el archivo de configuración
	if FileAccess.file_exists("user://settings.cfg"):
		var config = ConfigFile.new()
		var err = config.load("user://settings.cfg")
		
		if err == OK:
			music_volume = config.get_value("audio", "music_volume", 0.8)
			sfx_volume = config.get_value("audio", "sfx_volume", 0.8)
			ai_difficulty = config.get_value("gameplay", "ai_difficulty", 1)
			animation_speed = config.get_value("gameplay", "animation_speed", 1.0)
			fullscreen = config.get_value("display", "fullscreen", false)

func save_settings():
	var config = ConfigFile.new()
	
	# Guardar configuración de audio
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	
	# Guardar configuración de juego
	config.set_value("gameplay", "ai_difficulty", ai_difficulty)
	config.set_value("gameplay", "animation_speed", animation_speed)
	
	# Guardar configuración de pantalla
	config.set_value("display", "fullscreen", fullscreen)
	
	# Guardar el archivo
	config.save("user://settings.cfg")

func apply_settings():
	# Aplicar configuración de audio
	# En un juego completo, aquí configurarías los buses de AudioServer
	
	# Aplicar configuración de pantalla
	get_window().mode = Window.MODE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED
	
	# Emitir señal para que otros nodos actualicen su configuración
	emit_signal("settings_applied")
	
	# Guardar la configuración
	save_settings()

# Callbacks de eventos UI

func _on_music_volume_changed(value):
	music_volume = value

func _on_sfx_volume_changed(value):
	sfx_volume = value

func _on_ai_difficulty_changed(index):
	ai_difficulty = index

func _on_animation_speed_changed(value):
	animation_speed = value

func _on_fullscreen_toggled(button_pressed):
	fullscreen = button_pressed

func _on_apply_button_pressed():
	apply_settings()

func _on_back_button_pressed():
	# Guardar ajustes al salir
	save_settings()
	# Volver al menú principal
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
