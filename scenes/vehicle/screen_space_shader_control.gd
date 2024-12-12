@tool
extends MeshInstance3D

@export var enable_in_editor: bool = false : set = _set_enable_in_editor
@export var enable_in_game: bool = true


func _set_enable_in_editor(new_enable_in_editor: bool) -> void:
	enable_in_editor = new_enable_in_editor
	visible = enable_in_editor


func _ready() -> void:
	if not Engine.is_editor_hint():
		visible = enable_in_game and not DebugTools.check_enabled(
			DebugTools.DebugTool.WIDE_CAMERA
		)
