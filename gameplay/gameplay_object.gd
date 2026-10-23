extends CharacterBody2D
class_name GameplayObject

enum MovementProfile {
	GROUND,
	FLYING,
}

enum MovementMode {
	NAVIGATION,
	DIRECT,
}

@export var movement_profile: MovementProfile = MovementProfile.GROUND
@export var movement_mode: MovementMode = MovementMode.NAVIGATION
@export var movement_speed: float = 100.0
@export var navigation_layers: int = 3
@export var arrival_distance: float = 12.0

var navigation_agent: NavigationAgent2D
var movement_target_position: Vector2 = Vector2.ZERO
var movement_target_set: bool = false


func configure_movement(config: Dictionary) -> void:
	# Profiles describe actor capabilities; navigation layers select actual map geometry.
	var configured_profile := int(config.get("movement_profile", movement_profile))
	if MovementProfile.values().has(configured_profile):
		movement_profile = configured_profile as MovementProfile
	var configured_mode := int(config.get("movement_mode", movement_mode))
	if MovementMode.values().has(configured_mode):
		movement_mode = configured_mode as MovementMode
	movement_speed = maxf(float(config.get("speed", config.get("move_speed", movement_speed))), 0.0)
	navigation_layers = int(config.get("navigation_layers", navigation_layers))
	arrival_distance = maxf(float(config.get("arrival_distance", arrival_distance)), 0.0)
	_apply_navigation_settings()


func set_movement_target(position: Vector2) -> void:
	movement_target_position = position
	movement_target_set = true
	if movement_mode == MovementMode.NAVIGATION:
		_ensure_navigation_agent()
		navigation_agent.target_position = position


func clear_movement_target() -> void:
	movement_target_set = false
	velocity = Vector2.ZERO
	if navigation_agent != null:
		navigation_agent.target_position = global_position


func get_movement_direction() -> Vector2:
	if !movement_target_set:
		return Vector2.ZERO
	if global_position.distance_to(movement_target_position) <= arrival_distance:
		return Vector2.ZERO
	if movement_mode == MovementMode.DIRECT:
		return global_position.direction_to(movement_target_position)

	_ensure_navigation_agent()
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	return global_position.direction_to(next_path_position)


func is_movement_target_reached() -> bool:
	if !movement_target_set:
		return true
	if global_position.distance_to(movement_target_position) <= arrival_distance:
		return true
	if movement_mode == MovementMode.NAVIGATION:
		_ensure_navigation_agent()
		return navigation_agent.is_target_reached()
	return false


func move_in_direction(direction: Vector2, speed: float = -1.0) -> void:
	var actual_speed := movement_speed if speed < 0.0 else maxf(speed, 0.0)
	velocity = direction.normalized() * actual_speed
	move_and_slide()


func _ensure_navigation_agent() -> void:
	if navigation_agent != null:
		return
	navigation_agent = get_node_or_null("NavigationAgent2D") as NavigationAgent2D
	if navigation_agent == null:
		navigation_agent = NavigationAgent2D.new()
		navigation_agent.name = "NavigationAgent2D"
		navigation_agent.path_desired_distance = 24.0
		add_child(navigation_agent)
	_apply_navigation_settings()


func _apply_navigation_settings() -> void:
	if navigation_agent == null:
		return
	navigation_agent.navigation_layers = navigation_layers
	navigation_agent.target_desired_distance = arrival_distance
