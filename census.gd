extends Spatial

var getDataDelay = 10
var currentTime = 0
var rabbits
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new()
	timer.set_one_shot(false)
	
	timer.set_wait_time(getDataDelay)
	timer.connect("timeout", self, "getData")
	
	add_child(timer)
	timer.start()
	rabbits = get_node("../rabbits")
	currentTime = currentTime - getDataDelay
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func getData():
	currentTime = currentTime + getDataDelay
	
	for rabbit in rabbits.get_children():
		if not rabbit.dead:
			print(rabbit.toString(currentTime))
