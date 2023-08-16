extends Node

enum Modes {NORMAL, ROAD, ZONE}

@export var modes = Modes
@export var current_mode = Modes.NORMAL


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("enter_zone_mode"):
		current_mode = Modes.ZONE
	elif Input.is_action_just_released("enter_road_mode"):
		current_mode = Modes.ROAD
		
		
