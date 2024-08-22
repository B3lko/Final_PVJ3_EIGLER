extends HSlider

@export
var bus_name: String
var bus_index: int
var config_file_path: String = "user://audio_settings.json"

func _ready() -> void:
	print(bus_name)
	bus_index = AudioServer.get_bus_index(bus_name)
	var config = load_audio_settings()
	if bus_name in config:
		value = db_to_linear(config[bus_name])
	else:
		value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))



func _on_value_changed(value: float) -> void:
	var db_value = linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_index, db_value)
	save_audio_settings(bus_name, db_value)



func save_audio_settings(bus_name: String, db_value: float) -> void:
	var config = load_audio_settings()
	config[bus_name] = db_value
	
	var file = FileAccess.open(config_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(config, "  "))
	file.close()



func load_audio_settings() -> Dictionary:
	if FileAccess.file_exists(config_file_path):
		var file = FileAccess.open(config_file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var result = JSON.parse_string(content)
			if result is Dictionary:
				return result
	return {}
