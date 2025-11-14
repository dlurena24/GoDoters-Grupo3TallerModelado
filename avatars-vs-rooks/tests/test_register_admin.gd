extends GutTest

# PRUEBAS PARA _on_register_button_pressed

func test_on_register_button_pressed_fields_empty():
	var scene = preload("res://scenes/admin_register.tscn").instantiate()
	scene._ready()
	scene.name_input.text = ""
	scene.first_name_input.text = ""
	scene.last_name_input.text = ""
	scene.nationality_input.text = ""
	scene.email_input.text = ""
	scene.password_input.text = ""
	scene.profile_picture_path = "prueba.jpg"
	scene._on_register_button_pressed()
	assert_eq(scene.error_label.text, "Completa todos los campos (incluida la contraseña).")

func test_on_register_button_pressed_underage():
	var scene = preload("res://scenes/admin_register.tscn").instantiate()
	scene._ready()
	var current_year = Time.get_datetime_dict_from_system().year
	scene.year_option.add_item(str(current_year - 10))
	scene.year_option.selected = scene.year_option.get_item_count() - 1
	scene.name_input.text = "John"
	scene.first_name_input.text = "John"
	scene.last_name_input.text = "Doe"
	scene.nationality_input.text = "MX"
	scene.email_input.text = "john@example.com"
	scene.password_input.text = "Abc123456!"
	scene.profile_picture_path = "prueba.jpg"
	scene._on_register_button_pressed()
	assert_eq(scene.error_label.text, "Error: Debes ser mayor de 18 años.")

func test_on_register_button_pressed_image_missing():
	var scene = preload("res://scenes/admin_register.tscn").instantiate()
	scene._ready()
	scene.name_input.text = "John"
	scene.first_name_input.text = "John"
	scene.last_name_input.text = "Doe"
	scene.nationality_input.text = "MX"
	scene.email_input.text = "john@example.com"
	scene.password_input.text = "Abc123456!"
	scene.profile_picture_path = ""  # No hay imagen
	scene._on_register_button_pressed()
	assert_eq(scene.error_label.text, "Sube una imagen .png o .jpg")

# PRUEBAS PARA _on_file_selected

func test_on_file_selected_sets_path():
	var scene = preload("res://scenes/admin_register.tscn").instantiate()
	scene._ready()
	scene.file_name_label.text = ""
	var path = "C:/fotos/foto1.png"
	scene._on_file_selected(path)
	assert_eq(scene.file_name_label.text, "foto1.png")
	assert_eq(scene.profile_picture_path, path)

func test_on_file_selected_empty_path():
	var scene = preload("res://scenes/admin_register.tscn").instantiate()
	scene._ready()
	scene.file_name_label.text = "anterior.png"
	var path = ""
	scene._on_file_selected(path)
	assert_eq(scene.profile_picture_path, "")
	assert_eq(scene.file_name_label.text, "")

func test_on_file_selected_jpg_file():
	var scene = preload("res://scenes/admin_register.tscn").instantiate()
	scene._ready()
	scene.file_name_label.text = ""
	var path = "C:/fotos/otrafoto.jpg"
	scene._on_file_selected(path)
	assert_eq(scene.file_name_label.text, "otrafoto.jpg")
	assert_eq(scene.profile_picture_path, path)
