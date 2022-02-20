extends Node2D

#Game Const
var goMoney : int = 200

#Game Variables
var Players : int
var properties_to_make : int
var pperside : int
var properties_made : int = 0
var corners_made : int = 0
var CurrentTurn = 0
var doubles : bool
var spot
var Purchased : bool
var freeParking = 0
var PropertyInfoIndex = 0
var BankruptPlayer = -1
var previousRoll
var MonopolySets = [0]
var bankruptPlayers = []
var winningplayer = -1
#auction variables
var currentbid = 0
var highestbid = 0
var highestbidder = -1
var currentbidder = -1
var bidderarray = []
var auctionspace
var moneyoffered = 0
#Misc Variables and game varients
var overideswap : bool = false
var railroadRule : bool = false
var railroadRuleJustMoves : bool = false
var noMonopolyNeeded : bool = false
#Preloads
var rng = RandomNumberGenerator.new()
var REGPROPERTY = preload("res://Property.tscn")
var CORNERPIECE = preload("res://CornerPiece.tscn")
var PLAYER = preload("res://Player.tscn")
var DICE = preload("res://VisualDice.tscn")
#var player = [PLAYER, PLAYER, PLAYER, PLAYER]
var player = []
var MGproperty = []
var dice = []

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	properties_to_make = get_node("/root/Global_s").properties_to_make
	Players = get_node("/root/Global_s").numPlayers
	for n in properties_to_make:
		get_node("/root/Global_s").PropertyOwnership.append(-1)
	for n in Players:
		player.append(PLAYER)
	pperside = properties_to_make
	if(get_node("/root/Global_s").investmentDealings == false):
		$Board/CanvasLayer/Panel/Invest.disabled = true
		$Board/CanvasLayer/PropertyProperties/RentDealProp.disabled = true
	railroadRule = get_node("/root/Global_s").railroadRule
	noMonopolyNeeded = get_node("/root/Global_s").noMonopolyrule
	if(noMonopolyNeeded):
		$Board/CanvasLayer/PropertyProperties/BuyHouse2.disabled = true
	get_node("/root/Global_s").Get_price_data()
	get_node("/root/Global_s").Get_Color_data()
	get_node("/root/Global_s").loadNames()
	get_node("/root/Global_s").loadNames2()
	get_node("/root/Global_s").randomizeSprites(Players)
	if (get_node("/root/Global_s").shuffledproperties):
		get_node("/root/Global_s").shuffleProperties()
	MakeProperties()
	AssignMonopoly()
	MakePlayers()
	MakeDice()
	UpdatePlayerInfo()
	initiateItemSwapArray()
	UpdatePropertiesReference()
	#NETWORKINGCODE
	
	MultiplayerAutoload.net_id = get_tree().get_network_unique_id()
	
	
	

func _process(_delta):
	#Text Updates
	if (player[CurrentTurn].bankrupt == true):
		CurrentTurn += 1
		if(CurrentTurn > Players):
			CurrentTurn == 0
	if(winningplayer < 0):
		$Control/TurnInstructor.text = player[CurrentTurn].playername + "'s Turn"
	$LeftHandControl/Freeparking.text = "Free Parking: " + var2str(freeParking + 500)
	$LeftHandControl/HotelQTY.text = "Hotels Left: " + var2str(get_node("/root/Global_s").maxhotels - get_node("/root/Global_s").hotelsingame)
	$LeftHandControl/HouseQTY.text = "Houses Left: " + var2str(get_node("/root/Global_s").maxhouses - get_node("/root/Global_s").housesingame)
	#moneyoffered = $Board/CanvasLayer/TradeScreen/MoneyOffered.connect("value_changed",self,`)
	$Board/CanvasLayer/TradeScreen/MoneyOffered
	checkPropClicks()
	if (Input.is_action_just_pressed("test")):
		get_node("/root/Global_s").housesetter(5)
		#AssignSpecialProperties(0,0,1)
	if (Input.is_action_just_pressed("escape")):
		pauseMenu()
		#get_node("/root/Global_s").Get_price_data()
	

func MakeProperties():
	var propwidth = get_node("/root/Global_s").BoardSize[0] - (get_node("/root/Global_s").CornerSize[0] * 2)
	get_node("/root/Global_s").setWidth(int(floor(float(propwidth) / float(float(properties_to_make - 4) / 4.0))))
	#make properties
	for n in properties_to_make:
		if(0 == properties_made % (properties_to_make / 4)):
			var cornerpiece = CORNERPIECE.instance()
			get_parent().add_child(cornerpiece)
			get_node("/root/Global_s").updatetotalcorners()
			get_node("/root/Global_s").updatetotalproperties()
			corners_made += 1
			properties_made +=1
			MGproperty.append(cornerpiece)
			MGproperty[n].proptype = get_node("/root/Global_s").Alltypes[n]
		else:
			var property = REGPROPERTY.instance()
			get_parent().add_child(property)
			property.side = get_node("/root/Global_s").determineSide(properties_made)
			properties_made += 1
			get_node("/root/Global_s").updatetotalproperties()
			MGproperty.append(property)
			MGproperty[n].proptype = get_node("/root/Global_s").Alltypes[n]

func MakePlayers():
	for n in Players:
		player[n] = PLAYER.instance()
		get_parent().add_child(player[n])
		player[n].playerNum = n
		player[n].spritenumber = get_node("/root/Global_s").spriteArray[n]
		player[n].updateIcon()
		
		#NETWORKING
		if n == 0:
			player[n].networkID = MultiplayerAutoload.player_ids[get_tree().get_network_unique_id()]
		else:
			player[n].networkID = MultiplayerAutoload.player_ids[n]

func MakeDice():
	var dicetomake = 2
	for n in dicetomake:
		dice.append(DICE)
		dice[n] = DICE.instance()
		get_parent().add_child(dice[n])
		dice[n].dicenum = n

func ResolveLand(playernum):
	spot = player[playernum].currentSpace
	if spot in get_node("/root/Global_s").PropertySpaceList:
		ResolveProperty(spot,playernum)
	elif spot in get_node("/root/Global_s").RailUtilSpaceList:
		ResolveRailUtil(spot,playernum)
	elif spot in get_node("/root/Global_s").BasicSpaceList:
		ResolveBasic(spot,playernum)
	elif spot in get_node("/root/Global_s").ChanceCCSpaceList:
		ResolveChanceCC(spot,playernum)
	UpdatePlayerInfo()

func ResolveProperty(spotlanded,playernum):
	var bill = get_node("/root/Global_s").PropPriceData[spotlanded]
	#var Housecheck = get_node("/root/Global_s").HousesPurchased[spot]
	var numhouses = MGproperty[spotlanded].houses
	if spotlanded in get_node("/root/Global_s").PropertiesPurchased:
		Purchased = true
		if(MGproperty[spotlanded].mortgage == false):
			if(MGproperty[spotlanded].investmentownerarray[CurrentTurn] >= 1):
					$Control/ResolveMessage.text = "You do not pay rent here"
			else:
				#check if fullset is owned
				var owner = MGproperty[spotlanded].ownedby
				var doublerent = false
				var monopolyset = MonopolySetArray(spotlanded)
				var ownedcounter = 0
				for l in monopolyset.size():
					if(owner == MGproperty[monopolyset[l]].ownedby):
						ownedcounter += 1
				if (ownedcounter == monopolyset.size()):
					doublerent = true
				$Control/ResolveMessage.text = ""
				var amount = str2var(bill[numhouses + 2])
				if (numhouses == 0 && doublerent):
					amount = amount * 2
				for t in MGproperty[spotlanded].investmentownerarray.size():
					var paycurrent = false
					var percent = (float(MGproperty[spotlanded].investmentownerarray[t]) / 100.0)
					var newamount = int(floor(amount * percent))
					if(MGproperty[spotlanded].investmentownerarray[t] > 0):
						#autofreerent
						player[CurrentTurn].money -= newamount
						paycurrent = true
					if(paycurrent):
						player[t].money += newamount
						player[CurrentTurn].wiggle(1,10)
						$Control/ResolveMessage.text += player[t].playername + " owns " + var2str(MGproperty[spotlanded].investmentownerarray[t]) +\
						"% of this property\n You owe them " + var2str(newamount) + "\n"
#			var owner = FindOwner(spotlanded)
#			var Payerplayer = player[CurrentTurn]
#			var Payeeplayer = player[owner]
#			Payerplayer.money -= str2var(bill[Housecheck + 2])
#			Payeeplayer.money += str2var(bill[Housecheck + 2])
#			$Control/ResolveMessage.text = "Player " + var2str(owner) + " owns " + get_node("/root/Global_s").PropNamesData[spotlanded] + ", you owe them " + var2str(bill[numhouses])
		else:
			$Control/ResolveMessage.text = "The Property is mortgaged"
	else:
		$Control/Pay.disabled = false
		$Control/ResolveMessage.text = get_node("/root/Global_s").PropNamesData[spotlanded] + \
		 " is unbought, click purchase to buy it"
		Purchased = false
	BankruptCheck()

