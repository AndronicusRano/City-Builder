extends Node

enum {NORMAL, ROAD, ZONE}

@export var modes : Modes
@export var current_mode = Modes.NORMAL


# Called when the node enters the scene tree for the first time.
func _ready():
	print("test")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
