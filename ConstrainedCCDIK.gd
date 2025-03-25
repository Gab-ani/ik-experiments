extends IKSolver
class_name ConstrainedCCDIK

var cache : Array[float]

@onready var last_touched_segment : int = 6

# TODO clean up draw solve from solve
func solve() -> Array[float]:
	var iterations : int = 0
	var start = Time.get_unix_time_from_system()
	fill_cache()
	goal_position = get_viewport().get_mouse_position()
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


func step() -> Array[float]:
	var output : Array[float] = cache.duplicate()
	last_touched_segment -= 1
	if last_touched_segment == -1:
		last_touched_segment = segments.size() - 1
	
	var endpoint : Vector2 = get_cached_end_position(output, segments.size()-1)
	var joint_to_end : Vector2 = get_cached_transform(output, last_touched_segment).origin.direction_to(endpoint)
	var joint_to_goal : Vector2 = get_cached_transform(output, last_touched_segment).origin.direction_to(goal_position)
	var correction_angle : float = joint_to_end.angle_to(joint_to_goal)
	output[last_touched_segment] += correction_angle
	if last_touched_segment != 0:
		output[last_touched_segment] = clamp(output[last_touched_segment], -segments[last_touched_segment].constraints, segments[last_touched_segment].constraints)
	
	return output


func choose_segment(cache : Array[float]) -> int:
	last_touched_segment -= 1
	if last_touched_segment == -1:
		last_touched_segment = 6
	return last_touched_segment


func count_cached_distance(cache : Array[float], i : int) -> float:
	var endpoint = get_cached_end_position(cache, segments.size() - 1)
	var position = get_cached_transform(cache, i).origin
	return abs(position.distance_to(goal_position) - position.distance_to(endpoint))


func fill_cache():
	cache.clear()
	for segment in segments:
		cache.append(segment.rotation)


func get_cached_transform(output : Array[float], segment : int) -> Transform2D:
	var transform : Transform2D = Transform2D(output[0], segments[0].global_position)
	for i in range(1, segment + 1):
		transform = transform * Transform2D(output[i], segments[i].position)
	return transform

func get_cached_end_position(output : Array[float], segment : int) -> Vector2:
	var transform : Transform2D = Transform2D(output[0], segments[0].global_position)
	for i in range(1, segment + 1):
		transform = transform * Transform2D(output[i], segments[i].position)
	return transform * Vector2(segments[segments.size() - 1].length, 0)


# if our "imagined" angles configuration returns a valuable solution for IK chain
# TODO unreachable
func cache_goal_reached() -> bool:
	return get_cached_end_position(cache, segments.size() - 1).distance_to(goal_position) < tolerance



































# asdsdgas
