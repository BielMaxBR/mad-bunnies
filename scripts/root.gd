extends Node2D

var build_mode = true

func _ready() -> void:
	$Builder.builded.connect(_builded)
	get_tree().paused = true
	
func _builded():
	$Builder.hide()
