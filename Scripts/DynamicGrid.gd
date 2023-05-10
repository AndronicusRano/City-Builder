extends GridMap

enum {STRAIGHT, THREE_WAY, FOUR_WAY, TURN}

@onready var camera = $"../Camera Pos + Y-Rot/Camera Rot Pivot/Camera3D"
@onready var sphere = $"../CSGSphere3D"

var current_tile = null
var neighboring_tiles = [Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1)]
var diagonal_tiles = [Vector3i(1, 0, 1), Vector3i(1, 0, -1), Vector3i(-1, 0, 1), Vector3i(-1, 0, -1)]

func _ready():
	print(get_used_cells())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mousePos = get_viewport().get_mouse_position()
	var ray = camera.project_ray_normal(mousePos) * 10000
	var origin = camera.project_ray_origin(mousePos)
	var query = PhysicsRayQueryParameters3D.create(origin, ray)
	var intersection = get_world_3d().direct_space_state.intersect_ray(query)

	
	if Input.is_key_pressed(KEY_M):
		current_tile = STRAIGHT
	#$"../Label".text = str(origin) + str(ray)
	
	if intersection == {}:
		return
	
	intersection.y = 0
	sphere.position = intersection.position
	
	var tile_map_pos = local_to_map(intersection.position)
	
	var neighboring_orientation = 0
	
	
	if Input.is_action_just_released("place_tile"):
		for tile in neighboring_tiles:
			var neighboring_tile_pos = tile_map_pos + tile
			var neighboring_tile = get_cell_item(neighboring_tile_pos)
		
			if neighboring_tile == INVALID_CELL_ITEM:
				continue
			
			neighboring_orientation = get_cell_item_orientation(neighboring_tile_pos)
			var is_facing_tile = neighboring_tile_is_facing_tile(tile, neighboring_orientation)
			print(is_facing_tile)
			
			var diagonals = []
			for diagonal_tile in diagonal_tiles:
				
				if tile.x != 0 and tile.x == diagonal_tile.x and get_cell_item(diagonal_tile + tile_map_pos) != INVALID_CELL_ITEM:
					diagonals.append(diagonal_tile)
				elif tile.z != 0 and tile.z == diagonal_tile.z and get_cell_item(diagonal_tile + tile_map_pos) != INVALID_CELL_ITEM:
					diagonals.append(diagonal_tile)
			$"../Label".text = str(diagonals)
			
			if len(diagonals) == 1:
				set_cell_item(neighboring_tile_pos, TURN)
				set_cell_item(tile_map_pos, STRAIGHT)
			elif neighboring_tile == STRAIGHT and is_facing_tile == false:
				if tile.x == -1:
					set_cell_item(neighboring_tile_pos, THREE_WAY, 16)
				elif tile.x == 1:
					set_cell_item(neighboring_tile_pos, THREE_WAY, 22)
				elif tile.z == -1:
					set_cell_item(neighboring_tile_pos, THREE_WAY, 0)
				elif tile.z == 1:
					set_cell_item(neighboring_tile_pos, THREE_WAY, 10)
					
				var new_tile_orientation
				if neighboring_orientation % 10 == 0: # If the orientation is left/right
					new_tile_orientation = 16
				elif neighboring_orientation % 10 != 0: # If the orientation is up/down
					new_tile_orientation = 0
				set_cell_item(tile_map_pos, STRAIGHT, new_tile_orientation)
			
			elif neighboring_tile == STRAIGHT and is_facing_tile == true:
				set_cell_item(tile_map_pos, STRAIGHT, neighboring_orientation)
				
			elif neighboring_tile == THREE_WAY:
				set_cell_item(neighboring_tile_pos, FOUR_WAY)
				set_cell_item(tile_map_pos, STRAIGHT, neighboring_orientation)
		
		# 22 / 16 up/down  10 / 0 left/right
func neighboring_tile_is_facing_tile(neighboring_tile_relative_pos, neighboring_tile_orientation):
	if neighboring_tile_orientation % 10 == 0: # If the orientation is left/right
		if neighboring_tile_relative_pos.x != 0: 
			return true
		else:
			return false
	elif neighboring_tile_orientation % 10 != 0: # If the orientation is up/down
		if neighboring_tile_relative_pos.x != 0:
			return false
		else:
			return true
