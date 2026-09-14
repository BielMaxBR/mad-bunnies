@tool
extends Path2D

var last_list = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var actual_list = curve.get_baked_points() as Array
	if last_list != actual_list:
		%Border.points = actual_list
		%Fill.polygon = actual_list
