extends Node2D

# Variables de la pieza
var type = ""  # pawn, rook, knight, bishop, queen, king
var color = 0  # 0 = blanco, 1 = negro
var board_position = Vector2.ZERO
var selected = false

# Señales
signal piece_selected(piece)

func _ready():
	# Configurar señales y apariencia inicial
	pass

func setup(piece_type, piece_color):
	type = piece_type
	color = piece_color
	
	# Cargar sprite basado en el tipo y color
	load_sprite()

func load_sprite():
	# Intentar cargar la textura desde los recursos
	var texture_path = "res://assets/pieces/%s_%s.png" % [get_color_name(), type]
	var texture = load(texture_path)
	
	if texture:
		$Sprite.texture = texture
	else:
		# Si no hay textura, usar formas básicas para representar la pieza
		create_fallback_sprite()

func get_color_name():
	return "white" if color == 0 else "black"

func create_fallback_sprite():
	# Crear una representación básica si no hay sprites
	var size = 60
	var label = Label.new()
	label.text = get_symbol()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(size, size)
	label.add_theme_color_override("font_color", Color.BLACK if color == 0 else Color.WHITE)
	
	var bg = ColorRect.new()
	bg.size = Vector2(size, size)
	bg.position = Vector2(-size/2, -size/2)
	bg.color = Color.WHITE if color == 0 else Color.DARK_GRAY
	
	add_child(bg)
	add_child(label)

func get_symbol():
	# Símbolo Unicode para representar las piezas
	var symbols = {
		"pawn": "♙♟",
		"rook": "♖♜",
		"knight": "♘♞",
		"bishop": "♗♝",
		"queen": "♕♛",
		"king": "♔♚"
	}
	
	var symbol_pair = symbols[type]
	return symbol_pair[color]

func select():
	selected = true
	$SelectionIndicator.visible = true
	# Emitir señal para informar al tablero
	emit_signal("piece_selected", self)

func deselect():
	selected = false
	$SelectionIndicator.visible = false

func _on_input_event(_viewport, event, _shape_idx):
	# Manejar eventos de entrada si queremos que las piezas sean clickeables directamente
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select()
