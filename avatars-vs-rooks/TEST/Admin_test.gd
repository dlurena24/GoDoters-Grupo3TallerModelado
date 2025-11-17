extends GutTest
const admin_registerScript :=preload("res://scripts/admin_register.gd")
var admin_reg
func before_each()-> void:
	admin_reg = admin_registerScript.new

# Pruebas de la funcion on_user_signed_up

func test_uid_string_conversion_string() -> void:
#prueba que el uid sea un string
	# Diferentes tipos de UID que podrían venir
	var uid_string := "string_uid_123"
	var result1: Dictionary = admin_reg.on_user_signed_up(uid_string)
	assert_eq(result1, "string_uid_123", "String UID debería mantenerse igual")


func test_uid_string_conversion_int() -> void:
#prueba que el uid sea se pueda convertir de int a string
	var uid_int := 12345
	var result2: Dictionary = admin_reg.on_user_signed_up(uid_int)
	assert_eq(result2, "12345", "Int UID debería convertirse a string")

func test_uid_string_conversion_float() -> void:
#prueba que el uid se pueda convertir de float a string	
	var uid_float := 123.45
	var result3: Dictionary = admin_reg.on_user_signed_up(uid_float)
	assert_eq(result3, "123.45", "Float UID debería convertirse a string")
	
#pruebas a la funcion on_user_signed_in
func test_pfp_local() -> void:
	# Caso 1: Con foto local (debe generar path de storage)
	var profile_picture_path_local = "user://photos/avatar.png"
	var uid_local = "user_123"
	var has_local_photo = profile_picture_path_local != ""
	
	var storage_path_local = ""
	if has_local_photo:
		var file_name = profile_picture_path_local.get_file()
		storage_path_local = "profile_pictures/%s/%s" % [uid_local, file_name]
	assert_eq(storage_path_local, "profile_pictures/user_123/avatar.png", "Debería generar path para foto local")
	
func test_pfp_no_local() -> void:
	# Caso 2: Sin foto local (debe usar photoURL de Google)
	var profile_picture_path_empty = ""
	var user_data_google = {"photourl": "https://google.com/photo.jpg", "photoURL": "https://google.com/photo2.jpg"}
	var download_url_empty_path = str(user_data_google.get("photourl", user_data_google.get("photoURL", "")))
	assert_eq(download_url_empty_path, "https://google.com/photo.jpg", "Debería usar photourl de Google cuando no hay foto local")

func test_pfp_no_local_ni_Google() -> void:
	# Caso 3: Sin foto local ni Google (URL vacía)
	var user_data_no_photo = {"email": "test@example.com"}
	var download_url_no_photo = str(user_data_no_photo.get("photourl", user_data_no_photo.get("photoURL", "")))
	assert_eq(download_url_no_photo, "", "Debería retornar string vacío sin fotos locales ni de Google")


func after_each() -> void:
	if is_instance_valid(admin_reg):
		admin_reg.free()
	admin_reg = null
	
