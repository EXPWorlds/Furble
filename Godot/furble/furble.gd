extends RigidBody2D

signal killed(furble)

onready var Col_Shape = self.get_node("CollisionShape2D")
onready var Pick_Shape = self.get_node("PickArea")
onready var Force_Field = self.get_node("ForceField")
onready var Furble_Sprite = self.get_node("Sprite")
onready var Scream_SFX = self.get_node("Scream_SFX")
onready var Game_Root = self.get_parent().get_parent()

var _blood_duration = 0.3
var size = 1.0
var expolosion_force = 250.0

func _ready():
	self.connect("killed", self.Game_Root, "on_Furble_killed")
	
	var new_scale_float = Furble.randf_range(0.5, 1.0)
	self.size = new_scale_float
	self.Scream_SFX.pitch_scale = 1 / new_scale_float
	var new_scale_vec2 = Vector2(new_scale_float, new_scale_float)
	self.Furble_Sprite.scale = new_scale_vec2
	self.Col_Shape.scale = new_scale_vec2
	self.Pick_Shape.scale = new_scale_vec2
	self.Force_Field.scale = new_scale_vec2
	
	var color_r =  Furble.randf_range(0.8, 1.0)
	var color_g =  Furble.randf_range(0.8, 1.0)
	var color_b =  Furble.randf_range(0.8, 1.0)
	var new_color = Color(color_r, color_g, color_b, 1.0)
	self.Furble_Sprite.self_modulate = new_color


func _on_AudioStreamPlayer_finished():
	self.queue_free()


func _on_Area2D_input_event(viewport, event, shape_idx):
		if event.is_pressed():
			self.apply_explosion_force()
			self.Col_Shape.queue_free()
			self.Pick_Shape.queue_free()
			self.Furble_Sprite.queue_free()
			self.Force_Field.queue_free()
			self.gravity_scale = 0
			self.linear_velocity = Vector2(0.0, 0.0)
			self.emit_signal("killed", self)
			if self.Game_Root.sound_is_on == true:
				self.Scream_SFX.play()
			else:
				self.queue_free()


func apply_explosion_force():
	var furble_list = self.Force_Field.get_overlapping_bodies()
	for furble in furble_list:
		if not furble.is_class("RigidBody2D"):
			continue
		var force_vector = furble.position - self.position
		force_vector = force_vector.normalized()
		force_vector = force_vector * self.expolosion_force * self.size
		furble.linear_velocity += force_vector