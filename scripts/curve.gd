@tool
extends Path2D

var last_list = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		await get_tree().process_frame
		$StaticBody2D/CollisionPolygon2D.polygon = curve.get_baked_points()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var actual_list = curve.get_baked_points() as Array
		if last_list != actual_list:
			%Border.points = actual_list
			%Fill.polygon = actual_list
