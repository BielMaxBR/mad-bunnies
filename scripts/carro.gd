extends Node2D


func _process(delta: float) -> void:
	var filhos = get_children()
	var size = filhos.size()
	var result = Vector2()
	
	for filho in filhos:
		result += filho.global_position
	if size:
		$Camera2D.global_position = result / size
