class_name EnumNaming
extends RefCounted


static func enum_to_name(enum_object, enum_value) -> String:
	var found_enum_key = null
	for enum_key in enum_object.keys():
		var enum_keys_value = enum_object[enum_key]
		if enum_keys_value == enum_value:
			found_enum_key = enum_key
			break
	
	if not found_enum_key:
		push_error(
			"Unable to match enum value " + str(enum_value) + " to enum object "
			+ str(enum_object) + "."
		)
		return ""
	
	return found_enum_key.capitalize()
