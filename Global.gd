extends Node

#Testing
var dicesetting = [2, 3, 0]
var MonopolytoPlayer0 : bool = false
#Setting Page properties
var dicesides = 6
var properties_to_make : int = 40 #must mod to 4
var numPlayers = 2
var investmentDealings : bool = false
var shuffledproperties : bool = false
var auctionproperty : bool = true
var noMonopolyrule : bool = false
var playerNameString = ["Player 0","Player 1","Player 2","Player 3","Player 4","Player 5","Player 6","Player 7","Player 8","Player 9","Player 10","Player 11",]
var railroadRule : bool = false
#var playerNameString = ["Butts","biscuits","Player 2","shamwow","Player 4","Player 5","Player 6","Player 7","Player 8","Player 9","Player 10","Player 11",]
#Board Properties
#var BoardSize = [600, 600]
#var CornerSize = [100, 100]
var BoardSize = [903, 903]
var CornerSize = [150, 150]
var Dicelocations = [520, 230, 620, 230]
var spacer = BoardSize[0] - (CornerSize[0] * 2)
var cornerSpot = (BoardSize[0] / 2) - CornerSize[0]
var edgeSpot = (BoardSize[0] / 2)
var spaces = properties_to_make + 4
var width = int(floor(float(spacer) / float(float(properties_to_make - 4) / 4.0)))
var PropertySize = [width, CornerSize[0]]
#var CornerStartPositionSide = [Vector2(200,200), Vector2(-300,200),  Vector2(-300,-300), Vector2(200,-300), Vector2(0,0)]
#var AccurateCornerStartPositionSide = [Vector2(0,0), Vector2(200,200), Vector2(-300,200),  Vector2(-300,-300), Vector2(200,-300)]
#var PropertyStartPositionSide = [Vector2(0,0), Vector2(200,200), Vector2(-200,200), Vector2(-200,-300), Vector2(200,-200)]
var CornerStartPositionSide = [Vector2(cornerSpot,cornerSpot), Vector2(-edgeSpot,cornerSpot),  Vector2(-edgeSpot,-edgeSpot), Vector2(cornerSpot,-edgeSpot), Vector2(0,0)]
var AccurateCornerStartPositionSide = [Vector2(0,0), Vector2(cornerSpot,cornerSpot), Vector2(-edgeSpot,cornerSpot),  Vector2(-edgeSpot,-edgeSpot), Vector2(cornerSpot,-edgeSpot)]
var PropertyStartPositionSide = [Vector2(0,0), Vector2(cornerSpot,cornerSpot), Vector2(-cornerSpot,cornerSpot), Vector2(-cornerSpot,-edgeSpot), Vector2(cornerSpot,-cornerSpot)]
#space properties
var PropertySpaceList = [1, 3, 6, 8, 9, 11, 13, 14, 16, 18, 19, 21, 23, 24, 26, 27, 29, 31, 32, 34, 37, 39]
var RailUtilSpaceList = [5, 12, 15, 25, 28, 35]
var BasicSpaceList = [0, 4, 10, 20, 30, 38]
var ChanceCCSpaceList = [2, 7, 17, 22, 33, 36]
var ShuffledPropertyGuide = []
#var MonopolySetsHardCode = [0, 1, 0, 1, 0, 0, 2, 0, 2, 2, 0, 3, 0, 3, 3, 0, 4, 0, 4, 4, 0, 5, 0, 5, 5, 0, 6, 6, 0, 6, 0, 7, 7, 0, 7, 0, 0, 8, 0, 8]
var MonopolySetsHardCode = []
var MonopolyColorHardCode = ["#E1E5BA", "#660066", "#E1E5BA", "black", "#96FFFF", "#CC6600", "#FFC0CB", "grey", "#FF8000", "red", "yellow", "#088000", "#1943CD"]
# 1- basic 2- chance 3- rail 4- prop 5- util
var Alltypes = [1, 4, 2, 4, 1, 3, 4, 2, 4, 4, 1, 4, 5, 4, 4, 3, 4, 2, 4, 4, 1, 4, 2, 4, 4, 3, 4, 4, 5, 4, 1, 4, 4, 2, 4, 3, 2, 4, 1, 4]
var ItemSlectorSwapper = []
var ColorArray
var cnummonopoly = 0
var maxhouses = 32
var maxhotels = 12
var housesingame = 0
var hotelsingame = 0
#Special Gameplay properties
var specialPropertiesString = ["Chocolate Twenty", "Crunchy Ten", "Crunchy Hundred"]
#Money Gameplay
var gomoney = 200
#Gameplay Properties
var current_pnum = 0
var current_cnum = 0
var current_iprop = 0
var spriteArray = []
var spritesavaliable = 7
var side : int = 1# side 1 is bottom, 2 left, 3 up, 4 right
var PropPriceData
var PropNamesData
var PropertiesPurchased = []
var PropertyOwnership = []
var HousesPurchased = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var PropertyArray = [1, 3, 6, 8, 9, 11, 13, 14, 16, 18, 19, 21, 23, 24, 26, 27, 29, 31, 32, 34, 37, 39]
var path = "res://PropertyPrices2.prn"
var pathColor = "res://Colors.prn"
var rng = RandomNumberGenerator.new()
var PropertyClicked = -1
#var path = "res://PropertyPrices.prn"
#onready var items = $VBox/Items



