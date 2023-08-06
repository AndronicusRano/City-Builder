extends Node
@onready var building_folder = get_node("Buildings")
@onready var building_prefab = preload("res://Scenes/building.tscn")
@onready var gridmap = $"../GridMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	create_building(function(Vector3(0, 0, 0)), 6)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_building(position: Vector3, floors):
	const building_height = 1
	var building = Node3D.new()
	building.position = position
	for floor_number in floors:
		var floor = building_prefab.instantiate()
		building.add_child(floor)
		floor.position = position
		position.y = position.y + building_height
	building_folder.add_child(building)
	
func function(position: Vector3i):
	return gridmap.map_to_local(position)
	
	
	
