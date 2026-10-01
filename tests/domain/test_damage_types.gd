extends GutTest
## Tipos de daño canónicos — docs/design/03-combat.md §2.2.


func test_solo_existen_tres_tipos() -> void:
	assert_eq(DamageTypes.TODOS.size(), 3, "la escala de daño está limitada a tres tipos")
	assert_true(DamageTypes.es_valido(DamageTypes.FISICO))
	assert_true(DamageTypes.es_valido(DamageTypes.RESONANTE))
	assert_true(DamageTypes.es_valido(DamageTypes.UMBRIO))


func test_tipo_desconocido_se_rechaza() -> void:
	assert_false(DamageTypes.es_valido(&"fuego"), "no existen escuelas elementales separadas")
	assert_false(DamageTypes.es_valido(&""))


func test_nombres_legibles() -> void:
	assert_eq(DamageTypes.nombre_legible(DamageTypes.FISICO), "Físico")
	assert_eq(DamageTypes.nombre_legible(DamageTypes.RESONANTE), "Resonante")
	assert_eq(DamageTypes.nombre_legible(DamageTypes.UMBRIO), "Umbrío")
	assert_eq(DamageTypes.nombre_legible(&"otro"), "desconocido")
