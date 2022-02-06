extends StaticBody2D

const MIN_X =  5.0
const MAX_X = 75.0
const MIN_Y = -40.0
const MAX_Y =  20.0

onready var player = get_node('/root/game/player')
onready var tween = get_node("tween")
onready var detect = get_node("detect")
onready var timer = get_node("timer")

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var speed = 500

var gravity = 2000
var detected = false

func _ready():
	var direction = 1 if randi() % 2 == 0 else -1
	var goal = global_position + Vector2(rand_range(MIN_X, MAX_X), rand_range(MIN_Y, MAX_Y)) * direction
	
	tween.interpolate_property(self, "position:x", null, goal.x, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self, "position:y", null, goal.y - 50, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(self, "position:y", goal.y - 50, goal.y, 0.4, Tween.TRANS_QUAD, Tween.EASE_IN, 0.4)
	tween.interpolate_property(self, "position:y", goal.y, goal.y - 10, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN, 0.8)
	tween.interpolate_property(self, "position:y", goal.y - 10, goal.y, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN, 0.9)

	tween.start()
	timer.start()
		
func _physics_process(_delta):
	if (detected):
		global_position = lerp(global_position, player.global_position, 0.3)
		
		if (global_position.distance_to(player.global_position) < 18):
			player.inventory.append({
				'item': 'stone',
				'number': 1
			})
			queue_free()
		
func _on_detect_body_entered(body):
	if (body == player):
		detected = true

func _on_timer_timeout():
	for _x in range(5):
		tween.interpolate_property(self, "modulate:a", 1, 0.5, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(self, "modulate:a", 0.5, 1, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_all_completed")
		
	tween.interpolate_property(self, "modulate:a", 1, 0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	
	queue_free()
