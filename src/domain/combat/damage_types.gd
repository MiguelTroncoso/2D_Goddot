class_name DamageTypes
extends RefCounted

## Tipos de daño canónicos de Astreva.
##
## Fuente: docs/design/01-lore.md §2.4 y docs/design/03-combat.md §2.2.
## Capa: domain/ (lógica pura). No importa nodos, red ni UI.

const FISICO := &"fisico"
const RESONANTE := &"resonante"
const UMBRIO := &"umbrio"

const TODOS := [FISICO, RESONANTE, UMBRIO]


## Devuelve true si el identificador corresponde a uno de los tres tipos válidos.
static func es_valido(tipo: StringName) -> bool:
	return TODOS.has(tipo)


## Nombre legible para UI y logs. Un tipo desconocido se reporta como "desconocido".
static func nombre_legible(tipo: StringName) -> String:
	if tipo == FISICO:
		return "Físico"
	if tipo == RESONANTE:
		return "Resonante"
	if tipo == UMBRIO:
		return "Umbrío"
	return "desconocido"
