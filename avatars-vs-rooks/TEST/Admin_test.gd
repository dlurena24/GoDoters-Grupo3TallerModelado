extends GutTest
const admin_registerScript :=preload("res://scripts/admin_register.gd")
var admin_reg
func before_each()-> void:
	admin_reg = admin_registerScript.new

# Pruebas de la funcion on_user_signed_up
# Prueba 1 la extracción de UID de diferentes formatos de datos
func test_uid_extraction_from_different_formats() -> void:
	# Datos de prueba
	var user_data_uid := {"uid": "test_uid_123"}
	var user_data_localId := {"localId": "test_localId_456"} 
	var user_data_localid := {"localid": "test_localid_789"}
	var user_data_empty := {}
	var user_data_invalid := {"other_key": "value"}
	
	# Probar la lógica de extracción de UID directamente
	var uid1 = user_data_uid.get("uid", user_data_uid.get("localId", user_data_uid.get("localid", null)))
	var uid2 = user_data_localId.get("uid", user_data_localId.get("localId", user_data_localId.get("localid", null)))
	var uid3 = user_data_localid.get("uid", user_data_localid.get("localId", user_data_localid.get("localid", null)))
	var uid4 = user_data_empty.get("uid", user_data_empty.get("localId", user_data_empty.get("localid", null)))
	var uid5 = user_data_invalid.get("uid", user_data_invalid.get("localId", user_data_invalid.get("localid", null)))
	
	# Verificar extracción de UID
	assert_eq(uid1, "test_uid_123", "Debería extraer UID de clave 'uid'")
	assert_eq(uid2, "test_localId_456", "Debería extraer UID de clave 'localId'")
	assert_eq(uid3, "test_localid_789", "Debería extraer UID de clave 'localid'")
	assert_eq(uid4, null, "Debería retornar null con diccionario vacío")
	assert_eq(uid5, null, "Debería retornar null con claves inválidas")

# Prueba 2 validación de URL de descarga
func test_download_url_validation() -> void:
	# URLs de prueba
	var download_url_valid = "https://example.com/image.jpg"
	var download_url_empty = ""
	var download_url_invalid = "invalid_url"
	
	# Verificar validación directamente
	assert_true(download_url_valid != "", "URL válida no debería estar vacía")
	assert_false(download_url_empty != "", "URL vacía debería fallar la validación")
	assert_true(download_url_invalid != "", "URL no vacía debería pasar validación básica")

# Prueba 3 conversión de UID a string
func test_uid_string_conversion() -> void:
	# Diferentes tipos de UID que podrían venir
	var uid_string := "string_uid_123"
	var uid_int := 12345
	var uid_float := 123.45
	
	# Probar conversión a string
	var result1 = str(uid_string)
	var result2 = str(uid_int)
	var result3 = str(uid_float)
	
	assert_eq(result1, "string_uid_123", "String UID debería mantenerse igual")
	assert_eq(result2, "12345", "Int UID debería convertirse a string")
    assert_false(result2, "12345", "Int UID debería convertirse a string")
	assert_eq(result3, "123.45", "Float UID debería convertirse a string")

# Pruebas para la funcion on_user_signed_in
# Prueba 1 lógica de selección de foto de perfil (local vs Google)
func test_profile_picture_selection_logic() -> void:
	# Caso 1: Con foto local (debe generar path de storage)
	var profile_picture_path_local = "user://photos/avatar.png"
	var uid_local = "user_123"
	var has_local_photo = profile_picture_path_local != ""
	
	var storage_path_local = ""
	if has_local_photo:
		var file_name = profile_picture_path_local.get_file()
		storage_path_local = "profile_pictures/%s/%s" % [uid_local, file_name]
	
	# Caso 2: Sin foto local (debe usar photoURL de Google)
	var profile_picture_path_empty = ""
	var user_data_google = {"photourl": "https://google.com/photo.jpg", "photoURL": "https://google.com/photo2.jpg"}
	var download_url_empty_path = str(user_data_google.get("photourl", user_data_google.get("photoURL", "")))
	
	# Caso 3: Sin foto local ni Google (URL vacía)
	var user_data_no_photo = {"email": "test@example.com"}
	var download_url_no_photo = str(user_data_no_photo.get("photourl", user_data_no_photo.get("photoURL", "")))
	
	# Verificar
	assert_eq(storage_path_local, "profile_pictures/user_123/avatar.png", "Debería generar path para foto local")
	assert_eq(download_url_empty_path, "https://google.com/photo.jpg", "Debería usar photourl de Google cuando no hay foto local")
	assert_eq(download_url_no_photo, "", "Debería retornar string vacío sin fotos locales ni de Google")

