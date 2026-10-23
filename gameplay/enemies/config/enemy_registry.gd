extends RefCounted
##Collects complete enemy configs into the flat lookup used by map spawning.

const Fast = preload("res://gameplay/enemies/config/fast.gd")
const Strong = preload("res://gameplay/enemies/config/strong.gd")
const Boss = preload("res://gameplay/enemies/config/boss.gd")
const Camo = preload("res://gameplay/enemies/config/camo.gd")
const Fly = preload("res://gameplay/enemies/config/fly.gd")

static var enemies_config: Dictionary = {
	"fast": Fast.config,
	"strong": Strong.config,
	"boss": Boss.config,
	"camo": Camo.config,
	"fly": Fly.config,
}

static func validate_enemies_config() -> void:
	var required_fields: Array[String] = [
		"name",
		"health",
		"speed",
		"bounty",
		"leak_damage",
		"texture",
	]
	for enemy_key in enemies_config:
		var enemy: Dictionary = enemies_config[enemy_key]
		assert(!enemy.is_empty(), "EMPTY ENEMY CONFIG FOR " + str(enemy_key))
		for field in required_fields:
			assert(enemy.has(field), "MISSING " + field + " IN ENEMY CONFIG FOR " + str(enemy_key))
		assert(str(enemy["name"]) == str(enemy_key),
			"ENEMY NAME MISMATCH FOR " + str(enemy_key))
		assert(float(enemy["health"]) > 0.0,
			"ENEMY HEALTH MUST BE POSITIVE FOR " + str(enemy_key))
		assert(float(enemy["speed"]) >= 0.0,
			"ENEMY SPEED MUST NOT BE NEGATIVE FOR " + str(enemy_key))
		assert(enemy["texture"] is Texture2D,
			"ENEMY TEXTURE MUST BE A Texture2D FOR " + str(enemy_key))