func ResolveRailUtil(spotlanded,playernum):
	var bill = get_node("/root/Global_s").PropPriceData[spotlanded]
	var Housecheck = get_node("/root/Global_s").HousesPurchased[spot]
	if spotlanded in get_node("/root/Global_s").PropertiesPurchased:
		Purchased = true
		if (MGproperty[spotlanded].mortgage):
			$Control/ResolveMessage.text = "This Property is Mortgaged"
		elif(MGproperty[spotlanded].investmentownerarray[CurrentTurn] >= 1):
			$Control/ResolveMessage.text = "You do not pay rent here"
		else:
			var owner = FindOwner(spotlanded)
			var Payerplayer = player[CurrentTurn]
			var Payeeplayer = player[owner]
			var cost = 0
			if (MGproperty[spotlanded].proptype == 3):
				cost = Payeeplayer.railRoadsOwned
				if (cost <= 2):
					cost = cost * 25
				elif (cost == 3):
					cost = 100
				else:
					cost = 200
				#Payerplayer.money -= cost
				#Payeeplayer.money += cost
				#$Control/ResolveMessage.text = player[owner].playername + " owns " + \
				#get_node("/root/Global_s").PropNamesData[spotlanded] + ", you owe them " + var2str(cost)
			else:
				cost = Payeeplayer.UtilitiesOwned
				if (cost == 1):
					cost = previousRoll * 4
				else:
					cost = previousRoll * 10
				#Payerplayer.money -= cost
				#Payeeplayer.money += cost
				#$Control/ResolveMessage.text = player[owner].playername + " owns " + \
				#get_node("/root/Global_s").PropNamesData[spotlanded] + ", you owe them " + var2str(cost)
			$Control/ResolveMessage.text = ""
			for t in MGproperty[spotlanded].investmentownerarray.size():
				var paycurrent = false
				var percent = (float(MGproperty[spotlanded].investmentownerarray[t]) / 100.0)
				var newamount = int(floor(cost * percent))
				if(MGproperty[spotlanded].investmentownerarray[t] > 0):
					#autofreerent
					player[CurrentTurn].money -= newamount
					paycurrent = true
				if(paycurrent):
					player[t].money += newamount
					player[CurrentTurn].wiggle(1,10)
					$Control/ResolveMessage.text += player[t].playername + " owns " + var2str(MGproperty[spotlanded].investmentownerarray[t]) +\
					"% of this property\n You owe them " + var2str(newamount) + "\n"
		if(railroadRule && railroadRuleJustMoves == false):
			$Board/CanvasLayer/RuleVarient/Railroad3.disabled = true
			$Board/CanvasLayer/RuleVarient/Railroad2.disabled = true
			$Board/CanvasLayer/RuleVarient/Railroad1.disabled = true
			handleRailroadRule(spotlanded)
	else:
		$Control/Pay.disabled = false
		$Control/ResolveMessage.text = get_node("/root/Global_s").PropNamesData[spotlanded] + \
		 " is unbought, click purchase to buy it"
		Purchased = false
	BankruptCheck()

func ResolveBasic(spotlanded,playernum):
	var basicspotarray = get_node("/root/Global_s").BasicSpaceList
	if spotlanded == basicspotarray[0]:
		$Control/ResolveMessage.text = "GO: Collect 400"
		player[playernum].money += goMoney
	if spotlanded == basicspotarray[1]:
		$Control/ResolveMessage.text = "That's definately \nIncome Tax\nMinus 200$"
		player[playernum].money -= goMoney
		freeParking += goMoney
	if spotlanded == basicspotarray[5]:
		$Control/ResolveMessage.text = "I think that's \nLuxury Tax\nMinus 75$"
		player[playernum].money -= 75
		freeParking += 75
	if spotlanded == basicspotarray[3]:
		$Control/ResolveMessage.text = "Free Parking \nYou got: " + var2str(freeParking + 500)
		player[playernum].money += 500
		freeParking = 0
	if spotlanded == basicspotarray[2]:
		$Control/ResolveMessage.text = "Visiting Jail"
	if spotlanded == basicspotarray[4]:
		$Control/ResolveMessage.text = "Go to Jail"
		var wait = GoToJail(player[CurrentTurn].currentSpace, 0, 0)
		$Control/EndTurn.disabled = true
		player[CurrentTurn].move(wait)
		yield(get_tree().create_timer((wait)*.17), "timeout")
		$Control/EndTurn.disabled = false
		#player[playernum].move(20)
		player[playernum].Jailed = true
		player[playernum].JailRolls = 0
	BankruptCheck()

func ResolveChanceCC(spotlanded,playernum):
	var ChanceCClist = get_node("/root/Global_s").ChanceCCSpaceList
	var chance = [ChanceCClist[1], ChanceCClist[3], ChanceCClist[5]]
	var CC = [ChanceCClist[0], ChanceCClist[2], ChanceCClist[4]]
	var amt : int
	if spotlanded in chance:
		amt = rng.randi() % 800 - 200
		if(abs(amt) < 200):
			$Control/ResolveMessage.text = "Chance Card: \n You recieve " + var2str(amt)
			player[playernum].money += amt
			if amt < 0:
				freeParking -= amt
		else:
			amt = floor(amt)
			player[CurrentTurn].move(amt % 20)
			UpdatePlayerInfo()
			$Control/ResolveMessage.text = "Chance Card: \n You move " + var2str(amt % 20) + " Spaces"
			$Control/EndTurn.disabled = true
			yield(get_tree().create_timer((amt % 20) * .16 + .5), "timeout")
			$Control/EndTurn.disabled = false
			ResolveLand(CurrentTurn)
	elif spotlanded in CC:
		amt = (rng.randi() % 20) * 10
		$Control/ResolveMessage.text = "Community Chest Card: \n You recieve " + var2str(amt)
		player[playernum].money += amt
		match[amt]:
			[10]:
				AssignSpecialProperties(CurrentTurn,1,1)
				$Control/ResolveMessage.text = "Community Chest Card: \n You recieve " + var2str(amt) + "\nThe Crunchy 10!"
			[100]:
				AssignSpecialProperties(CurrentTurn,2,1)
				$Control/ResolveMessage.text = "Community Chest Card: \n You recieve " + var2str(amt) + "\nThe Crunchy 100!"
			[20]:
				AssignSpecialProperties(CurrentTurn,0,1)
				$Control/ResolveMessage.text = "Community Chest Card: \n You recieve " + var2str(amt) + "\nThe Chocolate 20!"
			[_]:
				pass
	BankruptCheck()

func TurnTaker():
	removePlayer()
	$Control/Dice.disabled = false
	$Control/EndTurn.disabled = true
	$Control/Pay.disabled = true
	$Control/ResolveMessage.text = "Next Player Roll"
	UpdatePlayerInfo()
	UpdatePropertiesReference()
	#if(Players == 1):#game over
	if(Players - bankruptPlayers.size() == 1):#game over
		winningplayer
		for n in Players:
			if (player[n].bankrupt == false):
				winningplayer = n
		$Control/Bankrupcy.text = "Congratulations " + player[winningplayer].playername + "\nYou Win!"
		$Control/Dice.disabled = true
		$Control/EndTurn.disabled = true
		player[winningplayer].wiggle(10,10)
	else: #game not over
		if(doubles && player[CurrentTurn].Jailed == false):
			doubles = false
			if(get_node("/root/Global_s").auctionproperty):
				initiateAuction()
		elif((doubles || player[CurrentTurn].JailRolls == 2) && player[CurrentTurn].Jailed == true):
			doubles = false
			CurrentTurn += 1
			if (CurrentTurn >= Players):
				CurrentTurn = 0
		else:
			if(get_node("/root/Global_s").auctionproperty):
				initiateAuction()
			CurrentTurn += 1
			if (CurrentTurn >= Players):
				CurrentTurn = 0
		if (player[CurrentTurn].Jailed):
			$Control/JailPayout.visible = true
	#		if (player[CurrentTurn].Jailed):
	#			CurrentTurn += 1
	

