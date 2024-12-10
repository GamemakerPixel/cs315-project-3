class_name ConsumablePool
extends RefCounted

# This object will serve as the state of all the consumable resources in the
# game - it will be owned by the Map and passed to anything that consumes or
# produces them (resource gatherers, construction system, and generators).

# Technically some of these resources are not consumable, but their values still
# change and they're a convient abstraction for renewable generators.

enum Consumable {
	DAYLIGHT,
	LUMBER,
	COAL,
	IRON,
	WIND,
	GOLD,
}

class WaitListEntry:
	var minimum_amount: float
	var maximum_amount: float
	var used_callback: Callable # Accepts the amount used as an argument.
	
	@warning_ignore("shadowed_variable")
	func _init(minimum_amount: float, maximum_amount: float, used_callback: Callable):
		self.minimum_amount = minimum_amount
		self.maximum_amount = maximum_amount
		self.used_callback = used_callback

# Nonconsumble resources use setting and getting, consumable resources add and
# subtract. Both are abstracted to "supply" and "use". (Idealy this would be
# a set, but Godot doesn't have those yet.)
const NONCONSUMABLE = [
	Consumable.DAYLIGHT,
	Consumable.WIND,
]

# Consumable: float
# The below values are initial values.
var _counts: Dictionary = {
	Consumable.DAYLIGHT: 1.0,
	Consumable.LUMBER: 20.0,
	Consumable.COAL: 2.5,
	Consumable.IRON: 0.0,
	Consumable.WIND: 0.0,
	Consumable.GOLD: 0.0,
}

# Consumable: Array[WaitListEntry]
# Essentially a subscribable wait list for when resources run out.
# The first entry in the waitlist to have a minimum amount lower than the new
# amount will use the resource. Minimum amounts of 0 will be called as soon as
# any amount of resources are avaliable. (Therefore, non-consumable resource
# entries with a minimum of 0 will all be called when it is avaliable.)
var _wait_list: Dictionary = {}
var _unconditional_listeners: Array[Callable] = []


func supply(consumable: Consumable, amount: float) -> void:
	if consumable in NONCONSUMABLE:
		_counts[consumable] = amount
	else:
		_counts[consumable] += amount
	
	# This is mainly for nonconsumables, since they use supply to set the count.
	if amount == 0.0:
		return
	
	_notify_unconditional_listeners(consumable, _counts[consumable])
	_supply_to_waitlist(consumable)


# Returns the amount that was used (consumable) / avaliable (nonconsumable).
func use(
	consumable: Consumable,
	maximum_amount: float,
	minimum_amount: float = 0.0,
) -> float:
	if consumable in NONCONSUMABLE:
		return _counts[consumable]
	else:
		if minimum_amount > _counts[consumable]:
			return 0.0
		if maximum_amount >= _counts[consumable]:
			var used: float = _counts[consumable]
			if not consumable in NONCONSUMABLE:
				_counts[consumable] = 0.0
			_notify_unconditional_listeners(consumable, _counts[consumable])
			return used
		
		_counts[consumable] -= maximum_amount
		_notify_unconditional_listeners(consumable, _counts[consumable])
		return maximum_amount


# true is returned if the resource is used, false otherwise.
func use_exactly(consumable: Consumable, amount: float) -> bool:
	return use(consumable, amount, amount) != 0.0

# This is better than just calling query and use a bunch of times in another script
# because this function ensures that is done atomically (nothing can be called in
# between the check and use.)
# costs: {Consumable: float}
func use_many_exactly(costs: Dictionary) -> bool:
	var not_avaliable_flag: bool = false
	for consumable in costs.keys():
		var amount_requested: float = costs[consumable]
		if query_amount(consumable) < amount_requested:
			not_avaliable_flag = true
			break
	
	if not_avaliable_flag:
		return false
	
	for consumable in costs.keys():
		var amount: float = costs[consumable]
		use_exactly(consumable, amount)
	
	return true


func use_when_avaliable(
	callback: Callable,
	consumable: Consumable,
	maximum_amount: float,
	minimum_amount: float = 0.0,
) -> void:
	if _counts[consumable] > minimum_amount:
		callback.call(use(consumable, maximum_amount, minimum_amount))
		return
	
	var wait_list_entry = WaitListEntry.new(
		minimum_amount, maximum_amount, callback
	)
	
	if not consumable in _wait_list:
		_wait_list[consumable] = [wait_list_entry]
		return
	
	_wait_list[consumable].append(wait_list_entry)


func cancel_use_when_avaliable(
		callback: Callable,
		consumable: Consumable
	) -> void:
	
	for entry_index in range(0, _wait_list[consumable].size()):
		var entry: WaitListEntry = _wait_list[consumable][entry_index]
		if entry.callback == callback:
			_wait_list[consumable].remove_at(entry_index)
			return
	
	push_warning(
		"No waitlist entry with " + str(callback) + " for "
		+ str(consumable) + " found."
	)


func subscribe_to_all_changes(callback: Callable) -> void:
	_unconditional_listeners.append(callback)


func query_amount(consumable: Consumable) -> float:
	return _counts[consumable]


# Due to the if statement in supply, we can assume that the consumable provided
# has a count of more than 0 (thus we can safely notify all nonconsumable entries
# with a minimum value of 0).
func _supply_to_waitlist(consumable: Consumable) -> void:
	if not consumable in _wait_list:
		return
	
	var waitlist_entries = _wait_list[consumable]# as Array[WaitListEntry]
	var remaining_entries = waitlist_entries.filter(
		func(entry: WaitListEntry):
			return _not_able_to_supply_entry(entry, consumable)
	)
	if not remaining_entries:
		_wait_list.erase(consumable)
	
	_wait_list[consumable] = remaining_entries


func _not_able_to_supply_entry(
	entry: WaitListEntry,
	consumable: Consumable
) -> bool:
	var current_amount: float = _counts[consumable]
	
	if entry.minimum_amount > current_amount:
		return true
	
	entry.used_callback.call(
		use(
			consumable,
			entry.maximum_amount,
			entry.minimum_amount
		)
	)
	
	return false


func _notify_unconditional_listeners(
	consumable: Consumable,
	total: float,
) -> void:
	for callback in _unconditional_listeners:
		callback.call(consumable, total)
