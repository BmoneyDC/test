extends Node2D


var color : Color = Color(.5,0,0,1)
var Pname = "Jail"
var Pprice : int = 200
var xposition = -300
var yposition = 200
var Pnum = 0
var startPositionSide# = [Vector2(200,200), Vector2(-300,200),  Vector2(-300,-300), Vector2(200,-300), Vector2(0,0)]
#var startPositionSide = [Vector2(0,0), Vector2(-30,20), Vector2(20,20), Vector2(-30,-30), Vector2(20,-30)]
var cornerNum = 1
var rng = RandomNumberGenerator.new()
var ownedby = -2
# 1- basic 2- chance 3- rail 4- prop
var proptype
var monopolyset
var houses = 0
var mortgage = false
var investmentdeal : bool = false
var investmentownerarray = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#rng.randomize()
	Pnum = get_node("/root/Global_s").current_pnum
	var colorselection = get_node("/root/Global_s").ColorArray[Pnum]
	monopolyset = 0#get_node("/root/Global_s").MonopolySetsHardCode[Pnum]
	#rng.randomize()
	for n in get_node("/root/Global_s").numPlayers:
		investmentownerarray.append(-1)
	color = Color(colorselection[0],colorselection[1],colorselection[2],1)
	$CornerColor.color = color
	Pname = get_node("/root/Global_s").PropNamesData[get_node("/root/Global_s").current_pnum]
	$Title.text = Pname
	cornerNum = get_node("/root/Global_s").current_cnum
	startPositionSide = get_node("/root/Global_s").CornerStartPositionSide
	xposition = startPositionSide[cornerNum].x
	yposition = startPositionSide[cornerNum].y
	match[cornerNum]: #rotate sprite
		[0]:
			$Title.set_rotation(-PI/4)
			#$Houses.set_rotation(-PI/4)
		[1]:
			pass
		[2]:
			$Title.set_rotation(3*PI/4)
			#$Houses.set_rotation(3*PI/4)
			pass
		[3]:
			$Title.set_rotation(-3*PI/4)
			#$Houses.set_rotation(-3*PI/4)
			pass
		[4]:
			$Title.set_rotation(-3*PI/4)
			#$Houses.set_rotation(-3*PI/4)
			pass
	#$PropertyPrice.text = var2str(Pprice)
	#self.global_position.x = xposition
	#self.global_position.y = yposition
	self.position.x = xposition
	self.position.y = yposition
	self.scale.x = get_node("/root/Global_s").CornerSize[0] / 100.0
	self.scale.y = get_node("/root/Global_s").CornerSize[1] / 100.0
	#print(xposition)
	#print(yposition)

func _process(_delta):
	houseVisibility()
	setsprite()

func setsprite():
	var basicspotarray = get_node("/root/Global_s").BasicSpaceList
	if basicspotarray[0] == Pnum:
		$Picture.play("go")
	elif basicspotarray[2] == Pnum:
		$Picture.play("jail")
	elif basicspotarray[3] == Pnum:
		$Picture.play("freeparking")
	elif basicspotarray[4] == Pnum:
		$Picture.play("gotojail")
	else:
		$Picture.visible = false


func Reference():
	get_node("/root/Global_s").OpenProperty(Pnum)

func houseVisibility():
	match[houses]:
		[0]:
			$Houses/House1.visible = false
			$Houses/House2.visible = false
			$Houses/House3.visible = false
			$Houses/House4.visible = false
			$Houses/House5.visible = false
		[1]:
			$Houses/House1.visible = true
			$Houses/House2.visible = false
			$Houses/House3.visible = false
			$Houses/House4.visible = false
			$Houses/House5.visible = false
		[2]:
			$Houses/House1.visible = true
			$Houses/House2.visible = true
			$Houses/House3.visible = false
			$Houses/House4.visible = false
			$Houses/House5.visible = false
		[3]:
			$Houses/House1.visible = true
			$Houses/House2.visible = true
			$Houses/House3.visible = true
			$Houses/House4.visible = false
			$Houses/House5.visible = false
		[4]:
			$Houses/House1.visible = true
			$Houses/House2.visible = true
			$Houses/House3.visible = true
			$Houses/House4.visible = true
			$Houses/House5.visible = false
		[5]:
			$Houses/House1.visible = true
			$Houses/House2.visible = true
			$Houses/House3.visible = true
			$Houses/House4.visible = true
			$Houses/House5.visible = true
		

