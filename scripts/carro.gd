extends Node2D

var camera_zoom = 1
func _process(delta: float) -> void:
	var filhos = get_children()
	var size = filhos.size()
	var result = Vector2()
	
	for filho in filhos:
		result += filho.global_position
	if size:
		$Camera2D.global_position = result / size
	
	$Camera2D.zoom.x = lerpf($Camera2D.zoom.x,camera_zoom,0.5)
	$Camera2D.zoom.y = $Camera2D.zoom.x

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and not get_parent().build_mode:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera_zoom = clamp(camera_zoom * 1 + 0.1, 0.1, 2)
			
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera_zoom = clamp(camera_zoom * 1 - 0.1, 0.1, 2)