func OpenProperty(selection):
	PropertyClicked = selection

func determineSide(num):
	var tside = 1
	var pps = (properties_to_make - 4) / 4
	if num <= pps:
		tside = 1
	elif num <= (pps*2 + 1):
		tside = 2
	elif num <= (pps*3 + 2):
		tside = 3
	else:
		tside = 4
	return tside

func setWidth(value):
	width = value

func setnoMono(selection):
	noMonopolyrule = selection

func setAcution(selection):
	auctionproperty = selection

func setInvestment(selection):
	investmentDealings = selection

func setRailroad(selection):
	railroadRule = selection

func updatePlayerName(namearray):
	playerNameString = namearray

func updatetotalproperties():
	current_pnum += 1

func updatetotalcorners():
	current_cnum += 1

func updateImportantProperties():
	current_iprop += 1
	
func updateCurrentMonopoly():
	cnummonopoly += 1

func return_home_setter():
	pass

func housesetter(num):
	housesingame += num

func hotelsetter(num):
	hotelsingame += num

func SetPlayers(num):
	numPlayers = num

func setItemSwap(array):
	for n in array.size():
		ItemSlectorSwapper.append(array[n])

func SetDice(num):
	dicesides = num

func SetProp(num):
	properties_to_make = num

func SetShuffle(setting):
	shuffledproperties = setting

func shuffleProperties():
	randomize()
	var newColorarray = []
	var newAlltype = []
	var newPropPriceData = []
	var newPropNamesData = []
	for n in properties_to_make:
		ShuffledPropertyGuide.append(n)
		newColorarray.append(n)
		newAlltype.append(n)
		newPropPriceData.append(n)
		newPropNamesData.append(n)
	ShuffledPropertyGuide.shuffle()
	for l in properties_to_make:
		newColorarray[l] = ColorArray[ShuffledPropertyGuide[l]]
		newAlltype[l] = Alltypes[ShuffledPropertyGuide[l]]
		newPropPriceData[l] = PropPriceData[ShuffledPropertyGuide[l]]
		newPropNamesData[l] = PropNamesData[ShuffledPropertyGuide[l]]
	ColorArray = newColorarray
	Alltypes = newAlltype
	PropPriceData = newPropPriceData
	PropNamesData = newPropNamesData
	var newPropertySpaceList = []
	var newRailUtilSpaceList = []
	var newBasicSpaceList = []
	var newChanceCCSpaceList = []
	for t in PropertySpaceList.size():
		newPropertySpaceList.append(ShuffledPropertyGuide.find(PropertySpaceList[t]))
	PropertySpaceList = newPropertySpaceList
	for t in RailUtilSpaceList.size():
		newRailUtilSpaceList.append(ShuffledPropertyGuide.find(RailUtilSpaceList[t]))
	RailUtilSpaceList = newRailUtilSpaceList
	for t in BasicSpaceList.size():
		newBasicSpaceList.append(ShuffledPropertyGuide.find(BasicSpaceList[t]))
	BasicSpaceList = newBasicSpaceList
	for t in ChanceCCSpaceList.size():
		newChanceCCSpaceList.append(ShuffledPropertyGuide.find(ChanceCCSpaceList[t]))
	ChanceCCSpaceList = newChanceCCSpaceList

func randomizeSprites(_totalplayer):
	rng.randomize()
	randomize()
	#var csprite = rng.randi() % spritesavaliable
	for n in spritesavaliable:
		spriteArray.append(n)
	spriteArray.shuffle()
	pass

func Get_price_data():
	var pricedata = {}
	var file = File.new()
	file.open(path, file.READ)
	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		pricedata[pricedata.size()] = data_set
	file.close()
	PropPriceData = pricedata
	#print(maindata)
	#return maindata

func Get_Color_data():
	var pricedata = {}
	var file = File.new()
	file.open(pathColor, file.READ)
	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		pricedata[pricedata.size()] = data_set
	file.close()
	ColorArray = pricedata
	#print(maindata)
	#return maindata


#func showItems(data):
#	items.visible = false
#	for item in data.keys():
#		var item_copy = items.duplicate()
#		var entity : Dictionary = data[item]
#		item_copy.text = str(entity[0]) + " " + str(entity[1]) + " " + str(entity[2]) + " " + str(entity[3])
#		item_copy.visible = true
#		$VBox.add_child(item_copy)

func loadNames():
	var lines = []                              #set an empty array
	var file = File.new();                      #create an instance
	file.open("res://PropertyNames.txt", File.READ); #open the file into instance
	while not file.eof_reached():               #while we're not at end of file
		lines.append(file.get_line())           #append each line to the array
	PropNamesData = lines
	#return lines

func loadNames2():
	var lines = []                              #set an empty array
	var file = File.new();                      #create an instance
	file.open("res://PropertyNames2.txt", File.READ); #open the file into instance
	while not file.eof_reached():               #while we're not at end of file
		lines.append(file.get_line())           #append each line to the array
	PropNamesData = lines
	#return lines

