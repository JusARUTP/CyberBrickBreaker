extends CharacterBody2D

@export var Speed = 600.0
var resetPos: Vector2

func _ready() -> void:
	resetPos = global_position
	# Añadimos la paleta al grupo "Paleta" por código para que la bola la reconozca fácil
	add_to_group("Paleta")

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * Speed
	else:
		velocity.x = move_toward(velocity.x, 0, Speed)

	# --- CORRECCIÓN CRUCIAL ---
	# Forzamos que la velocidad en Y sea siempre 0 para que la bola no nos empuje
	velocity.y = 0 
	
	move_and_slide()
	
	# Reafirmamos la posición Y para evitar micro-desplazamientos por golpes fuertes
	global_position.y = resetPos.y

func resetPosition():
	global_position = resetPos
	velocity = Vector2.ZERO
