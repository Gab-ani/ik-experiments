extends IKSolver
class_name BestFormCCDIK

@export var distance_weight : Curve
@export var stress_weight : Curve

@export var stress_value : Curve


func step() -> Array[float]:
	var output : Array[float] = cache.duplicate()
	
	var chosen_segment = choose_segment(output)
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


# what we return is a profit of rotation a segment by caclulating gained distance per gained stress
func count_potential_profit(cache : Array[float], i : int) -> float:
	var local_sim_cache = cache.duplicate()
	var curr_transform : Transform2D = get_cached_transform(local_sim_cache, i)
	var endpoint : Vector2 = get_cached_end_position(local_sim_cache, segments.size()-1)
	var joint_to_end : Vector2 = curr_transform.origin.direction_to(endpoint)
	var joint_to_goal : Vector2 = curr_transform.origin.direction_to(goal_position)
	var correction_angle : float = joint_to_end.angle_to(joint_to_goal)
	var ideal_angle : float = cache[i] + correction_angle
	var resulting_angle : float
	resulting_angle = clamp(ideal_angle, -segments[i].constraints, segments[i].constraints)
	local_sim_cache[i] = resulting_angle
	
	var alpha = abs(ideal_angle - resulting_angle)
	var e = curr_transform.origin.distance_to(endpoint)
	var l = curr_transform.origin.distance_to(goal_position)
	var potential_optimal_distance = sqrt(pow(e,2) + pow(l,2) - 2*e*l*cos(alpha))
	
	var current_distace = endpoint.distance_to(goal_position)
	var delta_distance = current_distace - potential_optimal_distance
	var distance_value = distance_weight.sample(delta_distance)
	
	var current_stress = count_stress(cache)
	var potential_stress = count_stress(local_sim_cache)
	var delta_stress = potential_stress - current_stress
	var stress_value = stress_weight.sample(delta_stress)
	
	#prints(i, delta_stress, delta_distance, distance_value / stress_value)
	
	return distance_value / stress_value


func count_stress(cache : Array[float]) -> float:
	var stress = 0
	for i in cache.size():
		var stress_delta : float = (cache[i] - segments[i].prefered_rotation) / segments[i].constraints
		# here left and right constraints make sense, TODO upgrade
		stress += stress_value.sample(stress_delta)
	return stress
