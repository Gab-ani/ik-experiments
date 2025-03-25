extends Node
class_name IKSolver

var segments : Array[ArmSegment]

@export var debug_label : Label

@export var first_segment : ArmSegment
@export var tolerance : float = 1

var goal_position : Vector2

var cache : Array[float]

func _ready():
	segments.append(first_segment)
	build_chain(first_segment)


func build_chain(segment : ArmSegment):
	for child in segment.get_children():
		if child is ArmSegment:
			segments.append(child)
			build_chain(child)


func draw_solve():
	fill_cache()
	goal_position = get_viewport().get_mouse_position()
	set_pose(solve())
	redraw_constraints()


# TODO clean up draw solve from solve
func solve() -> Array[float]:
	var start = Time.get_unix_time_from_system()
	var iterations : int = 0
	while not cache_goal_reached(): 
		cache = step()
		iterations += 1
	debug_label.text = str(iterations) + " iterations to solve \n"
	debug_label.text += str((Time.get_unix_time_from_system() - start) * 1000) + " ms spent"
	return cache


func draw_step():
	fill_cache()
	goal_position = get_viewport().get_mouse_position()
	set_pose(step())
	redraw_constraints()


func set_pose(angles : Array[float]):
	for i in segments.size():
		segments[i].rotation = angles[i]


func step() -> Array[float]:
	return []


func fill_cache():
	cache.clear()
	for segment in segments:
		cache.append(segment.rotation)


func redraw_constraints():
	for segment in segments:
		segment.redraw_constraints()


# if our "imagined" angles configuration returns a valuable solution for IK chain
# TODO unreachable
func cache_goal_reached() -> bool:
	return get_cached_end_position(cache, segments.size() - 1).distance_to(goal_position) < tolerance


func get_cached_transform(output : Array[float], segment : int) -> Transform2D:
	var transform : Transform2D = Transform2D(output[0], segments[0].global_position)
	for i in range(1, segment + 1):
		transform = transform * Transform2D(output[i], segments[i].position)
	return transform


func get_cached_end_position(output : Array[float], segment : int) -> Vector2:
	var transform : Transform2D = Transform2D(output[0], segments[0].global_position)
	for i in range(1, segment + 1):
		transform = transform * Transform2D(output[i], segments[i].position)
	return transform * Vector2(segments[segment].length, 0)


func count_cached_distance(cache : Array[float], i : int) -> float:
	var endpoint = get_cached_end_position(cache, segments.size() - 1)
	var position = get_cached_transform(cache, i).origin
	return abs(position.distance_to(goal_position) - position.distance_to(endpoint))






























# asdsdgas
