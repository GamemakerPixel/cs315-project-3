extends Node

enum DebugTool {
	FREE_BUILDINGS,
	INVINCIBLE,
	WIDE_CAMERA,
}

const _DEBUG_MESSAGE = "THE FOLLOWING DEBUG TOOLS ARE ENABLED:"

const TOOL_SETTINGS = {
	DebugTool.FREE_BUILDINGS: false,
	DebugTool.INVINCIBLE: false,
	DebugTool.WIDE_CAMERA: false,
}


func _ready() -> void:
	var enabled_tools = _get_enabled_tools()
	
	if enabled_tools:
		print(_DEBUG_MESSAGE)
		for tool in enabled_tools:
			print(tool)
		print("")


func check_enabled(tool: DebugTool) -> bool:
	return TOOL_SETTINGS[tool]


func _get_enabled_tools() -> Array[String]:
	var enabled_tools: Array[String] = []
	
	for tool in TOOL_SETTINGS.keys():
		if TOOL_SETTINGS[tool]:
			enabled_tools.append(EnumNaming.enum_to_name(DebugTool, tool))
	
	return enabled_tools
