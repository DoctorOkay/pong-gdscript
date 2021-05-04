class_name Paddle
extends Node2D

var rect: Rect2
var speed: Vector2
var color


func _init():
	pass
	

func move(direction: Vector2, speed_scalar, screen_size: Vector2):
	var scaled_speed = speed * speed_scalar
	direction = direction.normalized()
	
	rect.position += scaled_speed * direction
	
	rect.position.x = clamp(rect.position.x, 0, screen_size.x - rect.size.x)
	rect.position.y = clamp(rect.position.y, 0, screen_size.y - rect.size.y)


func set_position(position):
	self.rect.position = position
