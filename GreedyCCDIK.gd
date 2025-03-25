extends IKSolver
class_name GreedyCCDIK


func step() -> Array[float]:
	var output : Array[float] = cache.duplicate()
	
	var chosen_segment = choose_segment(output)
	var endpoint : Vector2 = get_cached_end_position(output, segments.size()-1)
	var joint_to_end : Vector2 = get_cached_transform(output, chosen_segment).origin.direction_to(endpoint)
	var joint_to_goal : Vector2 = get_cached_transform(output, chosen_segment).origin.direction_to(goal_position)
	var correction_angle : float = joint_to_end.angle_to(joint_to_goal)
	output[chosen_segment] += correction_angle
	
	return output


func choose_segment(cache : Array[float]) -> int:
	var best_segment : int
	var best_distance : float = INF
	for i in segments.size():
		var distance = count_cached_distance(cache, i)
		if distance < best_distance:
			best_distance = distance
			best_segment = i
	print(best_distance)
	return best_segment
