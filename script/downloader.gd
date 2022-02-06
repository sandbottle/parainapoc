extends Node2D

onready var http = $http
onready var downloader = $"image-downloader"

var to_download = 0
var progress = 0
var download_list = []

func _ready():
	pass
	
func _on_http_request_completed(result, response_code, headers, body):
	var json = body.get_string_from_utf8()
	download_list = parse_json(json).to_download
	to_download = download_list.size() 
	
	$canvas/ui/vbox/label/loading/progress.max_value = to_download
	$canvas/ui/vbox/label/loading/progress.step = 1
	
	$canvas/ui/vbox/label/loading/number.text = '0/' + str(to_download)
	
	$canvas/ui/vbox/label/buttons.hide()
	$canvas/ui/vbox/label/loading.show()
	
	print('need to download resource')
	
	for x in range(to_download):
		var location = "https://sandbottle.net/parainapoc/resources/" + download_list[x]
		
		downloader.set_download_file(download_list[x])
		downloader.request(location)
		
		yield(downloader, "request_completed")
		progress = x
		
		$canvas/ui/vbox/label/loading/progress.value += 1
		$canvas/ui/vbox/label/loading/number.text = str(progress + 1) + '/' + str(to_download)
		
	print('resource downloaded')
	
	ProjectSettings.set_setting("application/run/main_scene", "res://scene/game.tscn")
	get_tree().change_scene("res://scene/game.tscn")

	$canvas/ui/vbox/label/loading.hide()
	$canvas/ui/vbox/finish.show()

func _on_download_pressed():
	http.request("https://sandbottle.net/parainapoc/")