func RollDice():
	$Sounds/DiceRoll.play()
	var justrolledtriples = false
	railroadRuleJustMoves = false
	var dicesidemax = get_node("/root/Global_s").dicesides
	dicesidemax = int(dicesidemax)
	var die1 = rng.randi() % dicesidemax + 1
	var die2 = rng.randi() % dicesidemax + 1
	if (get_node("/root/Global_s").dicesetting[2] == 1):
		die1 = get_node("/root/Global_s").dicesetting[0]
		die2 = get_node("/root/Global_s").dicesetting[1]
	dice[0].roll = die1
	dice[0].animateRoll()
	dice[1].roll = die2
	dice[1].animateRoll()
	previousRoll = die1 + die2
	if (die1 == die2):
		doubles = true
		player[CurrentTurn].doublesrolled += 1
	else:
		player[CurrentTurn].doublesrolled = 0
	$Control/Dice1.text = var2str(die1)
	$Control/Dice2.text = var2str(die2)
	$Control/Dice.disabled = true
	if (player[CurrentTurn].doublesrolled == 3):
		doubles = false
		justrolledtriples = true
		player[CurrentTurn].Jailed = true
		$Control/ResolveMessage.text = "Triple doubles\nGo to Jail"
		var wait = GoToJail(player[CurrentTurn].currentSpace, 0, 0)
		$Control/EndTurn.disabled = true
		player[CurrentTurn].move(wait)
		yield(get_tree().create_timer((wait)*.17), "timeout")
		$Control/EndTurn.disabled = false
		#yield(get_tree().create_timer(wait*.17), "timeout")
		player[CurrentTurn].JailRolls = 0
		player[CurrentTurn].doublesrolled = 0
	if (player[CurrentTurn].Jailed && doubles == false && player[CurrentTurn].JailRolls < 2 && justrolledtriples == false):
		player[CurrentTurn].JailRolls += 1
		$Control/ResolveMessage.text = player[CurrentTurn].playername + " has rolled " + var2str(player[CurrentTurn].JailRolls) + " times in jail"
		$Control/JailPayout.visible = false
	elif((doubles || player[CurrentTurn].JailRolls == 2) && player[CurrentTurn].Jailed == true):
		if(doubles == false):
			player[CurrentTurn].money -= 50
			freeParking += 50
			$Control/ResolveMessage.text = "You paid 50 to leave jail"
			$Control/JailPayout.visible = false
		else:
			doubles = false
			$Control/ResolveMessage.text = "You left jail with doubles"
			$Control/JailPayout.visible = false
		player[CurrentTurn].Jailed = false
		player[CurrentTurn].JailRolls = 0
		player[CurrentTurn].doublesrolled = 0
		#$Control/ResolveMessage.text = "You paid 50 to leave jail"
		player[CurrentTurn].move(die1 + die2)
		yield(get_tree().create_timer((die1+die2)*.17), "timeout")
	elif(justrolledtriples):
		pass
	else:
		player[CurrentTurn].move(die1 + die2)
		yield(get_tree().create_timer((die1+die2)*.17), "timeout")
	UpdatePlayerInfo()
	$Control/EndTurn.disabled = false
	if (player[CurrentTurn].Jailed == false):
		ResolveLand(CurrentTurn)
	#TurnTaker()

func realPlayer(fakenum):
	var realnum = 0
	for n in Players:
		if(player[n].playerNum == fakenum):
			realnum = player[n].playerNum
	return realnum

func removePlayer():
	BankruptCheck()
	if BankruptPlayer != -1:
		#player[BankruptPlayer].queue_free()
		var tempPlayer
		#tempPlayer = player[Players-1]
		#player[Players-1] = player[BankruptPlayer]
		#player[BankruptPlayer] = tempPlayer
		#player[Players-1].queue_free()
		if(MGproperty[spot].ownedby > 0):
			for n in properties_to_make:
				if(MGproperty[n].ownedby == BankruptPlayer):
					MGproperty[n].ownedby = MGproperty[spot].ownedby
					EndTheTradeDealFunction(n)
		else:
			for n in properties_to_make:
				if(MGproperty[n].ownedby == BankruptPlayer):
					MGproperty[n].ownedby = -1
					EndTheTradeDealFunction(n)
		#player[BankruptPlayer].queue_free()
		#player.remove(BankruptPlayer)
		#Players -= 1
		
		#player shifter
#		for n in Players:
#			if(player[n].playerNum > BankruptPlayer):
#				player[n].playerNum -= 1
#		for i in properties_to_make:
#			if(MGproperty[i].ownedby > BankruptPlayer):
#				MGproperty[i].ownedby -= 1
		player[BankruptPlayer].bankrupt = true
		bankruptPlayers.append(BankruptPlayer)
		BankruptPlayer = -1
		$Control/Bankrupcy.text = ""
		

func initiateAuction():
	var confirmauction = false
	if(Purchased == false):
		#auctionspace = CurrentTurn
		auctionspace = player[CurrentTurn].currentSpace
		if auctionspace in get_node("/root/Global_s").PropertySpaceList:
			confirmauction = true
		elif auctionspace in get_node("/root/Global_s").RailUtilSpaceList:
			confirmauction = true
		if(confirmauction):
			highestbidder = CurrentTurn
			currentbidder = CurrentTurn + 1
			highestbid = 0
			currentbid = 1
			bidderarray.clear()
			for n in Players:
				if(player[n].bankrupt == false):
					bidderarray.append(player[n].playerNum)
			#handleAuction()
			updateAuctionText()
			$Board/CanvasLayer/Auction.visible = true
			$Board/CanvasLayer/Auction/AuctionMessage.text = ""

func initiateItemSwapArray():
	var newArray = []
	var numMonopolySets = []
	var firstpropineachset = []
	var currentindex = 0
	for n in properties_to_make:
		var cset = MonopolySetArray(n)
		if(MGproperty[cset[0]].monopolyset in numMonopolySets):
			pass
		else:
			numMonopolySets.append(MGproperty[cset[0]].monopolyset)
			firstpropineachset.append(n)
	for t in numMonopolySets.size():
		var cset = MGproperty[firstpropineachset[t]].monopolyset
		for i in properties_to_make:
			if MGproperty[i].monopolyset == cset:
				newArray.append(MGproperty[i].Pnum)
	get_node("/root/Global_s").setItemSwap(newArray)

func checkPropClicks():
	var propclick = get_node("/root/Global_s").PropertyClicked
	if (propclick >= 0):
		overideswap = true
		PropertyPicked(propclick)
		overideswap = false
		get_node("/root/Global_s").OpenProperty(-1)

func FindOwner(location):
	var owner
#	for n in Players:
#		if location in player[n].PropertiesOwned:
#			owner = n
	owner = MGproperty[location].ownedby
	return owner

func netWorth(chosenplayer):
	var networth = player[chosenplayer].money
	for n in properties_to_make:
		var bill = get_node("/root/Global_s").PropPriceData[n]
		if (MGproperty[n].ownedby == chosenplayer):
			if(MGproperty[n].houses > 0):
				networth += MGproperty[n].houses * str2var(bill[1])
			if(MGproperty[n].mortgage == false):
				networth += str2var(bill[0]) / 2
	return networth

func AssignSpecialProperties(playersel, specialprop, assignment):
	for n in Players:
		if (player[n].specialProperties[specialprop] == 1):
			player[n].specialProperties[specialprop] = 0
	player[playersel].specialProperties[specialprop] = assignment


func AssignMonopoly():
	var MonopolyColorArray = []
	var colorselection
	var monopolys = get_node("/root/Global_s").cnummonopoly
	var cmonopoly = 0
	for n in properties_to_make:
		var color
		colorselection = get_node("/root/Global_s").ColorArray[n]
		color = Color(colorselection[0],colorselection[1],colorselection[2],1)
		MonopolyColorArray.append(color)
	var arr=[]
	for ncolor in MonopolyColorArray:
		#var newcolor = MonopolyColorArray[ncolor].color
		if !arr.has(ncolor):
			arr.append(ncolor)
	var numMonopolies = arr.size()
	for l in numMonopolies:
		for i in properties_to_make:
			if(MonopolyColorArray[i] == arr[l]):
				MGproperty[i].monopolyset = l
	for n in properties_to_make:
		if (get_node("/root/Global_s").shuffledproperties):
			get_node("/root/Global_s").MonopolySetsHardCode.append(MGproperty[get_node("/root/Global_s").ShuffledPropertyGuide[n]].monopolyset)
		else:
			get_node("/root/Global_s").MonopolySetsHardCode.append(MGproperty[n].monopolyset)
	


func MonopolyOwned(landed):
	var isowned : bool = false
	var set = get_node("/root/Global_s").MonopolySetsHardCode
	var checkedset = MGproperty[landed].monopolyset
	var numinset = set.count(checkedset)
	var numowned = 0
	var playercheck = MGproperty[landed].ownedby
	for n in properties_to_make:
		if (MGproperty[n].ownedby == playercheck && MGproperty[n].monopolyset == checkedset):
			numowned += 1
	if (numowned == numinset):
		isowned = true
	if(noMonopolyNeeded && playercheck >= 0):
		isowned = true
	return isowned

func MonopolySetArray(spotlanded):
	var setarray = []
	var set = get_node("/root/Global_s").MonopolySetsHardCode
	var checkedset = MGproperty[spotlanded].monopolyset
	var numinset = set.count(checkedset)
	for n in properties_to_make:
		if(MGproperty[n].monopolyset == checkedset):
			setarray.append(MGproperty[n].Pnum)
	return setarray


func UpdatePlayerInfo():
	var moneytracking = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	var propertyies = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	var textArray = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
	#var textArray = []
	var alterdname = get_node("/root/Global_s").playerNameString
	for n in Players:
		#textArray.append("")
		if n in bankruptPlayers:
			pass
		else:
			moneytracking[n] = player[n].money
			propertyies[n] = player[n].NumPropOwn
			var namestring = "Player " + var2str(player[n].playerNum)
			if (alterdname[n] != ""):
				namestring = alterdname[n]
			textArray [n] = namestring + "\n" + "" + player[n].icon +\
			"\nMoney: " + var2str(moneytracking[n]) + \
			"\nProperties: " + var2str(propertyies[n]) + "\nSpot: " + var2str(player[n].currentSpace)
	$Node/Player0.text = textArray[0]
	$Node/Player1.text = textArray[1]
	$Node/Player2.text = textArray[2]
	$Node/Player3.text = textArray[3]
	$Node/Player4.text = textArray[4]
	$Node/Player5.text = textArray[5]
	$Node/Player6.text = textArray[6]
	$Node/Player7.text = textArray[7]
	$Node/Player8.text = textArray[8]
	$Node/Player9.text = textArray[9]
	$Node/Player10.text = textArray[10]
	$Node/Player11.text = textArray[11]

