extends Control

var numpep : int
var numprop : int
var playerNameStringOptions = ["Player 0","Player 1","Player 2","Player 3","Player 4","Player 5","Player 6","Player 7","Player 8","Player 9","Player 10","Player 11",]

func _ready():
	$CenterContainer/HBoxContainer/VBoxContainer.add_constant_override("hseparation", 4) 
	$CenterContainer/HBoxContainer.add_constant_override("separation",10)
	initiateNames()

func _physics_process(_delta):
	numpep = $CenterContainer/HBoxContainer/VBoxContainer/numpeople.value
	get_node("/root/Global_s").SetPlayers(numpep)
	$CenterContainer/HBoxContainer/VBoxContainer/PlayerCount.text = var2str(numpep)
	numprop = $CenterContainer/HBoxContainer/VBoxContainer/PropSelector.value
	get_node("/root/Global_s").SetProp(numprop)
	$CenterContainer/HBoxContainer/VBoxContainer/PropCount.text = var2str(numprop)
	get_node("/root/Global_s").setInvestment($CenterContainer/HBoxContainer/VBoxContainer2/InvestmentDeals/EnableInvestment.pressed)
	get_node("/root/Global_s").SetShuffle($CenterContainer/HBoxContainer/VBoxContainer2/Shufflecontainter/ShuffleButton.pressed)
	updateNames()
	get_node("/root/Global_s").updatePlayerName(playerNameStringOptions)
	get_node("/root/Global_s").setRailroad($CenterContainer/HBoxContainer/VBoxContainer2/Railroad/RailroadRuleSelector.pressed)
	get_node("/root/Global_s").setAcution($CenterContainer/HBoxContainer/VBoxContainer2/Auction/Auctionrule.pressed)
	get_node("/root/Global_s").setnoMono($CenterContainer/HBoxContainer/VBoxContainer2/NoMonopolys/NoMonRule.pressed)
	#$get_node("/root/Global_variables").how_many(numpep)
	#$CenterContainer/VBoxContainer/player2.text = var2str(numpep)

func initiateNames():
	$CanvasLayer/Names/VBoxContainer/PlayerName.text = playerNameStringOptions[0]
	$CanvasLayer/Names/VBoxContainer/PlayerName2.text = playerNameStringOptions[1]
	$CanvasLayer/Names/VBoxContainer/PlayerName3.text = playerNameStringOptions[2]
	$CanvasLayer/Names/VBoxContainer/PlayerName4.text = playerNameStringOptions[3]
	$CanvasLayer/Names/VBoxContainer/PlayerName5.text = playerNameStringOptions[4]
	$CanvasLayer/Names/VBoxContainer/PlayerName6.text = playerNameStringOptions[5]
	$CanvasLayer/Names/VBoxContainer2/PlayerName.text = playerNameStringOptions[6]
	$CanvasLayer/Names/VBoxContainer2/PlayerName2.text = playerNameStringOptions[7]
	$CanvasLayer/Names/VBoxContainer2/PlayerName3.text = playerNameStringOptions[8]
	$CanvasLayer/Names/VBoxContainer2/PlayerName4.text = playerNameStringOptions[9]
	$CanvasLayer/Names/VBoxContainer2/PlayerName5.text = playerNameStringOptions[10]
	$CanvasLayer/Names/VBoxContainer2/PlayerName6.text = playerNameStringOptions[11]

func updateNames():
	playerNameStringOptions[0] = $CanvasLayer/Names/VBoxContainer/PlayerName.text
	playerNameStringOptions[1] = $CanvasLayer/Names/VBoxContainer/PlayerName2.text
	playerNameStringOptions[2] = $CanvasLayer/Names/VBoxContainer/PlayerName3.text
	playerNameStringOptions[3] = $CanvasLayer/Names/VBoxContainer/PlayerName4.text
	playerNameStringOptions[4] = $CanvasLayer/Names/VBoxContainer/PlayerName5.text
	playerNameStringOptions[5] = $CanvasLayer/Names/VBoxContainer/PlayerName6.text
	playerNameStringOptions[6] = $CanvasLayer/Names/VBoxContainer2/PlayerName.text
	playerNameStringOptions[7] = $CanvasLayer/Names/VBoxContainer2/PlayerName2.text
	playerNameStringOptions[8] = $CanvasLayer/Names/VBoxContainer2/PlayerName3.text
	playerNameStringOptions[9] = $CanvasLayer/Names/VBoxContainer2/PlayerName4.text
	playerNameStringOptions[10] = $CanvasLayer/Names/VBoxContainer2/PlayerName5.text
	playerNameStringOptions[11] = $CanvasLayer/Names/VBoxContainer2/PlayerName6.text

func _on_Start_pressed():
	get_tree().change_scene("res://Menu.tscn")


func _on_Quit_pressed():
	get_tree().change_scene("res://Menu.tscn")

func Options():
	get_tree().change_scene("res://Options.tscn")

#func _on_numpeople_changed():
#	numpep = $CenterContainer/VBoxContainer/numpeople.value
#	get_node("/root/Global_variables").how_many(numpep)



func info_button():
	get_tree().change_scene("res://info.tscn")




func _on_PropSelector_changed():
	pass # Replace with function body.


func _on_DiceSideSelector_changed():
	get_node("/root/Global_s").SetDice($CenterContainer/HBoxContainer/VBoxContainer2/DiceSides/DiceSideSelector.value)


func _on_DiceSideSelector_value_changed(value):
	var newvalue = floor(value)
	get_node("/root/Global_s").SetDice(newvalue)


func InvestmentToggle(button_pressed):
	get_node("/root/Global_s").setInvestment(button_pressed)


func _on_NameSheet_pressed():
	$CanvasLayer/Names.visible = true


func closeNames():
	$CanvasLayer/Names.visible = false


func _on_RailroadRuleSelector_toggled(button_pressed):
	get_node("/root/Global_s").setRailroad(button_pressed)


func _on_Auctionrule_toggled(button_pressed):
	get_node("/root/Global_s").setAcution(button_pressed)


func _on_NoMonRule_toggled(button_pressed):
	get_node("/root/Global_s").setnoMono(button_pressed)
