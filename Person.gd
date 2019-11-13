extends KinematicBody

onready var pos_1 = $Position3D.global_transform.origin
onready var pos_2 = $Position3D2.global_transform.origin
var move_speed = 2.0
var goal_pos = null
var turn_speed = 180.0
var goal = 0
var goose = null

enum STATE {WALKING, RESTING, LOOKING}
var cur_state = STATE.WALKING
var last_state = STATE.WALKING

const REST_TIME = 2.0
var cur_rest_time = 0.0

onready var anim = $FarmerGraphics/AnimationPlayer

func _ready():
	goal_pos = pos_1
	anim.play("walk_loop")

func _physics_process(delta):
	if cur_state == STATE.WALKING:
		var dir = goal_pos - global_transform.origin
		dir.y = 0
		var dis = dir.length()
		dir = dir.normalized()
		move_and_collide(dir * delta * move_speed)
		look_at(global_transform.origin + dir, delta)
		if dis < 0.1:
			if goal == 0:
				goal_pos = pos_2
				goal = 1
			else:
				goal_pos = pos_1
				goal = 0
			set_rest_state()
	elif cur_state == STATE.RESTING:
		look_at(goal_pos, delta)
		cur_rest_time += delta
		if cur_rest_time > REST_TIME:
			set_walk_state()
	else:
		#face goose
		look_at(goose.global_transform.origin, delta)
		cur_rest_time += delta
		if cur_rest_time > REST_TIME:
			return_to_last_state()

func look_at(target_pos, t_delta):
	var our_pos = global_transform.origin
	our_pos.y = 0
	target_pos.y = 0
	var to_target = target_pos - our_pos
	var goal_rot = rad2deg(atan2(to_target.x, to_target.z))
	# otherwise slowly rotate to target
	if abs(angle_difference(goal_rot, rotation_degrees.y)) < turn_speed * t_delta:
		# prevent overshooting goal angle
		rotation_degrees.y = goal_rot
	else:
		#calc which direction to turn
		var right = global_transform.basis.x
		var turn_dir = 1
		if right.dot(to_target) < 0:
			turn_dir = -1
		rotation_degrees.y += turn_speed * turn_dir * t_delta

func angle_difference(from, to):
    return fposmod(to - from + 180,  180 * 2) - 180

func return_to_last_state():
	if last_state == STATE.RESTING:
		set_rest_state()
	elif last_state == STATE.WALKING:
		set_walk_state()
	elif last_state == STATE.LOOKING:
		set_look_state()

func set_rest_state():
	set_last_state()
	cur_state = STATE.RESTING
	cur_rest_time = 0.0
	anim.play("stand_loop")

func set_walk_state():
	set_last_state()
	cur_state = STATE.WALKING
	anim.play("walk_loop")

func set_look_state():
	set_last_state()
	cur_state = STATE.LOOKING
	cur_rest_time = 0.0
	anim.play("stand_loop")

func set_last_state():
	if cur_state != STATE.LOOKING:
		last_state = cur_state