func validhousebuild(proposedhouse, buildorsell):
	var validbuild : bool = true
	if(noMonopolyNeeded == false):
		var Housecheck = get_node("/root/Global_s").HousesPurchased
		var setarray = []
		var set = get_node("/root/Global_s").MonopolySetsHardCode
		var checkedset = MGproperty[proposedhouse].monopolyset
		var numinset = set.count(checkedset)
		for n in properties_to_make:
			if(MGproperty[n].monopolyset == checkedset):
				setarray.append(MGproperty[n].Pnum)
		#Housecheck[proposedhouse] += 1 * buildorsell
		if(buildorsell == 1 || buildorsell == -1):
			for i in setarray.size():
				if(MGproperty[setarray[i]].mortgage):
					validbuild = false
				if (abs((MGproperty[proposedhouse].houses + (1 * buildorsell)) - MGproperty[setarray[i]].houses) > 1):
					validbuild = false
			#Housecheck[proposedhouse] -= 1 * buildorsell
	#		if (get_node("/root/Global_s").hotelsingame >= get_node("/root/Global_s").maxhotels):
	#			validbuild = false
	#		if (get_node("/root/Global_s").housesingame >= get_node("/root/Global_s").maxhouses):
	#			validbuild = false
	if (MGproperty[proposedhouse].mortgage):
		validbuild = false
	return validbuild

func validhousebuildTimes3(proposedhouse, buildorsell):
	var validbuild : bool = true
	var Housecheck = get_node("/root/Global_s").HousesPurchased
	var setarray = []
	var set = get_node("/root/Global_s").MonopolySetsHardCode
	var checkedset = MGproperty[proposedhouse].monopolyset
	var numinset = set.count(checkedset)
	for n in properties_to_make:
		if(MGproperty[n].monopolyset == checkedset):
			setarray.append(MGproperty[n].Pnum)
	if(noMonopolyNeeded == false):
		#Housecheck[proposedhouse] += 1 * buildorsell
		if(buildorsell == 1 || buildorsell == -1):
			for i in setarray.size():
				if(MGproperty[setarray[i]].mortgage):
					validbuild = false
				if (abs((MGproperty[setarray[i]].houses + (1 * buildorsell)) - MGproperty[setarray[i]].houses) > 1):
					validbuild = false
			#Housecheck[proposedhouse] -= 1 * buildorsell
	#		if (get_node("/root/Global_s").hotelsingame >= get_node("/root/Global_s").maxhotels):
	#			validbuild = false
	#		if (get_node("/root/Global_s").housesingame >= get_node("/root/Global_s").maxhouses):
	#			validbuild = false
	for i in setarray.size():
		if(MGproperty[setarray[i]].mortgage):
			validbuild = false
	return validbuild

func GoToJail(currentspot, d1, d2):
	var jaillocation = get_node("/root/Global_s").BasicSpaceList[2]
	var spots_to_move
	spots_to_move = properties_to_make - currentspot + jaillocation - d1 - d2
	return spots_to_move

func handleAuction():
	var numbidders = bidderarray.size()
	currentbidder = currentbidder % numbidders
	updateAuctionText()
	$Sounds/Ding.play()
	$Board/CanvasLayer/Auction/AuctionMessage.text = ""
	if (numbidders > 1):
		if (currentbid > highestbid):
			highestbid = currentbid
			highestbidder = bidderarray[currentbidder]
			currentbidder += 1
			currentbidder = currentbidder % numbidders
#			if (currentbidder > numbidders):
#				currentbidder = 0
		else:
			$Board/CanvasLayer/Auction/AuctionMessage.text = player[bidderarray[currentbidder]].playername + " has backed out of the auction"
			$Board/CanvasLayer/Auction/Submit.disabled = true
			yield(get_tree().create_timer(1), "timeout")
			$Board/CanvasLayer/Auction/Submit.disabled = false
			$Board/CanvasLayer/Auction/AuctionMessage.text = ""
			bidderarray.remove(currentbidder)
			
			#currentbidder = currentbidder % numbidders
			if (bidderarray.size() <= 1):
				currentbidder = highestbidder
				purchaseSpace(auctionspace,highestbidder,highestbid)
				UpdatePlayerInfo()
				$Board/CanvasLayer/Auction/AuctionMessage.text = "The property " + MGproperty[auctionspace].Pname + "is sold for: $" + \
				var2str(currentbid) + " to Player " + player[highestbidder].playername
				$Board/CanvasLayer/Auction/Submit.disabled = true
				yield(get_tree().create_timer(2.5), "timeout")
				$Board/CanvasLayer/Auction/Submit.disabled = false
				$Board/CanvasLayer/Auction.visible = false
				removePlayer()
		updateAuctionText()
#	else: #bid done
#		purchaseSpace(auctionspace,highestbidder,highestbid)
#		UpdatePlayerInfo()
#		$Board/CanvasLayer/Auction/AuctionMessage.text = "The property " + MGproperty[auctionspace].Pname + "is sold for: " + \
#		var2str(currentbid) + " by player " + var2str(highestbidder)
#		$Board/CanvasLayer/Auction/Submit.disabled = true
#		yield(get_tree().create_timer(1.8), "timeout")
#		$Board/CanvasLayer/Auction/Submit.disabled = false
#		$Board/CanvasLayer/Auction.visible = false
		

func handleRailroadRule(currentspot):
	var railroadarray = []
	if(railroadRule):
		for n in MGproperty.size():
			if(get_node("/root/Global_s").Alltypes[n] == 3 && MGproperty[n].Pnum != currentspot && MGproperty[n].ownedby != -1):
				railroadarray.append(n)
	if(railroadarray.size() >= 3):
		$Board/CanvasLayer/RuleVarient/Railroad3.text = MGproperty[railroadarray[2]].Pname
		$Board/CanvasLayer/RuleVarient/Railroad3.disabled = false
	if(railroadarray.size() >= 2):
		$Board/CanvasLayer/RuleVarient/Railroad2.text = MGproperty[railroadarray[1]].Pname
		$Board/CanvasLayer/RuleVarient/Railroad2.disabled = false
	if(railroadarray.size() >= 1):
		$Board/CanvasLayer/RuleVarient/Railroad1.text = MGproperty[railroadarray[0]].Pname
		$Board/CanvasLayer/RuleVarient/Railroad1.disabled = false
		$Board/CanvasLayer/RuleVarient.visible = true
	#railroadRuleJustMoves = true
	return railroadarray

func activateRailroadRule(picked):
	var choices = handleRailroadRule(player[CurrentTurn].currentSpace)
	var spacestomove = (choices[picked] - player[CurrentTurn].currentSpace + properties_to_make) % properties_to_make
	player[CurrentTurn].move(spacestomove)
	if (choices[picked] < player[CurrentTurn].currentSpace):
		player[CurrentTurn].money -= goMoney
	$Board/CanvasLayer/RuleVarient.visible = false
	railroadRuleJustMoves = true
	yield(get_tree().create_timer(spacestomove * .17), "timeout")
	ResolveLand(CurrentTurn)

func updateAuctionText():
	var numbidders =  bidderarray.size()
	var alterdname = get_node("/root/Global_s").playerNameString
	if currentbidder >= numbidders:
		currentbidder = 0
	var teststring = var2str(bidderarray[currentbidder])
#	if currentbidder < bidderarray.size():
#		teststring = var2str(bidderarray[currentbidder])
	$Board/CanvasLayer/Auction/AuctionInfo.text = "The property " + MGproperty[auctionspace].Pname + " is up for Auction" + \
	"\nThe current bid is: $" + var2str(highestbid) + " by " + alterdname[highestbidder] + "\n\n\nYour bid is: $" + \
	 var2str(currentbid) + " as " + alterdname[currentbidder]#var2str(bidderarray[currentbidder])#var2str(currentbidder)
#	$Board/CanvasLayer/Auction/AuctionInfo.text = "The property " + MGproperty[auctionspace].Pname + " is up for Auction" + \
#	"\nThe current bid is: $" + var2str(highestbid) + " by player " + var2str(highestbidder) + "\n\n\nYour bid is: $" + \
#	 var2str(currentbid) + " as player " + teststring#var2str(bidderarray[currentbidder])#var2str(currentbidder)

