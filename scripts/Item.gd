extends RefCounted
class_name Item

var sides = {
	Vector2.UP: true,
	Vector2.DOWN: true,
	Vector2.LEFT: true,
	Vector2.RIGHT: true,
}

var scene: PackedScene
var name = ""

func _init(_name,_scene):
	name = _name
	scene = _scene
