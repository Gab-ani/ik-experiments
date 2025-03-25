extends IKSolver
class_name ConstrainedGreedyCCDIK


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
