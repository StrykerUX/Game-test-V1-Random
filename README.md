# Game-test-V1-Random (Anime Chess)

Un juego de ajedrez con temática de anime desarrollado en Godot Engine 4.2.

![Anime Chess Banner](https://github.com/StrykerUX/Game-test-V1-Random/blob/main/assets/README.md)

## Descripción

Este proyecto implementa un juego de ajedrez tradicional con un diseño visual inspirado en personajes de anime. Los jugadores pueden disfrutar de todas las reglas clásicas del ajedrez con un toque visual único.

## Características

- Reglas completas de ajedrez
- Diseño visual con temática de anime
- Modo de un jugador contra la IA con diferentes niveles de dificultad
- Modo multijugador local para jugar contra un amigo
- Sistema de guardado y carga de partidas
- Configuración personalizable (sonido, gráficos, dificultad)
- Interfaz de usuario amigable e intuitiva

## Requisitos

- Godot Engine 4.2 o superior

## Instalación

### Desde el código fuente
1. Clona este repositorio: `git clone https://github.com/StrykerUX/Game-test-V1-Random.git`
2. Abre Godot Engine 4.2 o superior
3. Selecciona "Importar" y navega hasta la carpeta donde clonaste el repositorio
4. Haz clic en "Importar y Editar"
5. Una vez cargado el proyecto, haz clic en el botón "Reproducir" (F5) para ejecutar el juego

### Desde binarios precompilados (próximamente)
- Descarga la versión correspondiente a tu sistema operativo desde la sección de Releases
- Descomprime el archivo
- Ejecuta el archivo binario

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

## Estado del desarrollo

Este proyecto está en desarrollo activo. Las siguientes características están planeadas para futuras actualizaciones:

- Soporte para multijugador en línea
- Más variedades de sets de piezas con diferentes personajes de anime
- Animaciones mejoradas
- Modo historia con diferentes escenarios y personajes
- Logros y sistema de progresión
- Exportación a plataformas móviles

## Contribuir

¡Las contribuciones son bienvenidas! Si quieres contribuir a este proyecto:

1. Haz un fork del repositorio
2. Crea una rama para tu característica (`git checkout -b feature/amazing-feature`)
3. Realiza tus cambios
4. Haz commit de tus cambios (`git commit -m 'Add some amazing feature'`)
5. Haz push a la rama (`git push origin feature/amazing-feature`)
6. Abre un Pull Request

## Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE).

## Agradecimientos

- El equipo de Godot Engine por su increíble motor de juegos
- La comunidad de Godot por sus tutoriales y recursos
- Todos los artistas de anime cuyos estilos han inspirado el diseño visual
