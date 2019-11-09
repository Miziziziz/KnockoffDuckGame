extends KinematicBody

var move_speed = 3.0

var blank_path = null
func _ready():
	blank_path = $PinJoint.get_node_b()
	for p in get_tree().get_nodes_in_group("person"):
		p.goose = self

func _physics_process(delta):
	var move_vec = Vector3()
	move_vec.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	move_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	#var move_vec = Vector3(Input.get_joy_axis(0, JOY_AXIS_0), 0.0, Input.get_joy_axis(0, JOY_AXIS_1))
	move_and_collide(move_speed * move_vec * delta)
	if held_object:
		var dir = held_point.global_transform.origin - global_transform.origin
		$Graphics.rotation.y = Vector2(dir.z, dir.x).angle()
	elif move_vec != Vector3():
		$Graphics.rotation.y = Vector2(move_vec.z, move_vec.x).angle()

var held_object = null
var held_point = null
func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("honk"):
		$AudioStreamPlayer.play()
		for p in get_tree().get_nodes_in_group("person"):
			p.set_look_state()
	
	if Input.is_action_just_pressed("grab"):
		var bodies = $Area.get_overlapping_bodies()
		if bodies.size() > 0:
			held_object = bodies[0]
			$PinJoint.set_node_b(held_object.get_path())
			
			var points = held_object.get_node("Points").get_children()
			var closest_point = held_object
			var dis = 99999
			for point in points:
				var t_d = global_transform.origin.distance_to(point.global_transform.origin)
				if t_d < dis:
					dis = t_d
					closest_point = point
			held_point = closest_point
	
	if Input.is_action_just_released("grab") and held_object:
		$PinJoint.set_node_b(blank_path)
		held_object = null


