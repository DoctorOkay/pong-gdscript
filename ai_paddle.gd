class_name AiPaddle
extends Paddle

var chase_tolerance = 50

func chase_point(point: Vector2, speed_scalar, screen_size: Vector2):
	if point.y > rect.position.y + (rect.size.y / 2 + chase_tolerance):
		move(Vector2.DOWN, speed_scalar, screen_size)
	if point.y < rect.position.y + (rect.size.y / 2 - chase_tolerance):
		move(Vector2.UP, speed_scalar, screen_size)
