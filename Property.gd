extends Node2D


var color : Color = Color(1,0,0,1)
var colorselection
var Pname = "name"
var Pnum = 0
var Pprice = 200
var xposition = -200
var yposition = 200
var side = 2
var width
var houses = 0
var mortgage = false
#-200,200
var startPositionSide# = [Vector2(0,0), Vector2(200,200), Vector2(-200,200), Vector2(-200,-300), Vector2(200,-200)]#center for array at 0
var rng = RandomNumberGenerator.new()
var ownedby = -1
# 1- basic 2- chance 3- rail 4- prop
var proptype
var monopolyset
var investmentdeal : bool = false
var investmentownerarray = []

# Called when the node enters the scene tree for the first time.
func _ready():
	startPositionSide = get_node("/root/Global_s").PropertyStartPositionSide
	Pnum = get_node("/root/Global_s").current_pnum
	monopolyset = 0#get_node("/root/Global_s").MonopolySetsHardCode[Pnum]
	for n in get_node("/root/Global_s").numPlayers:
		investmentownerarray.append(-1)
	colorselection = get_node("/root/Global_s").ColorArray[Pnum]
	#rng.randomize()
	color = Color(colorselection[0],colorselection[1],colorselection[2],1)
	var propperside = ((get_node("/root/Global_s").properties_to_make) / (4)) #9
	var propertyspace = get_node("/root/Global_s").BoardSize[0] - (get_node("/root/Global_s").CornerSize[0] * 2)
	width = (propertyspace / (propperside - 1))
	side = get_node("/root/Global_s").determineSide(Pnum)
	#print("side" + var2str(side))
	if (side == 1):
		xposition = startPositionSide[side].x - (width * (Pnum % propperside))
		yposition = startPositionSide[side].y
	elif (side==2):
		yposition = startPositionSide[side].y - (width * (Pnum % propperside))
		xposition = startPositionSide[side].x
		self.rotate(PI/2) #if side == 2 else self.rotate(-PI/2)
	elif (side == 3):
		xposition = startPositionSide[side].x + (width * (Pnum % propperside)) - width
		yposition = startPositionSide[side].y
	elif (side==4):
		yposition = startPositionSide[side].y + (width * (Pnum % propperside))
		xposition = startPositionSide[side].x
		#self.rotate(PI/2) if side == 2 else self.rotate(-PI/2)
		self.rotate(-PI/2)
		
	
	self.scale.x = (width / 50.0)
	self.scale.y = get_node("/root/Global_s").PropertySize[1] / 100.0
	Pname = get_node("/root/Global_s").PropNamesData[Pnum]
	var temp_data = get_node("/root/Global_s").PropPriceData[Pnum]
	Pprice = str2var(temp_data[0])
#	var cipop = get_node("/root/Global_s").current_iprop
#	if(get_node("/root/Global_s").current_pnum == get_node("/root/Global_s").PropertyArray[cipop]):
#		Pname = get_node("/root/Global_s").PropNamesData[cipop]
#		var temp_data = get_node("/root/Global_s").PropPriceData[cipop]
#		Pprice = str2var(temp_data[0])
#		get_node("/root/Global_s").updateImportantProperties()
	
	$PropertyColor.color = color
	$PropertyName
	$PropertyName.text = Pname
#	var pricestring = ""
#	var testprice = Pprice
#	if (testprice != 0):
#		pricestring = var2str(Pprice)
#	if (Pprice == 0):
#		print("test")
	$PropertyPrice.text = var2str(Pprice)#pricestring
	if Pnum in get_node("/root/Global_s").ChanceCCSpaceList:
		$PropertyPrice.text = ""
	if Pnum == 4:
		$PropertyPrice.text = "200"
#	if Pnum in get_node("/root/Global_s").BasicSpaceList:
#		$PropertyPrice.text = ""
	#self.global_position.x = xposition
	#self.global_position.y = yposition
	self.position.x = xposition
	self.position.y = yposition
	#print(xposition)
	#print(yposition)

func _process(_delta):
	houseVisibility()

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
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PropClick_button_down():
	get_node("/root/Global_s").OpenProperty(Pnum)
