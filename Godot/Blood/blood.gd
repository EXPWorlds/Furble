extends Control

onready var Blood_Spray = self.get_node("Blood_Spray")
onready var Blood_Container = self.get_node("CenterContainer")

func _ready():
	randomize()
	var random_angle = randf() * 2 * PI
	self.set_rotation(random_angle)
	self.splat()
	
func splat():
	self.Blood_Container.visible = true
	self.Blood_Spray.play("Spray")

func _on_Blood_Spray_animation_finished(anim_name):
	self.Blood_Spray.stop()
	self.Blood_Container.visible = false
	self.queue_free()
