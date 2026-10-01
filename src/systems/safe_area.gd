class_name SafeArea
extends RefCounted

## Conversión de la zona segura del sistema (muescas, barras de gestos) a márgenes
## lógicos de interfaz. Puro y testeable: no toca nodos ni UI.
## Capa: systems/.

const MARGEN_MINIMO := 0.0


## Devuelve los márgenes lógicos que el HUD debe respetar.
##
## `pantalla` y `segura` están en píxeles de pantalla; `escala` es la relación
## píxeles-de-pantalla / unidades-lógicas (la del stretch del proyecto).
static func margenes(pantalla: Rect2i, segura: Rect2i, escala: Vector2) -> Dictionary:
	if segura.size.x <= 0 or segura.size.y <= 0:
		# Escritorio y headless pueden no reportar zona segura: no se reserva nada.
		return {"izquierda": 0.0, "arriba": 0.0, "derecha": 0.0, "abajo": 0.0}
	var factor := Vector2(maxf(escala.x, 0.0001), maxf(escala.y, 0.0001))
	var izquierda := maxf(MARGEN_MINIMO, float(segura.position.x - pantalla.position.x) / factor.x)
	var arriba := maxf(MARGEN_MINIMO, float(segura.position.y - pantalla.position.y) / factor.y)
	var derecha := maxf(
		MARGEN_MINIMO,
		float(
			pantalla.position.x + pantalla.size.x
			- (segura.position.x + segura.size.x)
		) / factor.x
	)
	var abajo := maxf(
		MARGEN_MINIMO,
		float(
			pantalla.position.y + pantalla.size.y
			- (segura.position.y + segura.size.y)
		) / factor.y
	)
	return {
		"izquierda": izquierda,
		"arriba": arriba,
		"derecha": derecha,
		"abajo": abajo,
	}


## Escala del stretch: píxeles de ventana por unidad lógica de viewport.
static func escala_stretch(tamano_ventana: Vector2i, tamano_viewport: Vector2) -> Vector2:
	if tamano_viewport.x <= 0.0 or tamano_viewport.y <= 0.0:
		return Vector2.ONE
	return Vector2(
		float(tamano_ventana.x) / tamano_viewport.x,
		float(tamano_ventana.y) / tamano_viewport.y
	)
