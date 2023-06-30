extends Node
@onready var building_folder = get_node("Buildings")
@onready var building_prefab = preload("res://Scenes/building.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	create_building(Vector3(0, 2, 0), 6)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_building(position: Vector3, floors):
	var building = building_prefab.instantiate()
	building_folder.add_child(building)
	building.position = position
	print(building.get_aabb())
	
