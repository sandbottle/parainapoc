extends MarginContainer

var notif_text : String = '' setget change_text

onready var tween = get_node('tween')
onready var label = get_node('label')

func play():
	modulate.a = 0
	
	tween.interpolate_property(self, 'modulate:a', 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'modulate:a', 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	queue_free()
	
func change_text(value):
	label.text = value
