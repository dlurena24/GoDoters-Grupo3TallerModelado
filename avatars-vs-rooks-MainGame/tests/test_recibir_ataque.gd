extends GutTest

const AVATAR_SCRIPT = "res://Framework/Clases/Avatars/avatar.gd"

func test_recibir_ataque_resta_salud_correctamente():
	print("Test 1 avatar recibir ataque")
	var avatar = load(AVATAR_SCRIPT).new()
	avatar.salud_actual = 100

	avatar.recibir_ataque(30)

	assert_eq(
		avatar.salud_actual,
		70,
		"La salud debería disminuir según la cantidad de daño."
	)


func test_recibir_ataque_no_muere_si_queda_salud():
	print("Test 2 avatar recibir ataque")

	var avatar = load(AVATAR_SCRIPT).new()
	avatar.salud_actual = 50

	avatar.recibir_ataque(20)

	assert_true(
		avatar.salud_actual > 0,
		"No debería morir si aún queda salud."
	)

	assert_false(
		avatar.is_queued_for_deletion(),
		"No debería estar marcado para borrarse mientras tenga salud."
	)


func test_recibir_ataque_muere_si_salud_llega_a_cero():
	print("Test 3 avatar recibir ataque")

	var avatar = load(AVATAR_SCRIPT).new()
	avatar.salud_actual = 10

	avatar.recibir_ataque(50)

	assert_true(
		avatar.is_queued_for_deletion(),
		"El avatar debería morir y quedar en cola de eliminación cuando la salud llega a 0 o menos."
	)