func UpdatePropertiesReference():
	$Board/CanvasLayer/Panel/ItemList.clear()
	var ownedstring
	for n in properties_to_make:
		var shiftedarray = get_node("/root/Global_s").ItemSlectorSwapper
		var testshifting = shiftedarray[n]
		var initialN = n
		n = testshifting
		if(MGproperty[n].ownedby < 0):
			ownedstring = "Unowned"
		else:
			#ownedstring = var2str(MGproperty[n].ownedby)
			ownedstring = player[MGproperty[n].ownedby].playername
		#change color of property
		var propertystring = get_node("/root/Global_s").PropNamesData[n]
		#var colorarray = get_node("/root/Global_s").MonopolySetsHardCode
		var mortgagedstring = ""
		if(MGproperty[n].mortgage):
			mortgagedstring = " - Mortgaged"
		if(MGproperty[n].houses > 0):
			mortgagedstring = " - Houses: " + var2str(MGproperty[n].houses)
		$Board/CanvasLayer/Panel/ItemList.add_item(get_node("/root/Global_s").PropNamesData[n] + \
		" - Owner: " + ownedstring + mortgagedstring)
		var colorselection = get_node("/root/Global_s").ColorArray[n]
		var backgroundcolor = Color(colorselection[0],colorselection[1],colorselection[2],.75)
		$Board/CanvasLayer/Panel/ItemList.set_item_custom_bg_color(initialN,backgroundcolor)
		n = initialN
#	for n in properties_to_make:
#		var shiftedarray = get_node("/root/Global_s").ItemSlectorSwapper
#		var colorselection = get_node("/root/Global_s").ColorArray[n]
#		var backgroundcolor = Color(colorselection[0],colorselection[1],colorselection[2],.75)
#		$Board/CanvasLayer/Panel/ItemList.set_item_custom_bg_color(n,backgroundcolor)
		#var2str(get_node("/root/Global_s").PropertyOwnership[n]))
	#$Board/CanvasLayer/Panel/ItemList.
#	var shiftedarray = get_node("/root/Global_s").ItemSlectorSwapper
#	for n in shiftedarray.size():
#		$Board/CanvasLayer/Panel/ItemList.move_item(shiftedarray[n],n)
	pass
	

func BankruptCheck():
	BankruptPlayer = -1
	for n in Players:
		if(player[n].money <= 0 && player[n].bankrupt == false):
			BankruptPlayer = n
			$Control/Bankrupcy.text = player[n].playername + \
			" is Bankrupt.\nIf end turn is\n clicked they will \n be out of the game\n sell something to stay in" + \
			"There networth is: " + var2str(netWorth(BankruptPlayer)) + "\nThey owe: " + var2str(player[BankruptPlayer].money)
	if (BankruptPlayer == -1):
		$Control/Bankrupcy.text = ""
	#return BankruptPlayer

func UpdatePropertySelectionText():
	var index = PropertyInfoIndex
	var ownedstring
	var moneystring
	var bill = get_node("/root/Global_s").PropPriceData[index]
	var Housecheck = get_node("/root/Global_s").HousesPurchased[index]
	#var owner = get_node("/root/Global_s").PropertyOwnership[index]
	var owner = MGproperty[index].ownedby
	if(MGproperty[index].ownedby < 0):
		ownedstring = "Unowned"
		moneystring = "-"
	else:
		#ownedstring = var2str(MGproperty[index].ownedby)
		ownedstring = player[MGproperty[index].ownedby].playername
		moneystring = var2str(player[MGproperty[index].ownedby].money)
	var mortgaged = " not"
	if index in get_node("/root/Global_s").PropertiesPurchased:
		if (MGproperty[index].mortgage):
			mortgaged = ""
	var housestring = var2str(MGproperty[PropertyInfoIndex].houses)
	$Board/CanvasLayer/PropertyProperties/PropInfo.text = " " + get_node("/root/Global_s").PropNamesData[index] + "\n Owned By " + \
	ownedstring + "\n Player Balance: " + moneystring + "\n Base Rent: " + var2str(bill[2]) + \
	 "\n Rent 1 House: " + var2str(bill[3]) + "\n Rent 2 House: " + var2str(bill[4]) + "\n Rent 3 House: " + var2str(bill[5]) + \
	"\n Rent 4 House: " + var2str(bill[6]) + "\n Rent Hotel: " + var2str(bill[7]) + "\n Cost Per House: " + var2str(bill[1]) + \
	"\n This Property currently has " + housestring + " Houses" + "\n This property is" + mortgaged +  " Mortgaged"

func UpdateTradeScreen():
	$Board/CanvasLayer/TradeScreen/MoneyPlayerSelector.max_value = Players - 1
	$Board/CanvasLayer/TradeScreen/PropertyPlayerSelector.max_value = Players - 1
	$Board/CanvasLayer/TradeScreen/PropertySlector.max_value = properties_to_make - 1
	var propnum = $Board/CanvasLayer/TradeScreen/PropertySlector.value
	var buyersmoney = $Board/CanvasLayer/TradeScreen/MoneyPlayerSelector.value
	$Board/CanvasLayer/TradeScreen/MoneyOffered.max_value = player[buyersmoney].money
	var testtext = get_node("/root/Global_s").PropNamesData[propnum]
	$Board/CanvasLayer/TradeScreen/SellPropertyInfo.text = testtext
	var ownedstring
	if(FindOwner(propnum) < 0):
		ownedstring = "Not Owned"
	else:
		ownedstring = player[FindOwner(propnum)].playername
		#ownedstring = var2str(FindOwner(propnum))
	$Board/CanvasLayer/TradeScreen/SellPlayerInfo.text = "Sell Player: " + ownedstring
	$Board/CanvasLayer/TradeScreen/BuyPlayerInfo.text = "Buyer Player: " + player[buyersmoney].playername + "\nBalance: " + var2str(player[buyersmoney].money)

func UpdateRentDealScreen():
	$Board/CanvasLayer/RentDeal/PlayerDealtSelector.max_value = Players - 1
	$Board/CanvasLayer/RentDeal/RentPropertySlector.max_value = properties_to_make - 1
	var propnum = $Board/CanvasLayer/RentDeal/RentPropertySlector.value
	var testtext = get_node("/root/Global_s").PropNamesData[propnum]
	$Board/CanvasLayer/RentDeal/SellPropertyInfo.text = testtext
	$Board/CanvasLayer/RentDeal/RentMessageCenter.text = ""
	var investor = $Board/CanvasLayer/RentDeal/PlayerDealtSelector.value
	$Board/CanvasLayer/RentDeal/PlayerDealt.text = player[investor].playername

func specificplayerproperties(playerselector):
	#var playerselector = 0
	var specialstring = ""
	for i in player[playerselector].specialProperties.size():
		if (player[playerselector].specialProperties[i] !=0):
			specialstring += " " + get_node("/root/Global_s").specialPropertiesString[i] + ","
	$Board/CanvasLayer/PlayerProperties.visible = true
	var propertiesowned = "You're Net Worth is " + var2str(netWorth(playerselector)) +\
	"\nYou have these special items:" + specialstring + "\nYou own these properties:"
	for n in properties_to_make:
		if(MGproperty[n].ownedby == playerselector):
			#var colorselection = get_node("/root/Global_s").ColorArray[n]
			var colorselection = get_node("/root/Global_s").MonopolyColorHardCode[MGproperty[n].monopolyset]
			var colortext = "[color=" + colorselection + "]"
			propertiesowned = propertiesowned + "\n" + colortext + MGproperty[n].Pname + "[/color] " +\
			var2str(MGproperty[n].investmentownerarray[MGproperty[n].ownedby]) + "%"
	propertiesowned += "\n\nYou have the following % of other players properties"
	for n in properties_to_make:
		if(MGproperty[n].investmentdeal && MGproperty[n].investmentownerarray[playerselector] > 0 && MGproperty[n].ownedby != playerselector):
			#var colorselection = get_node("/root/Global_s").ColorArray[n]
			var colorselection = get_node("/root/Global_s").MonopolyColorHardCode[MGproperty[n].monopolyset]
			var colortext = "[color=" + colorselection + "]"
			propertiesowned = propertiesowned + "\n" + colortext + MGproperty[n].Pname + "[/color] " +\
			var2str(MGproperty[n].investmentownerarray[playerselector]) + "%"
	$Board/CanvasLayer/PlayerProperties/PlayerPropInfo.bbcode_text = propertiesowned
	$Board/CanvasLayer/PlayerProperties/PlayerPropInfo.bbcode_enabled = true

func pauseMenu():
	if ($Board/CanvasLayer/PauseMenu.visible == false):
		if($Board/CanvasLayer/Panel.visible == false && $Board/CanvasLayer/TradeScreen.visible == false && $Board/CanvasLayer/PropertyProperties.visible == false):
			$Board/CanvasLayer/PauseMenu.visible = true
	else:
		$Board/CanvasLayer/PauseMenu.visible = false
	if($Board/CanvasLayer/PropertyProperties.visible == true):
		$Board/CanvasLayer/PropertyProperties.visible = false
	if($Board/CanvasLayer/Panel.visible == true):
		$Board/CanvasLayer/Panel.visible = false
	if($Board/CanvasLayer/PlayerProperties.visible == true):
		$Board/CanvasLayer/PlayerProperties.visible = false

