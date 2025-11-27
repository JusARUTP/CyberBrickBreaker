extends Node2D

var score = 0
@export var VidasMaximas = 3 # Cambié el nombre para recordar cuántas son al reiniciar
var vidas_actuales = 0

var gameover = false
var gameoverTimer = 0.0 # Timer interno

@export var Niveles : Array[PackedScene]
var indiceNivel = -1
var currentLevel

func _ready() -> void:
	# Al arrancar, mostramos el menú y ocultamos lo demás
	mostrar_menu_principal()
	
	# Conectamos la señal del botón Jugar
	# Asegúrate de que la ruta al botón sea correcta según tu árbol
	$ManejadorUI/MenuInicio/Jugar.pressed.connect(iniciar_partida)
	# --- NUEVO: Conectamos el botón de Salir ---
	# Asegúrate de que el nombre "BotonSalir" coincida con el de tu nodo
	$ManejadorUI/MenuInicio/Salir.pressed.connect(salir_del_juego)

func _process(delta: float) -> void:
	# Lógica para detectar tecla SOLO si estamos en Game Over
	if gameover:
		gameoverTimer -= delta
		if gameoverTimer <= 0:
			# Mostramos los textos de "Presiona una tecla" si no están visibles
			mostrar_textos_continuar()
			
			# Si presiona cualquier tecla, volvemos al menú
			if Input.is_anything_pressed():
				regresar_al_menu()

# --- FUNCIONES DE FLUJO DE JUEGO ---

func mostrar_menu_principal():
	# Reseteamos estados
	gameover = false
	
	# UI: Mostramos menú, ocultamos el resto
	$ManejadorUI/MenuInicio.show()
	$ManejadorUI/JuegoTerminado.hide()
	$ManejadorUI/JuegoTerminado2.hide()
	$ManejadorUI/Nivel.text = "" 
	$ManejadorUI/Vidas.text = ""
	$ManejadorUI/Score.text = ""

func iniciar_partida():
	# Ocultamos el menú
	$ManejadorUI/MenuInicio.hide()
	
	# Reseteamos valores de juego
	score = 0
	vidas_actuales = VidasMaximas
	indiceNivel = -1 # Empezamos en -1 para que al sumar 1 sea el nivel 0
	gameover = false
	
	# Actualizamos UI inicial
	actualizar_ui()
	
	# Arrancamos el primer nivel
	generarNuevoNivel()
	
# --- Agrega esta nueva función al final o junto a iniciar_partida ---
func salir_del_juego():
	print("Saliendo del juego...")
	get_tree().quit()

func regresar_al_menu():
	# Limpiamos el nivel actual si existe
	if currentLevel != null:
		# BLINDAJE: Desconectamos la señal de victoria antes de borrarlo.
		# Así evitamos que al destruirse active el siguiente nivel por error.
		if currentLevel.NivelCompletado.is_connected(generarNuevoNivel):
			currentLevel.NivelCompletado.disconnect(generarNuevoNivel)
			
		currentLevel.queue_free()
		currentLevel = null
		
	mostrar_menu_principal()

# --- LÓGICA DEL JUEGO ---

func generarNuevoNivel():
	# Si hay un nivel previo, lo borramos
	if currentLevel != null:
		currentLevel.queue_free()
		
	indiceNivel += 1
	
	if indiceNivel < Niveles.size():
		# Crear nuevo nivel
		$ManejadorUI/Nivel.text = "Nivel: " + str(indiceNivel + 1)
		currentLevel = Niveles[indiceNivel].instantiate()
		
		# Conectar señales
		currentLevel.NivelCompletado.connect(generarNuevoNivel)
		currentLevel.AddScore.connect(addScore)
		currentLevel.RemoveLife.connect(removeLife)
		
		add_child(currentLevel)
		# Usamos call_deferred para evitar errores de física en el primer frame
		currentLevel.call_deferred("GenerarBola")
	else:
		victoria()

func addScore():
	score += 1
	$ManejadorUI/Score.text = "Score : " + str(score)
	
func removeLife():
	vidas_actuales -= 1
	actualizar_ui()
	
	if currentLevel.has_node("Paleta"):
		currentLevel.get_node("Paleta").resetPosition()
	
	if vidas_actuales <= 0:
		perder_juego()
		return
		
	currentLevel.GenerarBola()

func actualizar_ui():
	$ManejadorUI/Vidas.text = "Vidas : " + str(vidas_actuales)
	$ManejadorUI/Nivel.text = "Nivel : " + str(indiceNivel + 1)
	$ManejadorUI/Score.text = "Score : " + str(score)

# --- ESTADOS DE FIN DE JUEGO ---

func perder_juego():
	print("GAME OVER")
	gameover = true
	gameoverTimer = 1.0 # Pequeña espera para no saltar el menu por accidente
	
	$ManejadorUI/JuegoTerminado.show()
	$ManejadorUI/JuegoTerminado/Puntuacion.text = "Puntuación: " + str(score)
	$ManejadorUI/JuegoTerminado/PresionaUnaTecla.hide() # Se oculta al inicio
	$ManejadorUI/JuegoTerminado/AnimationPlayer.play("Pulso")

func victoria():
	gameover = true
	gameoverTimer = 1.0
	
	$ManejadorUI/JuegoTerminado2.show()
	$ManejadorUI/JuegoTerminado2/Puntuacion.text = "Puntuación Final: " + str(score)
	$ManejadorUI/JuegoTerminado2/Agradecimientos.hide()
	$ManejadorUI/JuegoTerminado2/PresionaUnaTecla.hide()
	$ManejadorUI/JuegoTerminado2/AnimationPlayer.play("Pulso")

func mostrar_textos_continuar():
	if $ManejadorUI/JuegoTerminado2.visible:
		$ManejadorUI/JuegoTerminado2/Agradecimientos.show()
		$ManejadorUI/JuegoTerminado2/PresionaUnaTecla.show()
	elif $ManejadorUI/JuegoTerminado.visible:
		$ManejadorUI/JuegoTerminado/PresionaUnaTecla.show()
