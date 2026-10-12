extends CanvasLayer
##shown when the players health hits 0
##freezes the game and offers a retry

func _ready() -> void:
	#keep this screen responding while the rest of the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_freeze_gameplay()

##enemies and towers run in PROCESS_MODE_ALWAYS, so pausing the tree
##alone does not stop them, they have to be disabled one by one
func _freeze_gameplay() -> void:
	for node in get_tree().get_nodes_in_group("ENEMY"):
		node.process_mode = Node.PROCESS_MODE_DISABLED
	for node in get_tree().get_nodes_in_group("TOWER"):
		node.process_mode = Node.PROCESS_MODE_DISABLED

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
