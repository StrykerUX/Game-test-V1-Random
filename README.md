# Game-test-V1-Random (Anime Chess)

Un juego de ajedrez con temática de anime desarrollado en Godot Engine 4.2.

## ✅ Características implementadas

Este proyecto incluye las siguientes características:

- ✅ **Sistema completo de ajedrez**
  - Implementación completa de reglas de ajedrez
  - Movimientos especiales (enroque, captura al paso, promoción)
  - Jaque, jaque mate y tablas
  
- ✅ **Efectos visuales especiales**
  - Efectos para movimientos importantes (enroque, captura con reina)
  - Animaciones para jaque y jaque mate
  - Efectos visuales mejorados para las piezas

- ✅ **Menú principal completo**
  - Juego vs IA
  - Juego multijugador local
  - Selección de dificultad (fácil, medio, difícil)
  - Configuración de gráficos y sonido
  - Tutorial interactivo

- ✅ **Tutorial interactivo**
  - Lecciones de ajedrez paso a paso
  - Explicaciones visuales de movimientos
  - Demostraciones interactivas

- ✅ **IA mejorada**
  - Tres niveles de dificultad
  - Algoritmo minimax con poda alfa-beta
  - Evaluación posicional avanzada

- ✅ **Límite de tiempo**
  - Partidas con tiempo límite de 30 minutos
  - Sistema de puntuación para determinar el ganador cuando se acaba el tiempo

## 🛠️ Características pendientes para personalizar

- Piezas de ajedrez con diseño de anime (los placeholders están listos)
- Fondos personalizados con estilo anime
- Música y efectos de sonido temáticos

## 📸 Capturas de pantalla

*Las capturas de pantalla estarán disponibles una vez que se añadan los assets gráficos personalizados.*

## 🎮 Cómo jugar

1. Inicia el juego desde el menú principal
2. Selecciona el modo de juego (vs IA o vs Humano)
3. Para la IA, selecciona el nivel de dificultad:
   - **Fácil**: Movimientos aleatorios
   - **Medio**: IA con algoritmo minimax (profundidad 2)
   - **Difícil**: IA avanzada con minimax (profundidad 4)
4. Haz clic en una pieza para seleccionarla
5. Los movimientos válidos se mostrarán en verde
6. Haz clic en una casilla válida para mover la pieza
7. Observa los efectos especiales para movimientos importantes

### Controles
- **Clic izquierdo**: Seleccionar y mover piezas
- **Tecla ESC**: Abrir menú de pausa

## ⏱️ Temporizador
- Cada partida tiene un tiempo límite de 30 minutos
- Si se acaba el tiempo, se determina el ganador por la puntuación de las piezas
- La barra de progreso muestra el tiempo restante
- El color cambia a medida que se acerca el final (verde > amarillo > rojo)

## 🎓 Tutorial
El tutorial interactivo incluye lecciones sobre:
1. Movimientos básicos de las piezas
2. Enroque (corto y largo)
3. Captura al paso
4. Promoción de peón
5. Jaque y jaque mate

## 🖥️ Requisitos

- Godot Engine 4.2 o superior

## 🚀 Instalación

### Desde el código fuente
1. Clona este repositorio: `git clone https://github.com/StrykerUX/Game-test-V1-Random.git`
2. Abre Godot Engine 4.2 o superior
3. Selecciona "Importar" y navega hasta la carpeta donde clonaste el repositorio
4. Haz clic en "Importar y Editar"
5. Una vez listo, personaliza las imágenes en la carpeta `assets/` con tus propios diseños anime
6. Haz clic en el botón "Reproducir" (F5) para ejecutar el juego

### Crear un ejecutable
1. Abre el proyecto en Godot
2. Haz clic en "Proyecto" → "Exportar..." en el menú superior
3. Añade una configuración para la plataforma deseada (Windows, macOS, Linux)
4. Haz clic en "Exportar Proyecto" y selecciona la ubicación para el ejecutable
5. Comparte el ejecutable generado con otros usuarios

## 📁 Estructura del Proyecto

```
├── assets/            # Recursos gráficos y audio
│   ├── board/         # Texturas del tablero
│   ├── pieces/        # Sprites de las piezas de ajedrez
│   ├── ui/            # Elementos de la interfaz
│   └── audio/         # Efectos de sonido y música
├── scenes/            # Escenas de Godot
│   ├── main_menu.tscn # Menú principal
│   ├── game.tscn      # Escena del juego
│   ├── tutorial.tscn  # Tutorial interactivo
│   └── settings.tscn  # Pantalla de configuración
├── scripts/           # Scripts GDScript
│   ├── board/         # Lógica del tablero
│   ├── pieces/        # Comportamiento de las piezas
│   ├── ui/            # Controladores de interfaz
│   └── effects/       # Efectos visuales
```

## 👥 Contribuir

¡Las contribuciones son bienvenidas! Si quieres contribuir a este proyecto:

1. Haz un fork del repositorio
2. Crea una rama para tu característica (`git checkout -b feature/amazing-feature`)
3. Realiza tus cambios
4. Haz commit de tus cambios (`git commit -m 'Añadir nueva característica'`)
5. Haz push a la rama (`git push origin feature/amazing-feature`)
6. Abre un Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE).