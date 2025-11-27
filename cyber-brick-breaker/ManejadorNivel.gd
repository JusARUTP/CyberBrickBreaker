extends Node2D
class_name  ManejadorNivel
var ladrillos = []
signal NivelCompletado
@export var Bola :  PackedScene
signal AddScore
signal RemoveLife

func _ready() -> void:
	ladrillos = get_tree().get_nodes_in_group("Ladrillo")
	for i in ladrillos:
		i.tree_exited.connect(func(): self.onBrickExit(i))
	pass
	
func _process(delta: float) -> void:
	pass
	
func onBrickExit(ladrillo):
	# BLINDAJE: Si el Nivel entero se está borrando (por Game Over o Salir),
	# no nos importa que los ladrillos desaparezcan. Cortamos aquí.
	if is_queued_for_deletion():
		return
		
	ladrillos.erase(ladrillo)
	
	if ladrillos.size() <= 0:
		NivelCompletado.emit()
		
func GenerarBola():
	# 1. VERIFICACIÓN DE SEGURIDAD (La solución a tu error)
	# Si este nodo ya no está en el árbol (porque se está cerrando el juego o cambiando de nivel),
	# detenemos la función inmediatamente para evitar el crash.
	if not is_inside_tree():
		return

	# 2. Obtenemos los puntos de generación
	var puntos = get_tree().get_nodes_in_group("PuntoGenerarBola")
	
	# 3. Verificamos que realmente exista un punto para evitar errores de índice [0]
	if puntos.size() > 0:
		var bolaActual = Bola.instantiate()
		bolaActual.global_position = puntos[0].global_position
		add_child(bolaActual)
		bolaActual.AddScore.connect(func(): AddScore.emit())
		bolaActual.RemoveLife.connect(func(): RemoveLife.emit())
	else:
		print("ERROR: No hay ningún nodo en el grupo 'PuntoGenerarBola' en la escena.")
		
#func GenerarBola():
#	var bolaActual = Bola.instantiate()
#	bolaActual.global_position = get_tree().get_nodes_in_group("PuntoGenerarBola")[0].global_position
#	add_child(bolaActual)
#	bolaActual.AddScore.connect(func(): AddScore.emit())
#	bolaActual.RemoveLife.connect(func(): RemoveLife.emit())
	
