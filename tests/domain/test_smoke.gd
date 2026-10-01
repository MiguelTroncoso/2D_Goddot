extends GutTest
## Smoke test: verifica que GUT corre headless antes de escribir la suite de dominio.


func test_gut_esta_operativo() -> void:
	assert_true(true, "GUT inicializa y ejecuta tests en modo headless")


func test_aritmetica_basica() -> void:
	assert_eq(2 + 2, 4)
