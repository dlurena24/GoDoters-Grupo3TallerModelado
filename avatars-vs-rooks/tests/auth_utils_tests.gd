extends GutTest

# Ajusta la ruta si tu AuthUtils.gd está en otra carpeta
const AuthUtilsScript := preload("res://scripts/AuthUtils.gd")

var auth_utils

func before_each() -> void:
	# Se crea una instancia del script para poder llamar a los métodos
	auth_utils = AuthUtilsScript.new()


# PRUEBAS PARA: validate_password(pwd: String) -> Dictionary

# Debe aceptar una contraseña fuerte que cumpla todas las reglas
func test_validate_password_fuerte() -> void:
	var pwd := "Abcdef12345!"  # 12 caracteres, al menos 1 dígito, 1 mayúscula y 1 símbolo
	var result: Dictionary = auth_utils.validate_password(pwd)

	assert_true(result["ok"], "Una contraseña fuerte debería ser válida")
	assert_eq(0, result["errors"].size(), "No debería devolver errores para una contraseña válida")
	
# Debe rechazar una contraseña demasiado corta, pero que cumpla lo demás
func test_validate_password_muy_corta() -> void:
	var pwd := "Abc12!"  # Tiene mayúscula, dígitos y símbolo, pero es muy corta (< 12)
	var result: Dictionary = auth_utils.validate_password(pwd)

	assert_false(result["ok"], "Contraseña muy corta no debería ser válida")
	assert_true(result["errors"].has("- mínimo 12 caracteres"), "Debe indicar que le falta longitud")
	# Solo debería fallar por longitud en este caso
	assert_eq(1, result["errors"].size(), "Solo debería haber un error de longitud")


# Debe rechazar una contraseña sin dígitos, pero con el resto correcto
func test_validate_password_sin_digitos() -> void:
	var pwd := "Abcdefghijk!"  # 12 caracteres, mayúscula y símbolo, pero sin dígitos
	var result: Dictionary = auth_utils.validate_password(pwd)

	assert_false(result["ok"], "Contraseña sin dígitos no debería ser válida")
	assert_true(result["errors"].has("- al menos 1 dígito"), "Debe indicar que falta 1 dígito")


# PRUEBAS PARA: is_valid_image_path(path: String) -> bool

# Debe aceptar una ruta con extensión .png
func test_is_valid_image_path_png() -> void:
	var path := "user://imagenes/foto_perfil.png"
	var ok = auth_utils.is_valid_image_path(path)

	assert_true(ok, "Las rutas .png deberían ser válidas")


# Debe aceptar extensiones .jpg / .jpeg sin importar mayúsculas/minúsculas
func test_is_valid_image_path_jpg_jpeg() -> void:
	var path1 := "res://assets/PHOTO.JPG"
	var path2 := "res://assets/foto.JpEg"

	var ok1 = auth_utils.is_valid_image_path(path1)
	var ok2 = auth_utils.is_valid_image_path(path2)

	assert_true(ok1, "Las rutas .jpg deberían ser válidas sin importar mayúsculas")
	assert_true(ok2, "Las rutas .jpeg deberían ser válidas sin importar mayúsculas")


# Debe rechazar rutas vacías o con extensión inválida
func test_is_valid_image_path_invalida() -> void:
	var empty := ""
	var txt := "res://assets/readme.txt"

	var ok_empty = auth_utils.is_valid_image_path(empty)
	var ok_txt = auth_utils.is_valid_image_path(txt)

	assert_false(ok_empty, "Una ruta vacía no debería ser válida")
	assert_false(ok_txt, "Extensiones que no sean png/jpg/jpeg no deberían ser válidas")
	
func after_each() -> void:
	if is_instance_valid(auth_utils):
		auth_utils.free()
	auth_utils = null
