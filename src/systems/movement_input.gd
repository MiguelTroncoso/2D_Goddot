extends RefCounted
## Pure input math shared by the desktop and touch control paths.
## Capa: systems/ (no toca ui/, net/ ni entities/).

## Fracción horizontal de la pantalla que activa el joystick dinámico (pulgar izquierdo).
const ZONA_ACTIVACION_RATIO := 0.55
## Fracción vertical superior reservada al HUD (evita robar toques de botones de arriba).
const MARGEN_SUPERIOR_RATIO := 0.12


static func combine(keyboard: Vector2, touch: Vector2) -> Vector2:
	return (keyboard + touch).limit_length(1.0)


static func joystick_vector(offset: Vector2, travel: float, dead_zone: float) -> Vector2:
	if travel <= 0.0:
		return Vector2.ZERO
	var raw := (offset / travel).limit_length(1.0)
	var magnitude := raw.length()
	var threshold := clampf(dead_zone, 0.0, 0.99)
	if magnitude <= threshold:
		return Vector2.ZERO
	# Rescale outside the dead zone so slow movement remains possible.
	return raw.normalized() * ((magnitude - threshold) / (1.0 - threshold))


## Desplazamiento desde el punto donde el dedo tocó la pantalla.
##
## El joystick dinámico se mide SIEMPRE en el mismo espacio de coordenadas que el
## evento táctil crudo: nunca mezcla transformaciones de canvas, escala de stretch
## ni safe area. Es la corrección del bug de input en dispositivo (TASK-003.5).
static func delta_desde_origen(origen: Vector2, actual: Vector2) -> Vector2:
	return actual - origen


## Vector de movimiento a partir del origen del toque y la posición actual del dedo.
static func vector_desde_origen(
	origen: Vector2,
	actual: Vector2,
	travel: float,
	dead_zone: float
) -> Vector2:
	return joystick_vector(delta_desde_origen(origen, actual), travel, dead_zone)


## Zona táctil que activa el joystick: mitad izquierda, por debajo del HUD superior.
static func en_zona_activacion(
	posicion: Vector2,
	tamano_viewport: Vector2,
	ratio_horizontal: float = ZONA_ACTIVACION_RATIO,
	margen_superior: float = MARGEN_SUPERIOR_RATIO
) -> bool:
	if tamano_viewport.x <= 0.0 or tamano_viewport.y <= 0.0:
		return false
	if posicion.x < 0.0 or posicion.x > tamano_viewport.x:
		return false
	if posicion.y < tamano_viewport.y * margen_superior or posicion.y > tamano_viewport.y:
		return false
	return posicion.x <= tamano_viewport.x * clampf(ratio_horizontal, 0.05, 1.0)