func purchaseSpace(overidespace, overideplayer, priceoveride):
	var realspot = 0
	var realplayer = 0
	var realprice = 0
	if (overidespace == -1):
		realspot = spot
	else:
		realspot = overidespace
	if (overideplayer == -1):
		realplayer = CurrentTurn
	else:
		realplayer = overideplayer
	var bill = get_node("/root/Global_s").PropPriceData[realspot]
	var Housecheck = get_node("/root/Global_s").HousesPurchased[realspot]
	var Payerplayer = player[realplayer]
	if (priceoveride == -1):
		realprice = str2var(bill[Housecheck])
	else:
		realprice = priceoveride
	Payerplayer.money -= realprice
	Payerplayer.PropertiesOwned.append(realspot)
	get_node("/root/Global_s").PropertiesPurchased.append(realspot)
	Payerplayer.NumPropOwn += 1
	get_node("/root/Global_s").PropertyOwnership[realspot] = realplayer
	$Control/ResolveMessage.text = "You bought " + get_node("/root/Global_s").PropNamesData[realspot]
	MGproperty[realspot].ownedby = realplayer
	if (MGproperty[realspot].proptype == 3):
		Payerplayer.railRoadsOwned += 1
		if (Payerplayer.railRoadsOwned == 1):
			$Control/ResolveMessage.text += "\nTheir sense of smell is improving"
		elif (Payerplayer.railRoadsOwned == 2):
			$Control/ResolveMessage.text += "\nTheir sense of smell is phenomenal"
		elif (Payerplayer.railRoadsOwned == 3):
			$Control/ResolveMessage.text += "\nTheir sense of smell is insane"
		elif (Payerplayer.railRoadsOwned == 4):
			$Control/ResolveMessage.text += "\nTheir sense of smell is perfect"
	elif(MGproperty[realspot].proptype == 5):
		Payerplayer.UtilitiesOwned += 1
		if(realspot == 28):
			$Control/ResolveMessage.text = "You just lost the game"
	player[realplayer] = Payerplayer
	$Sounds/ChaChing.play()
	for n in MGproperty[realspot].investmentownerarray.size():
		MGproperty[realspot].investmentownerarray[n] = 0
	MGproperty[realspot].investmentownerarray[realplayer] = 100

func EndTheTradeDealFunction(propnum):
	var owner = MGproperty[propnum].ownedby
	for n in MGproperty[propnum].investmentownerarray.size():
		MGproperty[propnum].investmentownerarray[n] = 0
		if (n == owner):
			MGproperty[propnum].investmentownerarray[n] = 100
	MGproperty[propnum].investmentdeal = false
	$Board/CanvasLayer/RentDeal/RentMessageCenter.text = "Owner restored to 100% Ownership"

func adminedit(playerselected, moneyset, propset):
	var intmoney : int = int(moneyset)
	var intpropset : int = int(propset)
	playerselected = int(playerselected)
	player[playerselected].money = intmoney
	if intpropset != properties_to_make:
		player[playerselected].PropertiesOwned.append(intpropset)
		get_node("/root/Global_s").PropertiesPurchased.append(intpropset)
		player[playerselected].NumPropOwn += 1
		get_node("/root/Global_s").PropertyOwnership[intpropset] = playerselected
		MGproperty[intpropset].ownedby = playerselected
		if (MGproperty[intpropset].proptype == 3):
			player[playerselected].railRoadsOwned += 1
		elif(MGproperty[intpropset].proptype == 5):
			player[playerselected].UtilitiesOwned += 1
		for n in MGproperty[intpropset].investmentownerarray.size():
			MGproperty[intpropset].investmentownerarray[n] = 0
		MGproperty[intpropset].investmentownerarray[playerselected] = 100


#Triggers
func turnDone():
	TurnTaker()


func PaySpace():
	var bill = get_node("/root/Global_s").PropPriceData[spot]
	var Housecheck = get_node("/root/Global_s").HousesPurchased[spot]
	$Control/Pay.disabled = true
	if(Purchased):
		pass
	else:
		purchaseSpace(-1,-1,-1)
		Purchased = true
	UpdatePlayerInfo()
	BankruptCheck()


func ReferenceButton():
	UpdatePropertiesReference()
	if($Board/CanvasLayer/Panel.visible):
		$Board/CanvasLayer/Panel.visible = false
	else:
		$Board/CanvasLayer/Panel.visible = true
	UpdatePlayerInfo()


func ClosePropProp():
	$Board/CanvasLayer/PropertyProperties/MessageCenter.text = ""
	$Board/CanvasLayer/PropertyProperties.visible = false
	UpdatePropertiesReference()


func PropertyPicked(index):
	#PropertyInfoIndex = index
	var shiftedarray = get_node("/root/Global_s").ItemSlectorSwapper
	if (overideswap == false):
		PropertyInfoIndex = shiftedarray[index]
	else:
		PropertyInfoIndex = index
	$Board/CanvasLayer/PropertyProperties.visible = true
	UpdatePropertySelectionText()
#	for n in shiftedarray.size():
#		$Board/CanvasLayer/Panel/ItemList.move_item(shiftedarray[n],n)


func BuyHouse():
	var selector = FindOwner(PropertyInfoIndex)
	var bill = get_node("/root/Global_s").PropPriceData[PropertyInfoIndex]
	var Housecheck = get_node("/root/Global_s").HousesPurchased[PropertyInfoIndex]
	if(MonopolyOwned(PropertyInfoIndex)):
		if PropertyInfoIndex in get_node("/root/Global_s").PropertySpaceList:
			if (selector != null && get_node("/root/Global_s").Alltypes[PropertyInfoIndex] == 4):
				if (player[selector].money >= str2var(bill[1])):
					if(validhousebuild(PropertyInfoIndex,1)):
						if (MGproperty[PropertyInfoIndex].houses == 4 && ((get_node("/root/Global_s").maxhotels - get_node("/root/Global_s").hotelsingame) > 0)):
							player[selector].money -= str2var(bill[1])
							get_node("/root/Global_s").HousesPurchased[PropertyInfoIndex] += 1
							MGproperty[PropertyInfoIndex].houses += 1
							get_node("/root/Global_s").hotelsetter(1)
							get_node("/root/Global_s").housesetter(-4)
							$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "1 Hotel has been Bought"
							$Sounds/ChaChing.play()
						elif(MGproperty[PropertyInfoIndex].houses < 4 && ((get_node("/root/Global_s").maxhouses - get_node("/root/Global_s").housesingame) > 0)):
							player[selector].money -= str2var(bill[1])
							get_node("/root/Global_s").HousesPurchased[PropertyInfoIndex] += 1
							MGproperty[PropertyInfoIndex].houses += 1
							get_node("/root/Global_s").housesetter(1)
							$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "1 House has been Bought"
							$Sounds/ChaChing.play()
						else:
							$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No housing or at Hotel"
							$Sounds/Invalid.play()
					else:
						$Sounds/Invalid.play()
						$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "Mortgaged or Even Build Required"
				else:
					$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "Not Enough Money"
					$Sounds/Invalid.play()
			else:
				$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No One Owns this"
				$Sounds/Invalid.play()
		else:
			$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No Houses can be built here"
			$Sounds/Invalid.play()
	else:
		$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "This Monopoly is not owned"
		$Sounds/Invalid.play()
	UpdatePropertySelectionText()
	UpdatePlayerInfo()


func SellHouse():
	var selector = FindOwner(PropertyInfoIndex)
	var bill = get_node("/root/Global_s").PropPriceData[PropertyInfoIndex]
	var Housecheck = get_node("/root/Global_s").HousesPurchased[PropertyInfoIndex]
	var housesleft = get_node("/root/Global_s").maxhouses - get_node("/root/Global_s").housesingame
	if PropertyInfoIndex in get_node("/root/Global_s").PropertiesPurchased:
		if (selector != null):
			if (MGproperty[PropertyInfoIndex].houses > 0 && get_node("/root/Global_s").Alltypes[PropertyInfoIndex] == 4):
				if(validhousebuild(PropertyInfoIndex,-1)):
					player[selector].money += str2var(bill[1]) / 2
					get_node("/root/Global_s").HousesPurchased[PropertyInfoIndex] -= 1
					MGproperty[PropertyInfoIndex].houses -= 1
					$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "1 House has been Sold"
					if(MGproperty[PropertyInfoIndex].houses >= 4):
						if(housesleft >= 4):
							get_node("/root/Global_s").housesetter(4)
							get_node("/root/Global_s").hotelsetter(-1)
						else:
							MGproperty[PropertyInfoIndex].houses += 1
							player[selector].money -= str2var(bill[1]) / 2
							var CurrentHousesOnMonopoly = 0
							var monset = MonopolySetArray(PropertyInfoIndex)
							var evendistribute = housesleft % monset.size()
							for n in monset.size():
								CurrentHousesOnMonopoly += MGproperty[n].houses
								MGproperty[n].houses = evendistribute
								housesleft -= evendistribute
							for i in housesleft:
								MGproperty[i % monset.size()].houses += 1
							player[selector].money += (str2var(bill[1]) / 2) * (CurrentHousesOnMonopoly - housesleft)
							get_node("/root/Global_s").housesetter(-housesleft)
							get_node("/root/Global_s").hotelsetter(-3)
							$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "Houses altered due to housing shortage"
					else:
						get_node("/root/Global_s").housesetter(-1)
					$Sounds/ChaChing.play()
				else:
					$Sounds/Invalid.play()
					$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "Houses must be sold evenly"
			else:
				$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No houses to sell"
				$Sounds/Invalid.play()
		else:
			$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No One Owns this"
			$Sounds/Invalid.play()
	else:
		$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No houses can be sold here"
		$Sounds/Invalid.play()
	UpdatePropertySelectionText()
	UpdatePlayerInfo()


