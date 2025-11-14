extends GutTest

const ROOK_BASE_PATH = "res://Framework/Rook_Base.gd"

func test1_recibir_ataque_resta_vida_correctamente():
	var script = load(ROOK_BASE_PATH)
	assert_not_null(script)

	var rook = script.new()
	rook.vida = 100

	rook.recibir_ataque(30)

	assert_eq(rook.vida, 70, "La vida debe reducirse correctamente.")


func test2_recibir_ataque_mata_si_vida_llega_a_cero():
	var script = load(ROOK_BASE_PATH)
	assert_not_null(script)

	var rook = script.new()
	rook.vida = 20

	rook.recibir_ataque(50)

	assert_true(
		rook.is_queued_for_deletion(),
		"El rook debe morir y hacer queue_free() cuando vida <= 0."
	)


func test3_recibir_ataque_no_mata_si_vida_es_mayor_a_cero():
	var script = load(ROOK_BASE_PATH)
	assert_not_null(script)

	var rook = script.new()
	rook.vida = 100

	rook.recibir_ataque(10)

	assert_false(
		rook.is_queued_for_deletion(),
		"No debería morir si aún tiene vida."
	)
