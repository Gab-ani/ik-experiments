extends Node2D
class_name ArmSegment

@export var constraints : float = PI / 2.5
@export var prefered_rotation : float

@onready var start = $start as Node2D
@onready var end = $end as Node2D


var length : float

func _ready():
	length = end.global_position.distance_to(start.global_position)
	
	#rotation = randf_range(-constraints, constraints)
	prefered_rotation = rotation
	
	for child in get_children():
		if child is ArmSegment:
			child.position = end.position
	
	if abs(prefered_rotation) > constraints:
		print_tree()
		push_error("prefered rotation is out of constraints ")
	
	redraw_constraints()

func redraw_constraints():
	var parent = get_parent()
	if parent is ArmSegment:
		$PuncLeft.global_position = global_position
		$PunctRight.global_position = global_position
		$PuncLeft.global_rotation = parent.global_rotation - constraints
		$PunctRight.global_rotation = parent.global_rotation + constraints
	else:
		$PuncLeft.rotation = -constraints
		$PunctRight.rotation = constraints
