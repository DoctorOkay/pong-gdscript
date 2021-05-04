class_name Ball
extends Node2D

var radius = 10.0
var speed = Vector2()
var color = Color.white


func move(speed_scalar):
	self.position = position + speed * speed_scalar
