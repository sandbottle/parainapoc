extends KinematicBody2D

var sender = null
var target = null
var move
var hitcount = 0

export var steer_force = 50.0

var speed = 1000
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

func start(pos, dir, _sender,  _target = null):
	global_position = pos
	global_rotation = dir
	sender = _sender

	if (_target != null):
		speed = 500
		velocity = transform.x * speed
		
	target = _target

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _physics_process(delta):
	if (!target):
		global_position += transform.x * speed * delta
	else:
		if (is_instance_valid(target) && target.hitable):
			acceleration += seek()
			velocity += acceleration * delta
			velocity = velocity.clamped(speed)
			global_rotation = velocity.angle()
			global_position += velocity * delta
		else:
			target = null

func _on_area_body_entered(body):
	if (body != sender):
		if (is_instance_valid(body) && is_instance_valid(sender)):
			if (body.get('hitable') && body.get('team') != sender.get('team')):
				body.damaged(5)
		
				if (!target || hitcount == 5):
					queue_free()
					return
					
				hitcount += 1
				
		queue_free()
