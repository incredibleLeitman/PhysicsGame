extends Node
#class_name Suvat

#S 		displacement
#U		initial velocity (v - a*t)
#V		final velocity
#A		acceleration
#T		time

func calculate_v (var u:float, var a:float, var t:float) -> float:
	return u + a*t 			# [1]

func calculate_s_by_uat (var u:float, var a:float, var t:float) -> float:
	return u*t + 0.5*a*t*t	# [2]
	
func calculate_s_by_uvt (var u:float, var v:float, var t:float) -> float:
	return 0.5*(u + v)*t	# [3]

func calculate_v_squared (var u:float, var a:float, var s:float) -> float:
	return u*u + 2*a*s 		# [4]
	
func calculate_s_by_vat (var v:float, var a:float, var t:float) -> float:
	return v*t - 0.5*a*t*t 	# [5]

func calculate_a (var u:float, var v:float, var t:float) -> float:
	return (v - u)/t