func Mortgage():
	var selector = FindOwner(PropertyInfoIndex)
	var bill = get_node("/root/Global_s").PropPriceData[PropertyInfoIndex]
	var Housecheck = get_node("/root/Global_s").HousesPurchased[PropertyInfoIndex]
	if PropertyInfoIndex in get_node("/root/Global_s").PropertiesPurchased:
		if (selector != -1):
			if (Housecheck > 0):
				$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "You can not Mortgage with Houses"
				$Sounds/Invalid.play()
			else:
				var mortgage_calc = str2var(bill[0]) / 2
				$Sounds/ChaChing.play()
				if(MGproperty[PropertyInfoIndex].mortgage == false):#not mortgage
					$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "It is Mortgaged for " + var2str(mortgage_calc)
					player[selector].money += mortgage_calc
					MGproperty[PropertyInfoIndex].mortgage = true
					#get_node("/root/Global_s").HousesPurchased[PropertyInfoIndex] -= 1
				else:
					$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "It is Unmortgaged for " + var2str(mortgage_calc * 1.1)
					player[selector].money -= mortgage_calc * 1.1
					MGproperty[PropertyInfoIndex].mortgage = false
					#get_node("/root/Global_s").HousesPurchased[PropertyInfoIndex] -= 1
		else:
			$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No One Owns this"
			$Sounds/Invalid.play()
	else:
		$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No One Owns this"
		$Sounds/Invalid.play()
	UpdatePropertySelectionText()




func CloseReference():
	$Board/CanvasLayer/Panel.visible = false
	UpdatePlayerInfo()


func TradeButton():
	$Board/CanvasLayer/TradeScreen/TradeMessage.text = ""
	UpdatePropertiesReference()
	
#	var shiftedarray = get_node("/root/Global_s").ItemSlectorSwapper
#	for n in shiftedarray.size():
#		$Board/CanvasLayer/Panel/ItemList.move_item(shiftedarray[n],n)
	
	if($Board/CanvasLayer/TradeScreen.visible):
		$Board/CanvasLayer/TradeScreen.visible = false
	else:
		$Board/CanvasLayer/TradeScreen.visible = true
	UpdatePlayerInfo()


func CloseTrading():
	$Board/CanvasLayer/TradeScreen.visible = false
	UpdatePropertiesReference()
	UpdatePlayerInfo()
	UpdatePropertySelectionText()
	$Board/CanvasLayer/TradeScreen/TradeMessage.text = ""
	$Board/CanvasLayer/TradeScreen/TradeConfrim.disabled = false


func TradeConfirmButton():
	var propnum = $Board/CanvasLayer/TradeScreen/PropertySlector.value
	moneyoffered = $Board/CanvasLayer/TradeScreen/MoneyOffered.value
	var sellplayer = $Board/CanvasLayer/TradeScreen/PropertyPlayerSelector.value
	var buyplayer = $Board/CanvasLayer/TradeScreen/MoneyPlayerSelector.value
	moneyoffered = int(moneyoffered)
	sellplayer = int(sellplayer)
	buyplayer = int(buyplayer)
	sellplayer = FindOwner(propnum)
	if (MGproperty[propnum].ownedby == sellplayer && sellplayer >= 0):
		if(player[buyplayer].money >= moneyoffered):
			if(MGproperty[propnum].houses < 1):
				player[sellplayer].money += moneyoffered
				player[buyplayer].money -= moneyoffered
				player[buyplayer].PropertiesOwned.append(propnum)
				var remove = player[sellplayer].PropertiesOwned.find(propnum)
				player[sellplayer].PropertiesOwned.remove(remove)
				player[buyplayer].NumPropOwn += 1
				player[sellplayer].NumPropOwn -= 1
				get_node("/root/Global_s").PropertyOwnership[propnum] = buyplayer
				MGproperty[propnum].ownedby = buyplayer
				if (MGproperty[propnum].proptype == 3):
					player[buyplayer].railRoadsOwned += 1
					player[sellplayer].railRoadsOwned -= 1
				elif(MGproperty[propnum].proptype == 5):
					player[buyplayer].UtilitiesOwned += 1
					player[sellplayer].UtilitiesOwned -= 1
				$Board/CanvasLayer/TradeScreen/TradeMessage.text = "The trade has been completed\nAll Rent Deals Absolved"
				EndTheTradeDealFunction(propnum)
				$Sounds/Ding.play()
				$Board/CanvasLayer/TradeScreen/TradeConfrim.disabled = true
				yield(get_tree().create_timer(1.8), "timeout")
				CloseTrading()
			else:
				$Board/CanvasLayer/TradeScreen/TradeMessage.text = "You cannot trade with houses"
				$Sounds/Invalid.play()
		else:
			$Board/CanvasLayer/TradeScreen/TradeMessage.text = "Buy Player does not have enough Money"
			$Sounds/Invalid.play()
	else:
		$Board/CanvasLayer/TradeScreen/TradeMessage.text = "Sell Player does not Own that Property"
		$Board/CanvasLayer/TradeScreen/TradeMessage.text = "Property is not Owned"
		$Sounds/Invalid.play()
	UpdatePropertiesReference()

func PropertySlector(value):
	#UpdateTradeScreen()
	pass

func PropertySlectorUpdated(value):
	UpdateTradeScreen()

func MoneyPlayerSelector():
	#UpdateTradeScreen()
	pass


func MoneyPlayerSelectorUpdate(value):
	UpdateTradeScreen()


func PaytoLeaveJail():
	$Control/ResolveMessage.text = "You payed 50 to leave jail"
	$Control/JailPayout.visible = false
	player[CurrentTurn].money -= 50
	freeParking += 50
	player[CurrentTurn].Jailed = false
	player[CurrentTurn].JailRolls = 0
	player[CurrentTurn].doublesrolled = 0


func _on_ClosePlayerProp_pressed():
	$Board/CanvasLayer/PlayerProperties.visible = false


func NextMonopolyProp():
	var set = get_node("/root/Global_s").MonopolySetsHardCode
	var checkedset = MGproperty[PropertyInfoIndex].monopolyset
	var numinset = set.count(checkedset)
	var propnumset = []
	for n in properties_to_make:
		if (MGproperty[n].monopolyset == checkedset):
			propnumset.append(MGproperty[n].Pnum)
	var initialindex = propnumset.find(MGproperty[PropertyInfoIndex].Pnum)
	initialindex += 1
	if(initialindex >= numinset):
		initialindex = 0
	PropertyInfoIndex = propnumset[initialindex]
	UpdatePropertySelectionText()
	pass

func TradeProp():
	UpdatePropertiesReference()
	if($Board/CanvasLayer/TradeScreen.visible):
		$Board/CanvasLayer/TradeScreen.visible = false
	else:
		$Board/CanvasLayer/TradeScreen.visible = true
	UpdatePlayerInfo()
	$Board/CanvasLayer/TradeScreen/PropertySlector.value = PropertyInfoIndex
	UpdateTradeScreen()



func NextOwnedMonopoly():
	var set = get_node("/root/Global_s").MonopolySetsHardCode
	var curplayer = MGproperty[PropertyInfoIndex].ownedby
	var propnumset = []
	for n in properties_to_make:
		if (MGproperty[n].ownedby == curplayer):
			propnumset.append(MGproperty[n].Pnum)
	var initialindex = propnumset.find(MGproperty[PropertyInfoIndex].Pnum)
	initialindex += 1
	var numinset = propnumset.size()
	if(initialindex >= numinset):
		initialindex = 0
	PropertyInfoIndex = propnumset[initialindex]
	UpdatePropertySelectionText()
	$Board/CanvasLayer/PropertyProperties/MessageCenter.text = ""
	pass

func _on_Player0Properties_button_down():
	specificplayerproperties(0)


func _on_Player1Properties_button_down():
	specificplayerproperties(1)



func _on_Player2Properties_button_down():
	specificplayerproperties(2)


func _on_Player3Properties_button_down():
	specificplayerproperties(3)


func _on_Player4Properties_button_down():
	specificplayerproperties(4)


func _on_Player5Properties_button_down():
	specificplayerproperties(5)






func MainMenu_button():
	get_tree().change_scene("res://Menu.tscn")


func Resume_button():
	pauseMenu()


func _on_Submit_pressed():
	handleAuction()
	updateAuctionText()


func _on_Increase1_button_down():
	currentbid += 1
	if (player[currentbidder].money < currentbid):
		currentbid -= 1
	handleAuction()
	#updateAuctionText()


func _on_Increase10_pressed():
	currentbid += 10
	if (player[currentbidder].money < currentbid):
		currentbid -= 10
	handleAuction()
	#updateAuctionText()


