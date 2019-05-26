extends RigidBody2D

signal killed

onready var Col_Shape = self.get_node("CollisionShape2D")
onready var Furble_Sprite = self.get_node("Sprite")
onready var Scream_SFX = self.get_node("Scream_SFX")
onready var Game_Root = self.get_parent().get_parent()

var _is_moused_over = false

func _ready():
	self.connect("killed", self.Game_Root, "on_Furble_killed")
	
	var new_scale_float = Furble.randf_range(0.5, 1.0)
	self.Scream_SFX.pitch_scale = 1 / new_scale_float
	var new_scale_vec2 = Vector2(new_scale_float, new_scale_float)
	self.Furble_Sprite.scale = new_scale_vec2
	self.Col_Shape.scale = new_scale_vec2
	
	var color_r =  Furble.randf_range(0.8, 1.0)
	var color_g =  Furble.randf_range(0.8, 1.0)
	var color_b =  Furble.randf_range(0.8, 1.0)
	var new_color = Color(color_r, color_g, color_b, 1.0)
	self.Furble_Sprite.self_modulate = new_color

func _input(event):
	if event.is_action_pressed("Furble_Left_Mouse_Button") and self._is_moused_over:
		self.Col_Shape.queue_free()
		self.Furble_Sprite.queue_free()
		self.emit_signal("killed")
		if self.Game_Root.sound_is_on == true:
			self.Scream_SFX.play()
		else:
			self.queue_free()
		


func _on_RigidBody2D_mouse_entered():
	self._is_moused_over = true


func _on_RigidBody2D_mouse_exited():
	self._is_moused_over = false


func _on_AudioStreamPlayer_finished():
	self.queue_free()