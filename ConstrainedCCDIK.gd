extends IKSolver
class_name ConstrainedCCDIK

@onready var last_touched_segment : int = 6


func step() -> Array[float]:
	var output : Array[float] = cache.duplicate()
	
	last_touched_segment = choose_segment()
	var endpoint : Vector2 = get_cached_end_position(output, segments.size()-1)
	var joint_to_end : Vector2 = get_cached_transform(output, last_touched_segment).origin.direction_to(endpoint)
	var joint_to_goal : Vector2 = get_cached_transform(output, last_touched_segment).origin.direction_to(goal_position)
	var correction_angle : float = joint_to_end.angle_to(joint_to_goal)
	output[last_touched_segment] += correction_angle
	if last_touched_segment != 0:
		output[last_touched_segment] = clamp(output[last_touched_segment], -segments[last_touched_segment].constraints, segments[last_touched_segment].constraints)
	
	return output


func choose_segment() -> int:
	last_touched_segment -= 1
	if last_touched_segment == -1:
		last_touched_segment = segments.size() - 1
	return last_touched_segment
