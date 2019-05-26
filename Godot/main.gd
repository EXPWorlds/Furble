extends Control

onready var Furble_Dropper = self.get_node("Path2D/PathFollow2D")
onready var Furble_Dropper_Path = self.get_node("Path2D")
onready var Spawn_Timer = self.get_node("SpawnTimer")
onready var Furble_Root = self.get_node("Furble_Root")
onready var Kill_Count = self.get_node("KillCount")
onready var Timer_Count = self.get_node("TimerCount")
onready var Main_Menu = self.get_node("Main_Menu")
onready var Sound_On_BTN = self.get_node("Main_Menu/On")
onready var Sound_Off_BTN = self.get_node("Main_Menu/Off")
onready var Game_Over = self.get_node("Game_Over")
onready var Score_Label = self.get_node("Game_Over/Score")

onready var Furble_Scene = load("res://furble/Furble.tscn")

export(Image) var mouse_curser
export var speed = 0.5
var time_in_seconds = 0
var killcount = 0
var sound_is_on = true

func _ready():
	Input.set_custom_mouse_cursor(mouse_curser, 0,  Vector2(32.0, 32.0))


func _on_Timer_timeout():
	self.time_in_seconds += 1 
	self.Timer_Count.text = "Seconds: " + str(self.time_in_seconds)


func _on_SpawnTimer_timeout():
	randomize()
	self.Furble_Dropper.unit_offset = randf()
	randomize()
	var furbles_per_second =  1 + floor(self.time_in_seconds / 20.0)
	var new_wait_time = 1.0 / furbles_per_second + Furble.randf_range(0.0, 0.1)
	self.Spawn_Timer.wait_time = new_wait_time
	var New_Furble = self.Furble_Scene.instance()
	New_Furble.position = self.Furble_Dropper_Path.to_global(self.Furble_Dropper.position)
	self.Furble_Root.add_child(New_Furble)


func _on_Lose_Area_body_entered(body):
	self.Spawn_Timer.stop()
	self.clear_all_furbles()
	self.Score_Label.text = "You decimated " + str(self.killcount) + " furbles\n in " + str(self.time_in_seconds) + " seconds!"
	self.Game_Over.visible = true
	self.Kill_Count.visible = false
	self.Timer_Count.visible = false

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func on_Furble_killed():
	self.killcount += 1
	self.Kill_Count.text = "Furbles Desimated: " + str(self.killcount)


func start_new_game():
	self.Game_Over.visible = false
	self.Main_Menu.visible = false
	self.Timer_Count.visible = true
	self.Kill_Count.visible = true
	self.Spawn_Timer.wait_time = 1.0
	self.Spawn_Timer.start()
	self.killcount = 0
	self.Kill_Count.text = "Furbles Desimated: " + str(self.killcount)
	self.time_in_seconds = 0
	self.Timer_Count.text = "Seconds: " + str(self.time_in_seconds)

func _on_Play_pressed():
	self.start_new_game()


func _on_Quit_pressed():
	get_tree().quit()


func _on_On_pressed():
	self.sound_is_on = true
	self.Sound_Off_BTN.rect_scale = Vector2(0.7, 0.7)
	self.Sound_Off_BTN.self_modulate = Color(0.95, 0.6, 0.6, 0.5)
	self.Sound_On_BTN.rect_scale = Vector2(1.0, 1.0)
	self.Sound_On_BTN.self_modulate = Color(0.95, 0.6, 0.6, 1.0)


func _on_Off_pressed():
	self.sound_is_on = false
	self.Sound_On_BTN.rect_scale = Vector2(0.7, 0.7)
	self.Sound_On_BTN.self_modulate = Color(0.95, 0.6, 0.6, 0.5)
	self.Sound_Off_BTN.rect_scale = Vector2(1.0, 1.0)
	self.Sound_Off_BTN.self_modulate = Color(0.95, 0.6, 0.6, 1.0)

func clear_all_furbles():
	var Furble_List = self.Furble_Root.get_children()
	for furble in Furble_List:
		furble.queue_free()


func _on_Menu_pressed():
	self.Game_Over.visible = false
	self.Main_Menu.visible = true
