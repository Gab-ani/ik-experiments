extends Node
class_name IKSolver

var segments : Array[ArmSegment]

@export var debug_label : Label

@export var first_segment : ArmSegment
@export var tolerance : float = 1

var goal_position : Vector2

func _ready():
	segments.append(first_segment)
	build_chain(first_segment)


func build_chain(segment : ArmSegment):
	for child in segment.get_children():
		if child is ArmSegment:
			segments.append(child)
			build_chain(child)


func draw_solve():
	set_pose(solve())
	redraw_constraints()

func draw_step():
	pass


func set_pose(angles : Array[float]):
	for i in segments.size():
		segments[i].rotation = angles[i]


func step() -> Array[float]:
	return []


func solve() -> Array[float]:
	return []


func redraw_constraints():
	for segment in segments:
		segment.redraw_constraints()

# if our "imagined" angles configuration returns a valuable solution for IK chain
## TODO unreachable
#func cache_goal_reached() -> bool:
	## TODO imagine cache
	#return segments[segments.size() - 1].end.global_position.distance_to(goal_position) < tolerance




































# asdsdgas
