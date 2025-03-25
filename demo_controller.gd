extends Node

@export var ik_solver : IKSolver


func _process(delta):
	if Input.is_action_just_released("ik_solve"):
		ik_solver.draw_solve()
	if Input.is_action_just_released("ik_step"):
		ik_solver.draw_step()
