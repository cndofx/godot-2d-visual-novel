## Auto-loaded node that handles global variables
extends Node

const SAVE_FILE_LOCATION := "user://2DVisualNovelDemo.save"


func add_variable(name: String, value) -> void:
	var save_file = FileAccess.open(SAVE_FILE_LOCATION, FileAccess.READ_WRITE)
	
	var data: Dictionary
	if save_file:
		var json = JSON.new()
		var parse_result = json.parse(save_file.get_as_text())
		data = (
			json.data
			if parse_result == OK
			else { variables = {} }
		)
	else:
		save_file = FileAccess.open(SAVE_FILE_LOCATION, FileAccess.WRITE_READ)
		data = { variables = {} }

	if name != "":
		if not data.has("variables"):
			data["variables"] = {}

		data["variables"][name] = _evaluate(value)

	save_file.store_line(JSON.new().stringify(data))
	save_file.close()


func get_stored_variables_list() -> Dictionary:
	var save_file := FileAccess.open(SAVE_FILE_LOCATION, FileAccess.READ)

	var json := JSON.new()
	json.parse(save_file.get_as_text()) 

	save_file.close()

	return json.data.variables


# Used to evaluate the variables' values
func _evaluate(input):
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + input)
	script.reload()
	var obj = RefCounted.new()
	obj.set_script(script)
	return obj.eval()
