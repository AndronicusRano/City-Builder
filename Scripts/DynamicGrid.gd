extends GridMap

enum {STRAIGHT, THREE_WAY, FOUR_WAY}

@onready var camera = $"../Camera Pos + Y-Rot/Camera Rot Pivot/Camera3D"
@onready var sphere = $"../CSGSphere3D"

var current_tile = null
var neighboring_tiles = [Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1)]


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
	$"../Label".text = str(origin) + str(ray)
	
	if intersection == {}:
		return
	
	intersection.y = 0
	sphere.position = intersection.position
	
	var tile_map_pos = local_to_map(intersection.position)
	
	var neighboring_orientation = 0
	
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		for tile in neighboring_tiles:
			var neighboring_tile = tile_map_pos + tile
		
			if get_cell_item(neighboring_tile) == INVALID_CELL_ITEM:
				continue
			neighboring_orientation = get_cell_item_orientation(neighboring_tile)
			if tile.x != 0 and neighboring_orientation % 10 != 0:
				set_cell_item(neighboring_tile, THREE_WAY)		
			elif tile.z != 0 and neighboring_orientation % 10 == 0:		
				set_cell_item(neighboring_tile, THREE_WAY, 16)
				
			$"../Label".text = str(neighboring_orientation)
		
		set_cell_item(tile_map_pos, STRAIGHT, neighboring_orientation)
		
		# 22 / 16 up/down  10 / 0 left/right
		
		
		
