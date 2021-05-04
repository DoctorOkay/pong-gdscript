class_name Collision
extends Resource

const POINT_BUFFER = 10

static func point_to_point(point_a: Vector2, point_b: Vector2) -> bool:
	var buffer = POINT_BUFFER
	return circle_to_circle(point_a, buffer, point_b, buffer)


static func point_to_circle(point: Vector2, center: Vector2, radius) -> bool:
	var distance_vector = point - center
	var distance = sqrt((distance_vector.x * distance_vector.x) + (distance_vector.y * distance_vector.y))
	
	return distance <= radius


static func point_to_rect(point: Vector2, rect: Rect2) -> bool:
	var left_edge = rect.position.x
	var right_edge = rect.position.x + rect.size.x
	var top_edge = rect.position.y
	var bottom_edge = rect.position.y + rect.size.y
	
	return point.x >= left_edge and point.x <= right_edge and point.y >= top_edge and point.y <= bottom_edge


static func circle_to_circle(center_a: Vector2, radius_a, center_b: Vector2, radius_b) -> bool:
	var center_distance_vector = center_a - center_b
	var center_distance = sqrt((center_distance_vector.x * center_distance_vector.x) +
			(center_distance_vector.y * center_distance_vector.y))
	var combined_radius = radius_a + radius_b
	return center_distance <= combined_radius


static func circle_to_rect(center: Vector2, radius, rect: Rect2) -> bool:
	var test_point = center
	
	if center.x < rect.position.x:
		test_point.x = rect.position.x
	elif center.x > rect.position.x + rect.size.x:
		test_point.x = rect.position.x + rect.size.x
		
	if center.y < rect.position.y:
		test_point.y = rect.position.y
	elif center.y > rect.position.y + rect.size.y:
		test_point.y = rect.position.y + rect.size.y
		
	return point_to_circle(test_point, center, radius)