func _on_Increase100_pressed():
	currentbid += 100
	if (player[currentbidder].money < currentbid):
		currentbid -= 100
	handleAuction()
	#updateAuctionText()


func _on_MoneyOffered_value_changed(value):
	moneyoffered = value


func PlayerDealtSelector(value):
	UpdateRentDealScreen()


func _on_CloseInvest_pressed():
	$Board/CanvasLayer/RentDeal.visible = false


func _on_PropertySlector_value_changed(value):
	UpdateRentDealScreen()


func _on_PercentOffered_value_changed(value):
	UpdateRentDealScreen()


func _on_RentPropertySlector_value_changed(value):
	UpdateRentDealScreen()


func ConfirmRentDeal():
	var valid = false
	var propnum = $Board/CanvasLayer/RentDeal/RentPropertySlector.value
	var proposedpercent = $Board/CanvasLayer/RentDeal/PercentOffered.value
	var investor = $Board/CanvasLayer/RentDeal/PlayerDealtSelector.value
	var owner = MGproperty[propnum].ownedby
	if (owner < 0):
		$Board/CanvasLayer/RentDeal/RentMessageCenter.text = "This Property is not owned"
		$Sounds/Invalid.play()
		return
	var availablepercent = MGproperty[propnum].investmentownerarray[owner]
	for n in Players:
		if(player[n].playerNum == investor):
			valid = true
	if (availablepercent > proposedpercent):
		if (owner == investor):
			$Board/CanvasLayer/RentDeal/RentMessageCenter.text = "Selected player is primary owner"
			$Sounds/Invalid.play()
			valid = false
		else:
			valid = true
	else:
		$Board/CanvasLayer/RentDeal/RentMessageCenter.text = "This is too high a percent"
		$Sounds/Invalid.play()
		valid = false
	
	#Complete the trade
	if(valid):
		MGproperty[propnum].investmentownerarray[investor] += proposedpercent
		MGproperty[propnum].investmentownerarray[owner] = availablepercent - proposedpercent
		MGproperty[propnum].investmentdeal = true
		$Board/CanvasLayer/RentDeal/RentMessageCenter.text = player[investor].playername +\
		" has been given " + var2str(proposedpercent) + " %"
		$Board/CanvasLayer/RentDeal/ConfirmDeal.disabled = true
		yield(get_tree().create_timer(1), "timeout")
		$Board/CanvasLayer/RentDeal/ConfirmDeal.disabled = false
		$Board/CanvasLayer/RentDeal/RentMessageCenter.text = ""
	


func EndDeal():
	var propnum = $Board/CanvasLayer/RentDeal/RentPropertySlector.value
	var proposedpercent = $Board/CanvasLayer/RentDeal/PercentOffered.value
	var investor = $Board/CanvasLayer/RentDeal/PlayerDealtSelector.value
	EndTheTradeDealFunction(propnum)
	


func _on_Invest_pressed():
	$Board/CanvasLayer/RentDeal.visible = true




func _on_Admin_button_down():
	$Board/CanvasLayer/Admin.visible = true
	$Board/CanvasLayer/Admin/PlayerEdit.max_value = Players - 1
	$Board/CanvasLayer/Admin/PropertyEdit.max_value = properties_to_make
	$Board/CanvasLayer/Admin/MoneyEdit.max_value = 100000
	var nplayer = $Board/CanvasLayer/Admin/PlayerEdit.value
	$Board/CanvasLayer/Admin/AlteredPlayer.text = "Altered Player: " + player[nplayer].playername


func _on_CloseAdmin_button_down():
	$Board/CanvasLayer/Admin.visible = false
	$Board/CanvasLayer/Admin/MessageCenter.text = ""
	UpdatePlayerInfo()


func _on_AlterPlayer_button_down():
	var nmoney = $Board/CanvasLayer/Admin/MoneyEdit.value
	var nplayer = $Board/CanvasLayer/Admin/PlayerEdit.value
	var nprop = $Board/CanvasLayer/Admin/PropertyEdit.value
	$Board/CanvasLayer/Admin/AlteredPlayer.text = "Altered Player: " + player[nplayer].playername
	if nprop in get_node("/root/Global_s").BasicSpaceList || nprop in get_node("/root/Global_s").ChanceCCSpaceList:
		$Board/CanvasLayer/Admin/MessageCenter.text = "Property can not be owned"
	else:
		adminedit(nplayer,nmoney,nprop)
		$Board/CanvasLayer/Admin/MessageCenter.text = "Edit Confirmed"
		yield(get_tree().create_timer(1), "timeout")
		$Board/CanvasLayer/Admin/MessageCenter.text = ""


func _on_MoneyPlayerSelector_value_changed(value):
	var nplayer = $Board/CanvasLayer/Admin/PlayerEdit.value
	$Board/CanvasLayer/Admin/AlteredPlayer.text = "Altered Player: " + player[nplayer].playername


func _on_PropertyEdit_value_changed(value):
	var nplayer = $Board/CanvasLayer/Admin/PlayerEdit.value
	$Board/CanvasLayer/Admin/AlteredPlayer.text = "Altered Player: " + player[nplayer].playername
	if value == properties_to_make:
		$Board/CanvasLayer/Admin/PropertySelectionInfo.text = "No Properties"
	else:
		$Board/CanvasLayer/Admin/PropertySelectionInfo.text = MGproperty[value].Pname


func Build3Houses():
	var selector = FindOwner(PropertyInfoIndex)
	var bill = get_node("/root/Global_s").PropPriceData[PropertyInfoIndex]
	var Housecheck = get_node("/root/Global_s").HousesPurchased[PropertyInfoIndex]
	if(MonopolyOwned(PropertyInfoIndex)):
		if PropertyInfoIndex in get_node("/root/Global_s").PropertySpaceList:
			if (selector != null && get_node("/root/Global_s").Alltypes[PropertyInfoIndex] == 4):
				var monopolysettobuild = MonopolySetArray(PropertyInfoIndex)
				if (player[selector].money >= str2var(bill[1]) * monopolysettobuild.size()):
					if(validhousebuildTimes3(PropertyInfoIndex,1)):
						var housecounter4 = 0
						var samehouse = MGproperty[monopolysettobuild[0]].houses
						for i in monopolysettobuild.size():
							if(MGproperty[monopolysettobuild[i]].houses == samehouse):
								housecounter4 += 1
						if(housecounter4 != monopolysettobuild.size()):
							$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "Number of houses must be equal"
							$Sounds/Invalid.play()
						else:
							if (MGproperty[PropertyInfoIndex].houses == 4 && ((get_node("/root/Global_s").maxhotels - get_node("/root/Global_s").hotelsingame) >= monopolysettobuild.size())):
								player[selector].money -= str2var(bill[1]) * monopolysettobuild.size()
								for n in monopolysettobuild.size():
									get_node("/root/Global_s").HousesPurchased[monopolysettobuild[n]] += 1
									MGproperty[monopolysettobuild[n]].houses += 1
								get_node("/root/Global_s").hotelsetter(monopolysettobuild.size())
								get_node("/root/Global_s").housesetter(-4 * monopolysettobuild.size())
								$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "A hotel has been built on Each"
								$Sounds/ChaChing.play()
							elif(MGproperty[PropertyInfoIndex].houses < 4 && ((get_node("/root/Global_s").maxhouses - get_node("/root/Global_s").housesingame) >= monopolysettobuild.size())):
								player[selector].money -= str2var(bill[1]) * monopolysettobuild.size()
								for n in monopolysettobuild.size():
									get_node("/root/Global_s").HousesPurchased[monopolysettobuild[n]] += 1
									MGproperty[monopolysettobuild[n]].houses += 1
								get_node("/root/Global_s").housesetter(monopolysettobuild.size())
								$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "A house has been built on Each"
								$Sounds/ChaChing.play()
							else:
								$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No housing or at Max"
								$Sounds/Invalid.play()
					else:
						$Sounds/Invalid.play()
						$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "Mortgaged or Even Build Required"
				else:
					$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "Not Enough Money"
					$Sounds/Invalid.play()
			else:
				$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No One Owns this"
				$Sounds/Invalid.play()
		else:
			$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "No Houses can be built here"
			$Sounds/Invalid.play()
	else:
		$Board/CanvasLayer/PropertyProperties/MessageCenter.text = "This Monopoly is not owned"
		$Sounds/Invalid.play()
	UpdatePropertySelectionText()
	UpdatePlayerInfo()


func _on_Railroad1_button_down():
	activateRailroadRule(0)

func _on_Railroad2_button_down():
	activateRailroadRule(1)


func _on_Railroad3_button_down():
	activateRailroadRule(2)


func _on_Pass_button_down():
	$Board/CanvasLayer/RuleVarient.visible = false


func RentDealFromProperty():
	UpdatePropertiesReference()
	if($Board/CanvasLayer/RentDeal.visible):
		$Board/CanvasLayer/RentDeal.visible = false
	else:
		$Board/CanvasLayer/RentDeal.visible = true
	UpdatePlayerInfo()
	$Board/CanvasLayer/RentDeal/RentPropertySlector.value = PropertyInfoIndex
	UpdateRentDealScreen()
