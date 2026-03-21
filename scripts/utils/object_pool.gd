extends Node
## Object pooling system for efficient reuse of frequently created objects
class_name ObjectPool

var pools: Dictionary = {}

## Register a new object pool
func register_pool(pool_name: String, scene_path: String, initial_size: int = 10) -> void:
	if pool_name in pools:
		push_warning("Pool already exists: ", pool_name)
		return

	if not ResourceLoader.exists(scene_path):
		push_error("Scene not found for pool: ", scene_path)
		return

	var pool_data = {
		"scene_path": scene_path,
		"available": [],
		"in_use": []
	}

	# Pre-create instances
	for i in range(initial_size):
		var instance = load(scene_path).instantiate()
		instance.visible = false
		add_child(instance)
		pool_data["available"].append(instance)

	pools[pool_name] = pool_data

## Get an instance from the pool
func get_instance(pool_name: String) -> Node:
	if pool_name not in pools:
		push_error("Pool not found: ", pool_name)
		return null

	var pool_data = pools[pool_name]
	var instance: Node = null

	if pool_data["available"].size() > 0:
		instance = pool_data["available"].pop_back()
	else:
		# Create new instance if pool is empty
		instance = load(pool_data["scene_path"]).instantiate()
		add_child(instance)

	pool_data["in_use"].append(instance)
	instance.visible = true
	return instance

## Return an instance to the pool
func return_instance(pool_name: String, instance: Node) -> void:
	if pool_name not in pools:
		push_error("Pool not found: ", pool_name)
		return

	var pool_data = pools[pool_name]
	if instance in pool_data["in_use"]:
		pool_data["in_use"].erase(instance)
		pool_data["available"].append(instance)
		instance.visible = false
		if instance.has_method("reset"):
			instance.reset()

## Get pool statistics
func get_pool_stats(pool_name: String) -> Dictionary:
	if pool_name not in pools:
		return {}

	var pool_data = pools[pool_name]
	return {
		"available": pool_data["available"].size(),
		"in_use": pool_data["in_use"].size(),
		"total": pool_data["available"].size() + pool_data["in_use"].size()
	}

## Clear all pools
func clear_all() -> void:
	for pool_name in pools.keys():
		var pool_data = pools[pool_name]
		for instance in pool_data["available"]:
			instance.queue_free()
		for instance in pool_data["in_use"]:
			instance.queue_free()
	pools.clear()
