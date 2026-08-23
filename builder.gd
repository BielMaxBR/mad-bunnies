extends Node2D

@export var size = Vector2i(5,5)
@export var root: Node2D

var menu_items: Array[Item] = []
var selected_item = -1
var grid: Dictionary[Vector2i, Dictionary] = {}

var angle = 0 # angulo atual

var center_reset = Vector2()

var is_left_pressing = false
var is_right_pressing = false

var pos: Vector2i # usado pra posição da grid do mouse

signal builded
func add_items():
	add("bloco",preload('res://bloco.tscn'))
	add("roda",preload('res://roda.tscn'),[Vector2.LEFT,Vector2.RIGHT,Vector2.DOWN])

func is_on_grid(pos: Vector2i):
	var rect = Rect2i(Vector2.ZERO,size)
	
	return rect.has_point(pos + size/2)

func add(_name, _scene,falses = []):
	var item = Item.new(_name,_scene)
	for dir in falses:
		item.sides[dir] = false
	menu_items.append(item)
	
	create_item_buttom(_name,_scene)

func create_item_buttom(_name,_scene):
	var button: TextureButton = preload("res://botao_default.tscn").instantiate()
	button.get_node("Label").text = _name
	$GUI/Control/MenuLeft/VBoxContainer.add_child(button)
	
	var mock_scene: Node2D = _scene.instantiate()
	mock_scene.process_mode = Node.PROCESS_MODE_DISABLED
	button.get_node("SubViewport").add_child(mock_scene)
	
	var id = menu_items.size() - 1
	var onpress = func():
		selected_item = id
		$preview.texture = button.texture_normal
	button.pressed.connect(onpress)
	
func _ready() -> void:
	generate_background()
	add_items()

func _process(_delta: float) -> void:
	pos = $tiles.local_to_map(get_local_mouse_position())
	if is_left_pressing:
		spawn_block()
	if is_right_pressing:
		delete_block()
	$preview.visible =  is_on_grid(pos)
	$preview.position = $tiles.map_to_local(pos)
	$preview.rotation = PI/2 * angle

func generate_background():
	for x in size.x:
		for y in size.y:
			var _pos = Vector2i(x,y) - size/2
			$background.set_cell(_pos,0,Vector2(0,0),0)
	# set camera center
	if size.x % 2 == 0:
		$Camera2D.position.x = 0
	if size.y % 2 == 0:
		$Camera2D.position.y = 0
	center_reset = $Camera2D.position

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_left_pressing = event.pressed
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_right_pressing = event.pressed
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			angle = (angle + 1) % 4 
			#print(angle)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			angle = (angle - 1) % 4
			if angle == -1: angle = 3

func spawn_block():
	if not is_on_grid(pos): return
	if grid.has(pos): return
	if selected_item == -1: return
	var item = menu_items[selected_item]
	
	var block: Node2D = item.scene.instantiate()
	block.rotation = PI/2 * angle
	block.global_position = $tiles.map_to_local(pos) + position
	
	if root:
		root.add_child(block)
	else:
		add_child(block)
		
	#block.process_mode = Node.PROCESS_MODE_DISABLED
	grid.set(pos,{"item": item,"block": block, "angle":angle})

func delete_block():
	if not is_on_grid(pos): return
	if not grid.has(pos): return
	
	var block = grid.get(pos).block
	block.queue_free()
	grid.erase(pos)

func _on_build_pressed() -> void:
	for item_pos: Vector2i in grid:
		var block: Node2D = grid[item_pos].block
		var item: Item = grid[item_pos].item
		var block_angle: int = grid[item_pos].angle
		
		for side: Vector2 in item.sides:
			if item.sides[side] == false: continue
			var dir = side.rotated(block_angle*PI/2)
			if not grid.has(item_pos + Vector2i(dir)): continue
			var neighbor = grid[item_pos + Vector2i(dir)]
			var reverse = Vector2(dir.rotated(neighbor.angle*-PI/2) * -1).round()
			if neighbor.item.sides[reverse] == false: continue
			var new_pin := PinJoint2D.new()
			new_pin.bias = 0.01
			new_pin.node_a = ".."
			new_pin.node_b = "../../%s" % [neighbor.block.name]
			block.add_child(new_pin)
			new_pin.position = Vector2((Vector2(dir) + Vector2(dir).rotated(-PI/2)) * 64).rotated(block_angle*-PI/2)

	get_tree().paused = false

	grid = {}
	builded.emit()