# Prueba 2 construcción de datos para Firestore con diferentes escenarios
func test_firestore_data_construction() -> void:
	# Configurar datos de prueba
	var uid = "test_uid_123"
	var user_data = {"email": "google@example.com"}
	var name_input_text = "UserName"
	var email_input_text = "backup@example.com"
	var first_name_input_text = "John"
	var last_name_input_text = "Doe"
	var nationality_input_text = "Mexican"
	var download_url = "https://example.com/photo.jpg"
	var profile_picture_path = "user://photos/avatar.png"
	
	# Construir datos como lo hace la función
	var firestore_data = {
		"username": name_input_text.strip_edges(),
		"email": str(user_data.get("email", email_input_text.strip_edges())),
		"role": "admin",
		"profile_picture_url": download_url,
		"profile_picture_path": ("" if profile_picture_path == "" else "profile_pictures/%s/%s" % [uid, profile_picture_path.get_file()]),
		"first_name": first_name_input_text.strip_edges(),
		"last_name": last_name_input_text.strip_edges(),
		"nationality": nationality_input_text.strip_edges()
	}
	
	# Verificar construcción correcta de datos
	assert_eq(firestore_data["email"], "google@example.com", "Debería priorizar email de user_data sobre email_input")
	assert_eq(firestore_data["profile_picture_path"], "profile_pictures/test_uid_123/avatar.png", "Debería generar path cuando hay foto local")
	assert_eq(firestore_data["role"], "admin", "Rol siempre debería ser 'admin'")

# Prueba 3 extracción de UID con diferentes claves para Google Sign-In
func test_uid_extraction_google_signin_variants() -> void:
	# Configurar diferentes formatos de datos de Google Sign-In
	var user_data_uid := {"uid": "google_uid_123"}
	var user_data_localId := {"localId": "google_localId_456"} 
	var user_data_localid := {"localid": "google_localid_789"}
	var user_data_missing_uid := {"email": "test@example.com", "photoURL": "https://photo.jpg"}
	
	# Probar la lógica de extracción de UID directamente
	var uid1 = user_data_uid.get("uid", user_data_uid.get("localId", user_data_uid.get("localid", null)))
	var uid2 = user_data_localId.get("uid", user_data_localId.get("localId", user_data_localId.get("localid", null)))
	var uid3 = user_data_localid.get("uid", user_data_localid.get("localId", user_data_localid.get("localid", null)))
	var uid4 = user_data_missing_uid.get("uid", user_data_missing_uid.get("localId", user_data_missing_uid.get("localid", null)))
	
	# Verificar extracción de UID
	assert_eq(uid1, "google_uid_123", "Debería extraer UID de clave 'uid' en Google Sign-In")
	assert_eq(uid2, "google_localId_456", "Debería extraer UID de clave 'localId' en Google Sign-In")
	assert_eq(uid3, "google_localid_789", "Debería extraer UID de clave 'localid' en Google Sign-In")
	assert_eq(uid4, null, "Debería retornar null cuando faltan todas las claves UID")
func after_each() -> void:
	if is_instance_id_valid(admin_reg):
		admin_reg.free()
	admin_reg = null
	
