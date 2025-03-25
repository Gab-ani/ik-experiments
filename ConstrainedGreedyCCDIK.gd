extends IKSolver
class_name ConstrainedGreedyCCDIK


var cache : Array[float]

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
	
	var chosen_segment = choose_segment(output)
	print(chosen_segment)
	var endpoint : Vector2 = get_cached_end_position(output, segments.size()-1)
	var joint_to_end : Vector2 = get_cached_transform(output, chosen_segment).origin.direction_to(endpoint)
	var joint_to_goal : Vector2 = get_cached_transform(output, chosen_segment).origin.direction_to(goal_position)
	var correction_angle : float = joint_to_end.angle_to(joint_to_goal)
	
	output[chosen_segment] += correction_angle
	if chosen_segment != 0:
		output[chosen_segment] = clamp(output[chosen_segment], -segments[chosen_segment].constraints, segments[chosen_segment].constraints)
	
	return output


func choose_segment(cache : Array[float]) -> int:
	var best_segment : int
	var best_profit : float = -INF
	for i in segments.size():
		var profit = count_potential_profit(cache, i)
		if profit > best_profit:
			best_profit = profit
			best_segment = i
	return best_segment

# count next angle and clamp it
# use law of cosines to get optimal distance
# count and return profit
func count_potential_profit(cache : Array[float], i : int) -> float:
	var curr_transform : Transform2D = get_cached_transform(cache, i)
	var endpoint : Vector2 = get_cached_end_position(cache, segments.size()-1)
	var joint_to_end : Vector2 = curr_transform.origin.direction_to(endpoint)
	var joint_to_goal : Vector2 = curr_transform.origin.direction_to(goal_position)
	var correction_angle : float = joint_to_end.angle_to(joint_to_goal)
	var ideal_angle : float = cache[i] + correction_angle
	var resulting_angle : float
	if i != 0:
		resulting_angle = clamp(ideal_angle, -segments[i].constraints, segments[i].constraints)
	else:
		resulting_angle = ideal_angle
	
	var alpha = abs(ideal_angle - resulting_angle)
	var e = curr_transform.origin.distance_to(endpoint)
	var l = curr_transform.origin.distance_to(goal_position)
	var potential_optimal_distance = sqrt(pow(e,2) + pow(l,2) - 2*e*l*cos(alpha))
	
	var current_distace = endpoint.distance_to(goal_position)
	return current_distace - potential_optimal_distance


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
