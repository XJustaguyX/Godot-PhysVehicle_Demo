extends Spatial

export var is_steer_wheel = false

# Gets references to nodes through variables for easy use
onready var car_p = get_parent()
onready var wheel = $CollisionPoint
onready var raycast = $RayCast

# For suspension calculations
var add_force = Vector3() # this gets sent to the parent Vehicle_Main script
var displacement = 0.0
var prev_displacement = 0.0
var speed = 0.0
var wheel_vel_vector

# gets last position of wheel in space. Used for friction calculation
var last_point = get_global_translation()

func _ready():
	raycast.cast_to.y = -car_p.sus_height

# SUSPENSION CALCULATIONS
func _physics_process(delta):
	vis_handle()
	calc_vel_vector()
	
	if(is_on_ground()):
		prev_displacement = displacement
		
		displacement = (raycast.cast_to - global_transform.xform_inv(raycast.get_collision_point())).length()
		speed = (displacement - prev_displacement) / delta
		
		var spring_force = car_p.gravity_scale * car_p.weight * car_p.sus_stiffness * displacement
		var sus_damp_force = car_p.sus_damp * speed
		add_force = Vector3.UP * clamp(spring_force + sus_damp_force, 0, 50)
	else:
		add_force = Vector3.ZERO

# HANDLES VISUAL SIDE (wheel turning, grounding the wheels)
func vis_handle():
	if is_on_ground():
		var wheel_pos = raycast.get_collision_point() + Vector3(0, 0.42, 0)
		wheel.global_transform.origin = lerp(wheel.global_transform.origin, wheel_pos, 0.2)
	if is_steer_wheel:
		rotation.y = car_p.turn
	if !car_p.inp_break:
		wheel.rotate_x(0.01*car_p.get_velocity(true))

func is_on_ground():
	if raycast.is_colliding():
		return true
	else:
		return false

func get_pos():
	return wheel.get_global_translation() - car_p.get_global_translation()

# Calculates linear velocity for each wheel separately for friction.
# This is done by subtracting the current position from the last frame's position.
func calc_vel_vector():
	wheel_vel_vector = get_global_translation() - last_point
	wheel_vel_vector = wheel_vel_vector.normalized()
	last_point = get_global_translation()

func get_vel_vector():
	return wheel_vel_vector

#return scalar multiplier for friction
func get_frict_mod():
	var x_normal # vector points to the side of wheel
	var z_normal # vector points to the front of wheel

	if is_on_ground():
		if is_steer_wheel:
			
			x_normal = global_transform.basis.x.rotated(car_p.transform.basis.y, car_p.turn)
			
			z_normal = global_transform.basis.z.rotated(car_p.transform.basis.y, car_p.turn)
			
		else:
			
			x_normal = global_transform.basis.x
			
			z_normal = global_transform.basis.z
		
		return [x_normal.dot(get_vel_vector()), -z_normal.dot(get_vel_vector())]
	else:
		return [0, 0]

func get_type():
	return int(!is_steer_wheel)
