extends Node2D

var bankrupt : bool = false
var money : int = 1500
var currentSpace : int = 0
var moved = false
var spaces_moved
var croll
var cornerpositions
var playerNum = 1
var player_offset
var playername = ""
var rng = RandomNumberGenerator.new()
var wiggletime = false
var PropertiesOwned = []
var HousesOwned = []
var NumPropOwn = 0
var railRoadsOwned = 0
var UtilitiesOwned = 0
var Jailed : bool = false
var JailRolls = 0
var doublesrolled = 0
var icon = ""
var spritenumber = 0
# 0- chocolate-20 1- crunchy 10 2- crunchy 100
var specialProperties = [0, 0, 0]

#NETWORKING STUFF
var networkID = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	# = Color(rand_range(0,1),rand_range(0,1),rand_range(0,1),1)
	cornerpositions = get_node("/root/Global_s").CornerStartPositionSide
	player_offset = playerNum * 10
	var gospot = (get_node("/root/Global_s").BoardSize[0] / 2.0) - (get_node("/root/Global_s").CornerSize[0] / 2.0)
	self.position = Vector2(gospot,gospot) + Vector2(player_offset,player_offset)
	spritenumber = get_node("/root/Global_s").spriteArray[playerNum]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	playername = get_node("/root/Global_s").playerNameString[playerNum]
	if(bankrupt):
		self.visible = false
	if (Input.is_action_just_pressed("test")):
		pass
	if (wiggletime):
		wiggle(1,10)
		pass

func wiggle(time,strength):
	wiggletime = false
	$PlayerIcon.visible = false
	$AffectedPlayer.visible=true
	$AffectedPlayer.material.set_shader_param("Strength",strength)
	yield(get_tree().create_timer(time), "timeout")
	$AffectedPlayer.material.set_shader_param("Strength",0.0)
	$PlayerIcon.visible = true
	$AffectedPlayer.visible = false

func updateIcon():
	$PlayerIcon.play(var2str(spritenumber))
	$AffectedPlayer.play(var2str(spritenumber))
	match[spritenumber]:
		[0]:
			icon = "Rainbow"
		[1]:
			icon = "Skateboard"
		[2]:
			icon = "SuperPerson"
		[3]:
			icon = "Guns"
		[4]:
			icon = "Ptony"
		[5]:
			icon = "Dice"
		[6]:
			icon = "Dragon"


func move(roll):
	var direction = Vector2(1,0)
	for n in roll:
		var modCSP = (currentSpace + 1) % 40
		if (modCSP <= 10):
			direction = Vector2(-1,0)
		elif (modCSP <= 20):
			direction = Vector2(0,-1)
		elif (modCSP <= 30):
			direction = Vector2(1,0)
		elif (modCSP <= 40):
			direction = Vector2(0,1)
		currentSpace += 1
		currentSpace = currentSpace % (get_node("/root/Global_s").properties_to_make)
		if(currentSpace == 0 && Jailed == false):
			money += get_node("/root/Global_s").gomoney
		#self.position += (get_node("/root/Global_s").width) * direction
		yield(get_tree().create_timer(.15), "timeout")
		CenterOnPiece(currentSpace)
#plan recenter once a corner is reached


# Center on piece
func CenterOnPiece(pos):
	var SideSpot = pos % ((get_node("/root/Global_s").properties_to_make) / 4)
	var side = get_node("/root/Global_s").determineSide(pos)
	if(SideSpot == 0):
		self.position = (get_node("/root/Global_s").AccurateCornerStartPositionSide[side]) + \
		Vector2((get_node("/root/Global_s").CornerSize[1]) / 2 + player_offset,((get_node("/root/Global_s").CornerSize[1]/2) + player_offset))
	else:
		match[side]: #rotate sprite
			[0]:
				pass
			[1]:
				self.position = (get_node("/root/Global_s").PropertyStartPositionSide[side]) - \
				Vector2((get_node("/root/Global_s").width) * (SideSpot - .5),-((get_node("/root/Global_s").PropertySize[1]/2) + player_offset))
			[2]:
				self.position = (get_node("/root/Global_s").PropertyStartPositionSide[side]) - \
				Vector2(((get_node("/root/Global_s").PropertySize[1]/2) + player_offset),(get_node("/root/Global_s").width) * (SideSpot - .5))
				pass
			[3]:
				self.position = (get_node("/root/Global_s").PropertyStartPositionSide[side]) + \
				Vector2((get_node("/root/Global_s").width) * (SideSpot - .5),((get_node("/root/Global_s").PropertySize[1]/2) + player_offset))
				pass
			[4]:
				self.position = (get_node("/root/Global_s").PropertyStartPositionSide[side]) + \
				Vector2(((get_node("/root/Global_s").PropertySize[1]/2) + player_offset),(get_node("/root/Global_s").width) * (SideSpot - .5))
				pass
	#print("moved")


#func doneMoving():
#
#	spaces_moved += 1
#	if(spaces_moved == croll):
#		moved = true
#	pass # Replace with function body.


#func move2(roll):
#	croll = roll
#	if(spaces_moved < roll):
#		var direction = Vector2(1,0)
#		var modCSP = currentSpace + 1
#		if (modCSP <= 10):
#			direction = Vector2(-1,0)
#		elif (modCSP <= 20):
#			direction = Vector2(0,-1)
#		elif (modCSP <= 30):
#			direction = Vector2(1,0)
#		elif (modCSP <= 40):
#			direction = Vector2(0,1)
#		currentSpace += 1
#		self.position += (get_node("/root/Global_s").width / 2) * direction
#		$Moving.start()
