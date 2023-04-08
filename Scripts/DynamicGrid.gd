extends GridMap

enum {STRAIGHT, THREE_WAY, FOUR_WAY}
var current_tile = null
@onready var camera = $"../Camera Pos + Y-Rot/Camera Rot Pivot/Camera3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_used_cells())
	set_cell_item(Vector3i(0, 0, 0), 0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mousePos = get_viewport().get_mouse_position()
	var ray = camera.project_ray_normal(mousePos)
	var origin = camera.project_ray_origin(mousePos)
	var query = PhysicsRayQueryParameters3D.create(origin, ray)
	
	if Input.is_key_pressed(KEY_M):
		current_tile = STRAIGHT
	$"../Label".text = str(get_world_3d().direct_space_state.intersect_ray(query))
	
		
		
