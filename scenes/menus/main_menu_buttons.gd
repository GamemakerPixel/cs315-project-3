extends VBoxContainer

@export_file var game_scene: String


func _on_play() -> void:
	get_tree().change_scene_to_file(game_scene)


func _on_quit() -> void:
	get_tree().quit()
