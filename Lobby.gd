extends Control

func _ready():
	get_tree().connect("network_peer_connected",self,"Success")


func _on_Host_button_down():
	var net = NetworkedMultiplayerENet.new()
	net.create_server(4242,10)
	get_tree().network_peer = net


func _on_Join_button_down():
	var net = NetworkedMultiplayerENet.new()
	net.create_client("127.0.0.1",4242)
	get_tree().network_peer = net

func Success(id):
	MultiplayerAutoload.player_ids.append(id)
	if MultiplayerAutoload.player_ids.size() > 1:
		var a = preload("res://MainGame.tscn").instance()
		get_tree().root.add_child(a)
		queue_free()
