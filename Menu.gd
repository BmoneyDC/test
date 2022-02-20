extends Control

var numpep : int
var numprop : int

func _ready():
	$CenterContainer/VBoxContainer.add_constant_override("hseparation", 4) 

func _physics_process(_delta):
	pass
	#numpep = $CenterContainer/VBoxContainer/numpeople.value
	#get_node("/root/Global_s").SetPlayers(numpep)
	#numprop = $CenterContainer/VBoxContainer/PropSelector.value
	#get_node("/root/Global_s").SetProp(numprop)
	#$get_node("/root/Global_variables").how_many(numpep)
	#$CenterContainer/VBoxContainer/player2.text = var2str(numpep)

func _on_Start_pressed():
	get_tree().change_scene("res://MainGame.tscn")


func _on_Quit_pressed():
	get_tree().quit()

func Options():
	get_tree().change_scene("res://Options.tscn")

#func _on_numpeople_changed():
#	numpep = $CenterContainer/VBoxContainer/numpeople.value
#	get_node("/root/Global_variables").how_many(numpep)


func _on_CheckButton_toggled(button_pressed):
	if(button_pressed):
		get_node("/root/Global_variables").show_names()
	else:
		get_node("/root/Global_variables").hide_names()


func _on_nameswap2_toggled(button_pressed):
	if(button_pressed):
		get_node("/root/Global_variables").swap_names()
	else:
		get_node("/root/Global_variables").no_swap_names()


func info_button():
	get_tree().change_scene("res://info.tscn")




func _on_PropSelector_changed():
	pass # Replace with function body.
