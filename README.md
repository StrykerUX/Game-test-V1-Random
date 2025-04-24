# Game-test-V1-Random (Anime Chess)

Un juego de ajedrez con temática de anime desarrollado en Godot Engine 4.2.

## Estado Actual del Proyecto

Este es un proyecto en fase inicial que incluye:

- ✅ Estructura completa del proyecto Godot
- ✅ Lógica básica de ajedrez (movimientos de piezas, capturas, detección de jaque/mate)
- ✅ Implementación de interfaz de usuario (menú principal, pantalla de juego, configuración)
- ✅ Sistema básico de guardado/carga de partidas
- ✅ Modo IA básica (movimientos aleatorios)
- ⚠️ No incluye assets gráficos (imágenes de piezas, tablero) - se deben añadir manualmente
- ⚠️ No incluye recursos de audio - se deben añadir manualmente

## Descripción

Este proyecto implementa un juego de ajedrez tradicional con espacio para un diseño visual inspirado en personajes de anime. El código base está completo, pero requiere que añadas tus propios assets gráficos para las piezas con temática de anime.

## Características Implementadas

- **Lógica de ajedrez**:
  - Movimientos legales para todas las piezas
  - Sistema de turnos
  - Detección de jaque y jaque mate
  - Detección de tablas por ahogado

- **Interfaces**:
  - Menú principal funcional
  - Pantalla de juego completa
  - Menú de pausa
  - Pantalla de configuración

- **Modos de juego**:
  - Un jugador vs IA (implementación básica)
  - Multijugador local (dos jugadores en el mismo dispositivo)

- **Funcionalidades adicionales**:
  - Sistema de guardado/carga de partidas
  - Configuración de opciones de juego (sonido, dificultad, pantalla)

## Características Pendientes

- **Assets gráficos**:
  - Imágenes de piezas con temática de anime
  - Textura personalizada para el tablero
  - Elementos gráficos de UI mejorados

- **Mejoras de juego**:
  - IA más avanzada (actualmente solo hace movimientos aleatorios)
  - Animaciones de movimiento
  - Efectos visuales

- **Funcionalidades adicionales**:
  - Efectos de sonido y música
  - Tutorial interactivo
  - Estadísticas de juego

## Requisitos

- Godot Engine 4.2 o superior

## Instalación

### Desde el código fuente
1. Clona este repositorio: `git clone https://github.com/StrykerUX/Game-test-V1-Random.git`
2. Abre Godot Engine 4.2 o superior
3. Selecciona "Importar" y navega hasta la carpeta donde clonaste el repositorio
4. Haz clic en "Importar y Editar"
5. Añade las imágenes para las piezas y el tablero en las carpetas correspondientes
6. Una vez listo, haz clic en el botón "Reproducir" (F5) para ejecutar el juego

### Crear un ejecutable
1. Abre el proyecto en Godot
2. Haz clic en "Proyecto" → "Exportar..." en el menú superior
3. Añade una configuración para la plataforma deseada (Windows, macOS, Linux)
4. Haz clic en "Exportar Proyecto" y selecciona la ubicación para el ejecutable
5. Comparte el ejecutable generado con otros usuarios

## Cómo jugar

1. En el menú principal, selecciona "Jugar vs IA" o "Jugar vs Humano"
2. El jugador de las piezas blancas siempre comienza
3. Haz clic en una pieza para seleccionarla (se mostrarán los movimientos válidos)
4. Haz clic en una casilla válida para mover la pieza seleccionada
5. Busca dar jaque mate al rey oponente para ganar

### Controles
- **Clic izquierdo**: Seleccionar y mover piezas
- **Tecla ESC**: Abrir menú de pausa

## Personalización

### Añadir piezas con temática de anime

1. Crea o consigue imágenes de personajes de anime para las piezas (tamaño recomendado: 80x80 píxeles)
2. Nombra los archivos siguiendo la convención establecida (ej: white_pawn.png, black_queen.png)
3. Coloca las imágenes en la carpeta `assets/pieces/`

### Personalizar el tablero

1. Crea o consigue una imagen para el tablero (tamaño recomendado: 640x640 píxeles)
2. Nombra el archivo como `chess_board.png`
3. Coloca la imagen en la carpeta `assets/board/`

## Estructura del Proyecto

```
├── assets/            # Recursos gráficos y audio
│   ├── board/         # Texturas del tablero
│   ├── pieces/        # Sprites de las piezas de ajedrez
│   ├── ui/            # Elementos de la interfaz
│   └── audio/         # Efectos de sonido y música
├── scenes/            # Escenas de Godot
├── scripts/           # Scripts GDScript
│   ├── board/         # Lógica del tablero
│   ├── pieces/        # Comportamiento de las piezas
│   └── ui/            # Controladores de interfaz
```

## Próximos pasos

Para llevar este proyecto al siguiente nivel:

1. **Añadir assets gráficos**: Esto es lo más urgente, ya que el juego funciona pero necesita imágenes para las piezas y el tablero.
2. **Mejorar la IA**: Implementar algoritmos más avanzados como minimax con poda alfa-beta.
3. **Añadir efectos de sonido y música**: Para mejorar la experiencia de juego.
4. **Implementar animaciones**: Añadir animaciones para los movimientos y capturas.
5. **Exportar a diferentes plataformas**: Crear ejecutables para Windows, macOS, Linux y posiblemente móviles.

## Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE).

## Agradecimientos

- El equipo de Godot Engine por su increíble motor de juegos
- La comunidad de Godot por sus tutoriales y recursos
