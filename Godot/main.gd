extends Control


onready var Furble_Dropper = self.get_node("Path2D/PathFollow2D")
onready var Furble_Dropper_Path = self.get_node("Path2D")
onready var Spawn_Timer = self.get_node("SpawnTimer")
onready var Furble_Root = self.get_node("Furble_Root")
onready var Blood_Root = self.get_node("Blood_Root")
onready var Kill_Count = self.get_node("KillCount")
onready var Timer_Count = self.get_node("TimerCount")
onready var Count_Timer = self.get_node("CountTimer")
onready var Main_Menu = self.get_node("Main_Menu")
onready var Sound_On_BTN = self.get_node("Main_Menu/On")
onready var Sound_Off_BTN = self.get_node("Main_Menu/Off")
onready var Game_Over = self.get_node("Game_Over")
onready var Score_Label = self.get_node("Game_Over/Score")
onready var Screen_Shaker = self.get_node("Camera2D/Screen_Shaker")
onready var Lose_Timer = self.get_node("Lose_Timer")
onready var Lose_Area = self.get_node("Lose_Area")
onready var Warning_Flash = self.get_node("Warning_Flash")
onready var Death_SFX = self.get_node("Death_SFX")
onready var Mouse_Blocker = self.get_node("MouseBlocker")

onready var Furble_Scene = load("res://furble/Furble.tscn")
onready var Blood_Scene = load("res://Blood/Blood.tscn")

export(Image) var mouse_curser
export var speed = 0.5
export var warning_time = 5.0
var time_in_seconds = 0
var killcount = 0
var game_over_anti_clickthrough_cooldown = 2.0
var sound_is_on = true

func _ready():
	Input.set_custom_mouse_cursor(mouse_curser, 0,  Vector2(3.0,20))


func _physics_process(delta):
	var Furbles_in_Lose_Area = self.Lose_Area.get_overlapping_areas()
	if Furbles_in_Lose_Area:
		if self.Lose_Timer.is_stopped():
			#self.Warning_Flash.current_animation = "Warning_Flash"
			#self.Warning_Flash.play()
			self.Lose_Timer.wait_time = warning_time
			self.Lose_Timer.start()
		#self.Warning_Flash.playback_speed = (1.0 / self.Lose_Timer.time_left + 0.01 * 3.0) + 1.0
		var mod_color = (self.Lose_Timer.time_left / self.warning_time)
		self.modulate = Color(1.0, mod_color, mod_color, 1.0)
	else:
		self.Lose_Timer.stop()
		#self.Warning_Flash.stop(true)
		self.modulate = Color(1.0, 1.0, 1.0, 1.0)


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


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()


func on_Furble_killed(furble):
	var size = furble.size
	var shake_duration = 0.3 * size
	var shake_amplitude = 8.0 * size
	self.Screen_Shaker._on_Requested_shake(shake_duration, shake_amplitude)
	var New_Blood = self.Blood_Scene.instance()
	New_Blood.rect_position = furble.position
	New_Blood.rect_scale = Vector2(furble.size, furble.size)
	self.Blood_Root.add_child(New_Blood)
	self.killcount += 1
	self.Kill_Count.text = "Furbles Desimated: " + str(self.killcount)


func start_new_game():
	self.modulate = Color(1.0, 1.0, 1.0, 1.0)
	self.set_physics_process(true)
	self.Game_Over.visible = false
	self.Main_Menu.visible = false
	self.Timer_Count.visible = true
	self.Kill_Count.visible = true
	self.Spawn_Timer.wait_time = 1.0
	self.Spawn_Timer.start()
	self.Count_Timer.start()
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
	self.Sound_Off_BTN.self_modulate = Color(0.73, 0.93, 0.69, 0.5)
	self.Sound_On_BTN.rect_scale = Vector2(1.0, 1.0)
	self.Sound_On_BTN.self_modulate = Color(0.73, 0.93, 0.69, 1.0)


func _on_Off_pressed():
	self.sound_is_on = false
	self.Sound_On_BTN.rect_scale = Vector2(0.7, 0.7)
	self.Sound_On_BTN.self_modulate = Color(0.73, 0.93, 0.69, 0.5)
	self.Sound_Off_BTN.rect_scale = Vector2(1.0, 1.0)
	self.Sound_Off_BTN.self_modulate = Color(0.73, 0.93, 0.69, 1.0)

func clear_all_furbles():
	var Furble_List = self.Furble_Root.get_children()
	for furble in Furble_List:
		furble.queue_free()


func wipe_blood():
	var Blood_List = self.Blood_Root.get_children()
	for blood in Blood_List:
		blood.queue_free()

func _on_Menu_pressed():
	self.Game_Over.visible = false
	self.Main_Menu.visible = true


func _on_Lose_Timer_timeout():
	self.set_physics_process(false)
	self.Spawn_Timer.stop()
	self.Lose_Timer.stop()
	self.Count_Timer.stop()
	self.Mouse_Blocker.mouse_filter = MOUSE_FILTER_STOP
	if self.sound_is_on:
		self.Death_SFX.play()
	else:
		yield(get_tree().create_timer(3.0), "timeout")
		_on_Death_SFX_finished()


func _on_Death_SFX_finished():
	self.clear_all_furbles()
	self.wipe_blood()
	self.modulate = Color(1.0, 1.0, 1.0, 1.0)
	self.Score_Label.text = "You decimated " + str(self.killcount) + " furbles\n in " + str(self.time_in_seconds) + " seconds!"
	self.Game_Over.visible = true
	self.Kill_Count.visible = false
	self.Timer_Count.visible = false
	self.Mouse_Blocker.mouse_filter = MOUSE_FILTER_IGNORE
