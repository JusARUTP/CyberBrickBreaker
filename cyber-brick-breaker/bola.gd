extends RigidBody2D

@export var speed := 400
var velocity := Vector2(0,-1) * speed
signal AddScore
signal RemoveLife

func _ready() -> void:
	gravity_scale = 0
	linear_velocity = velocity
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Obtenemos la dirección actual normalizada
	var direccion_actual = linear_velocity.normalized()
	
	# --- CORRECCIÓN ANTI-BUCLE HORIZONTAL ---
	# Definimos un umbral mínimo vertical (0.2 suele ser suficiente)
	var umbral_vertical = 0.2 
	
	# Si el valor absoluto de Y es menor que el umbral, es que está muy horizontal
	if abs(direccion_actual.y) < umbral_vertical:
		# Empujamos la bola: Si iba bajando (y > 0), forzamos 0.2. Si iba subiendo, forzamos -0.2
		# El 'sign' devuelve 1 si es positivo, -1 si es negativo.
		var empuje = sign(direccion_actual.y) * umbral_vertical
		
		# Si por casualidad Y era exactamente 0 (muy raro), forzamos hacia abajo por defecto
		if empuje == 0: empuje = umbral_vertical
		
		direccion_actual.y = empuje
		# Volvemos a normalizar para que el cambio de ángulo no afecte la velocidad final
		direccion_actual = direccion_actual.normalized()
	# ----------------------------------------

	# Aplicamos la velocidad corregida
	linear_velocity = direccion_actual * speed
	
	if state.get_contact_count() > 0:
		$Rebote.play()
		for i in range(state.get_contact_count()):
			var collider = state.get_contact_collider_object(i)

			if collider.is_in_group("Ladrillo"):
				$Romper.play()
				collider.queue_free()
				AddScore.emit()
			if collider.is_in_group("Eliminar"):
				RemoveLife.emit()
				queue_free()
