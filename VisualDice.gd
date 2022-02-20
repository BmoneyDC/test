extends Node2D


var roll = 0
var dicenum = 0
var spinning = false
var spinrate = 16
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	updateSprite(roll)
	if dicenum == 0:
		self.position.x = get_node("/root/Global_s").Dicelocations[0]
		self.position.y = get_node("/root/Global_s").Dicelocations[1]
	else:
		self.position.x = get_node("/root/Global_s").Dicelocations[2]
		self.position.y = get_node("/root/Global_s").Dicelocations[3]

func _process(_delta):
	updateSprite(roll)
	updateposition()
	if spinning:
		self.rotate(PI / spinrate)

func updateposition():
	if dicenum == 0:
		self.position.x = get_node("/root/Global_s").Dicelocations[0]
		self.position.y = get_node("/root/Global_s").Dicelocations[1]
	else:
		self.position.x = get_node("/root/Global_s").Dicelocations[2]
		self.position.y = get_node("/root/Global_s").Dicelocations[3]

func updateSprite(newroll):
	match[newroll]:
		[1]:
			$DiceFace.play("1")
			$Roll.visible = false
		[2]:
			$DiceFace.play("2")
			$Roll.visible = false
		[3]:
			$DiceFace.play("3")
			$Roll.visible = false
		[4]:
			$DiceFace.play("4")
			$Roll.visible = false
		[5]:
			$DiceFace.play("5")
			$Roll.visible = false
		[6]:
			$DiceFace.play("6")
			$Roll.visible = false
		[_]:
			$DiceFace.play("0")
			$Roll.text = var2str(roll)
			$Roll.visible = true

func animateRoll():
	spinning = true
	rng.randomize()
	spinrate = randi() % 24 + 8
	$DiceFace.material.set_shader_param("amount",1.0)
	yield(get_tree().create_timer(.25), "timeout")
	$DiceFace.material.set_shader_param("amount",0.0)
	spinning = false
	#self.rotation = 0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
