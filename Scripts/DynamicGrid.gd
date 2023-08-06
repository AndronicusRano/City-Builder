extends GridMap

enum {STRAIGHT, THREE_WAY, FOUR_WAY, TURN}

enum {UP = 22, DOWN = 16, LEFT = 10, RIGHT = 0}
enum {UP_3_WAY = 10, DOWN_3_WAY = 0, LEFT_3_WAY = 22, RIGHT_3_WAY = 16}
enum {UP_RIGHT = 10, UP_LEFT = 22, DOWN_RIGHT = 16, DOWN_LEFT = 0}
#enum {UP_RIGHT = 0, UP_LEFT = 10, DOWN_RIGHT = 16, DOWN_LEFT = 22}
# 22: left  10: up
# 22 / 16 up/down  10 / 0 left/right

@onready var camera = $"../Camera Pos + Y-Rot/Camera Rot Pivot/Camera3D"
@onready var sphere = $"../CSGSphere3D"
@onready var mode_manager = $"../ModeManager"

var neighboring_tiles = [Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1)]

var TOP_TILE = neighboring_tiles[3]
var BOTTOM_TILE = neighboring_tiles[2]
var LEFT_TILE = neighboring_tiles[1]
var RIGHT_TILE = neighboring_tiles[0]

var diagonal_tiles = [Vector3i(1, 0, 1), Vector3i(1, 0, -1), Vector3i(-1, 0, 1), Vector3i(-1, 0, -1)]


func _process(delta):
	#if mode_manager.get("current_mode") != mode_manager.get("modes")["ROAD_MODE"]:
	#	return
	
	var mousePos = get_viewport().get_mouse_position()
	var ray = camera.project_ray_normal(mousePos) * 10000
	var origin = camera.project_ray_origin(mousePos)
	var query = PhysicsRayQueryParameters3D.create(origin, ray)
	var intersection = get_world_3d().direct_space_state.intersect_ray(query)
	if intersection == {}:
		return
	
	intersection.y = 0 # Keeps the placement of tiles on the ground
	sphere.position = intersection.position # Moves the cursor
	
	var tile_pos = local_to_map(intersection.position)
	#$"../Label".text = str("debug")
	if Input.is_action_just_released("place_tile") and get_cell_item(tile_pos) == INVALID_CELL_ITEM:
		
		orientate_tile_from_neighboring_tiles(tile_pos)
		
		for local_neighboring_tile_pos in neighboring_tiles:
			var neighboring_tile_pos = tile_pos + local_neighboring_tile_pos
			
			if get_cell_item(neighboring_tile_pos) == INVALID_CELL_ITEM:
				continue
			
			orientate_tile_from_neighboring_tiles(neighboring_tile_pos)
		
	elif Input.is_action_just_released("remove_tile"):
		set_cell_item(tile_pos, INVALID_CELL_ITEM)
		for local_neighboring_tile_pos in neighboring_tiles:
			var neighboring_tile_pos = tile_pos + local_neighboring_tile_pos
			
			if get_cell_item(neighboring_tile_pos) == INVALID_CELL_ITEM:
				continue
			
			orientate_tile_from_neighboring_tiles(neighboring_tile_pos)


func orientate_tile_from_neighboring_tiles(tile_pos):
	var empty_neighbor_position
	var neighboring_tile_cells = []
	for local_neighboring_tile_pos in neighboring_tiles:
		var neighboring_tile_pos = tile_pos + local_neighboring_tile_pos
		var neighboring_tile = get_cell_item(neighboring_tile_pos)
		
		if neighboring_tile == INVALID_CELL_ITEM:
			empty_neighbor_position = local_neighboring_tile_pos
			continue
		neighboring_tile_cells.append(neighboring_tile_pos)
		
	if len(neighboring_tile_cells) == 1:
		var neighboring_cell = get_cell_item(neighboring_tile_cells[0])
		if does_neighboring_tile_have_same_orientation(neighboring_tile_cells[0] - tile_pos, get_cell_item_orientation(neighboring_tile_cells[0])):
			set_cell_item(tile_pos, STRAIGHT, get_cell_item_orientation(neighboring_tile_cells[0]))
		elif does_neighboring_tile_have_same_orientation(neighboring_tile_cells[0] - tile_pos, get_cell_item_orientation(neighboring_tile_cells[0])) == false:
			if get_cell_item_orientation(neighboring_tile_cells[0]) == UP or get_cell_item_orientation(neighboring_tile_cells[0]) == DOWN:
				set_cell_item(tile_pos, STRAIGHT, RIGHT)
			else:
				set_cell_item(tile_pos, STRAIGHT, UP)
	elif len(neighboring_tile_cells) == 2:
		if neighboring_tile_cells[0] == TOP_TILE + tile_pos or neighboring_tile_cells[1] == TOP_TILE + tile_pos:
			if neighboring_tile_cells[0] == LEFT_TILE + tile_pos or neighboring_tile_cells[1] == LEFT_TILE + tile_pos:
				set_cell_item(tile_pos, TURN, UP_LEFT)
			elif neighboring_tile_cells[0] == RIGHT_TILE + tile_pos or neighboring_tile_cells[1] == RIGHT_TILE + tile_pos: 
				set_cell_item(tile_pos, TURN, UP_RIGHT)
			else:
				set_cell_item(tile_pos, STRAIGHT, UP) 
		elif neighboring_tile_cells[0] == BOTTOM_TILE + tile_pos or neighboring_tile_cells[1] == BOTTOM_TILE + tile_pos:
			if neighboring_tile_cells[0] == LEFT_TILE + tile_pos or neighboring_tile_cells[1] == LEFT_TILE + tile_pos:
				set_cell_item(tile_pos, TURN, DOWN_LEFT)
			elif neighboring_tile_cells[0] == RIGHT_TILE + tile_pos or neighboring_tile_cells[1] == RIGHT_TILE + tile_pos:
				set_cell_item(tile_pos, TURN, DOWN_RIGHT)
			else:
				set_cell_item(tile_pos, STRAIGHT, UP)
		elif (neighboring_tile_cells[0] == LEFT_TILE + tile_pos or neighboring_tile_cells[1] == LEFT_TILE + tile_pos) and (neighboring_tile_cells[0] == RIGHT_TILE + tile_pos or neighboring_tile_cells[1] == RIGHT_TILE + tile_pos):
			set_cell_item(tile_pos, STRAIGHT, RIGHT)
			pass
	elif len(neighboring_tile_cells) == 3:
		var new_orientation = 0
		if empty_neighbor_position == RIGHT_TILE:
			new_orientation = LEFT_3_WAY
		elif empty_neighbor_position == LEFT_TILE:
			new_orientation = RIGHT_3_WAY
		elif empty_neighbor_position == BOTTOM_TILE:
			new_orientation = UP_3_WAY
		elif empty_neighbor_position == TOP_TILE:
			new_orientation = DOWN_3_WAY
		set_cell_item(tile_pos, THREE_WAY, new_orientation)
	elif len(neighboring_tile_cells) == 4:
		set_cell_item(tile_pos, FOUR_WAY)


func does_neighboring_tile_have_same_orientation(neighboring_tile_relative_pos, neighboring_tile_orientation):
	if neighboring_tile_orientation == LEFT or neighboring_tile_orientation == RIGHT:
		if neighboring_tile_relative_pos.x != 0: 
			return true
		else:
			return false
	elif neighboring_tile_orientation == UP or neighboring_tile_orientation == DOWN: # If the orientation is up/down
		if neighboring_tile_relative_pos.x != 0:
			return false
		else:
			return true 
