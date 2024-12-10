extends Control

@export_file var menu_scene: String


func _on_retry():
	get_tree().reload_current_scene()


func _on_menu():
	get_tree().change_scene_to_file(menu_scene)


func _on_quit():
	get_tree().quit()
