extends Node2D

enum GameState {MENU, SERVE, PLAY, GAME_OVER}

const WINNING_SCORE = 3
const DELTA_KEY_RESET = 0.0
const DELTA_KEY_MAX = 0.3

# game variables
var player_score = 0
var ai_score = 0
var is_player_serve = true
var current_game_state = GameState.MENU

# game objects
var player_paddle = Paddle.new()
var ai_paddle = AiPaddle.new()
var ball = Ball.new()

# paddle variables
var paddle_size = Vector2(10.0, 100.0)
var paddle_half_height = paddle_size.y / 2
var paddle_padding = 20.0
var paddle_color = Color.white
var paddle_speed = 300.0

# font variables
var font = DynamicFont.new()
var font_file = load("res://Nunito-Light.ttf")
var font_size = 24
var font_color = Color.white
var font_height
var font_half_width

# ui string variables
var ui_string = ""
var ui_string_position = Vector2.ZERO
var player_score_string
var player_score_string_position = Vector2.ZERO
var ai_score_string
var ai_score_string_position = Vector2.ZERO
var ui_score_position_divider = 3

# serve direction ui variables
var serve_line_length = 60.0
var serve_line_color = Color.yellow

var delta_key = DELTA_KEY_RESET

# screen variables
onready var screen_width = get_tree().get_root().size.x
onready var screen_height = get_tree().get_root().size.y
onready var screen_half_width = screen_width / 2
onready var screen_half_height = screen_height / 2

# ball variables
onready var ball_starting_position = Vector2(screen_half_width, screen_half_height)
onready var ball_starting_speed = Vector2(400.0, 0.0)

# serve direction variables
onready var serve_line_start = ball_starting_position
onready var serve_line_end = serve_line_start + (ball.speed.normalized() * serve_line_length)

# paddle starting positions
onready var player_paddle_starting_position = Vector2(paddle_padding, 
		screen_half_height - paddle_half_height)
onready var ai_paddle_starting_position = Vector2(screen_width - paddle_padding - paddle_size.x, 
		screen_half_height - paddle_half_height)


func _ready():	
	font.font_data = font_file
	font.size = font_size
	font_height = font.get_height()
	
	player_score_string = player_score as String
	player_score_string_position = Vector2(screen_half_width / ui_score_position_divider, font_height)
	
	ai_score_string = ai_score as String
	ai_score_string_position = Vector2(screen_width - screen_half_width / ui_score_position_divider, font_height)
	
	setup_game()


func _physics_process(delta):
	delta_key += delta
	
	player_score_string = player_score as String
	player_score_string_position = Vector2(screen_half_width / ui_score_position_divider, font_height)
	
	ai_score_string = ai_score as String
	ai_score_string_position = Vector2(screen_width - screen_half_width / ui_score_position_divider, font_height)
	
	match current_game_state:
		GameState.MENU:
			change_ui_string("WELCOME TO PONG")
			setup_game()			
			
			if Input.is_key_pressed(KEY_SPACE) and delta_key > 0.3:
				current_game_state = GameState.SERVE
				delta_key = DELTA_KEY_RESET
		GameState.SERVE:
			reset_field()
			
			serve_line_end = serve_line_start + (ball.speed.normalized() * serve_line_length)
			
			if is_player_serve:
				change_ui_string(("Player Serve"))			
			else:
				change_ui_string(("AI Serve"))
			
			# adjust ball launch angle	
			if Input.is_key_pressed(KEY_UP) and delta_key > DELTA_KEY_MAX:
				delta_key = DELTA_KEY_RESET
				ball.speed.y += -50
			if Input.is_key_pressed(KEY_DOWN) and delta_key > DELTA_KEY_MAX:
				delta_key = DELTA_KEY_RESET
				ball.speed.y += 50
			
			if Input.is_key_pressed(KEY_SPACE) and delta_key > DELTA_KEY_MAX:
				current_game_state = GameState.PLAY
				delta_key = DELTA_KEY_RESET
		GameState.PLAY:
			change_ui_string("Play")
			ball.move(delta)
			move_paddles(delta)
			
			check_ceiling_floor_collision()
			check_for_point()
			check_paddle_collision()
					
		GameState.GAME_OVER:
			change_ui_string("Game Over")
			reset_field()
			
			if Input.is_key_pressed(KEY_SPACE) and delta_key > DELTA_KEY_MAX:
				current_game_state = GameState.SERVE
				delta_key = DELTA_KEY_RESET
				setup_game()
	
	update()


func _draw():
	draw_circle(ball.position, ball.radius, ball.color)
	draw_rect(player_paddle.rect, player_paddle.color)
	draw_rect(ai_paddle.rect, ai_paddle.color)
	draw_string(font, ui_string_position, ui_string, font_color)
	draw_string(font, player_score_string_position, player_score_string, font_color)
	draw_string(font, ai_score_string_position, ai_score_string, font_color)
	
	if current_game_state == GameState.SERVE:
		draw_line(serve_line_start, serve_line_end, serve_line_color)


func change_ui_string(new_string):
	ui_string = new_string
	font_half_width = font.get_string_size(ui_string).x / 2
	ui_string_position = Vector2(screen_half_width - font_half_width, font_height)


func setup_game():
	player_score = 0
	ai_score = 0
	
	player_paddle.rect.position = player_paddle_starting_position
	player_paddle.rect.size = paddle_size
	player_paddle.speed = Vector2(0, paddle_speed)
	player_paddle.color = paddle_color
	
	ai_paddle.rect.position = ai_paddle_starting_position
	ai_paddle.rect.size = paddle_size
	ai_paddle.speed = Vector2(0, 200)
	ai_paddle.color = paddle_color
	
	ball.position = ball_starting_position
	ball.speed = ball_starting_speed
	
	is_player_serve = true


func check_paddle_collision():
	# player paddle collision
	if Collision.circle_to_rect(ball.position, ball.radius, player_paddle.rect):
		ball.speed = -ball.speed
		var distance = ball.position.y - (player_paddle.rect.position.y + player_paddle.rect.size.y / 2)
		ball.speed.y = distance * 10
	
	# ai paddle collision
	if Collision.circle_to_rect(ball.position, ball.radius, ai_paddle.rect):
		ball.speed = -ball.speed
		var distance = ball.position.y - (ai_paddle.rect.position.y + ai_paddle.rect.size.y / 2)
		ball.speed.y = distance * 10


func move_paddles(delta):
	# player movement
	if Input.is_key_pressed(KEY_W):
		player_paddle.move(Vector2(0, -1), delta, Vector2(screen_width, screen_height))
	if Input.is_key_pressed(KEY_S):
		player_paddle.move(Vector2(0, 1), delta, Vector2(screen_width, screen_height))
	
	ai_paddle.chase_point(ball.position, delta, Vector2(screen_width, screen_height))


func check_for_point():
	# screen edge collision
	if ball.position.x > screen_width:
		current_game_state = GameState.SERVE
		is_player_serve = false
		player_score  += 1
		ball.speed = -ball_starting_speed
		
		if player_score >= WINNING_SCORE:
			current_game_state = GameState.GAME_OVER
					
	if ball.position.x < 0:
		current_game_state = GameState.SERVE
		is_player_serve = true
		ai_score += 1
		ball.speed = ball_starting_speed
		
		if ai_score >= WINNING_SCORE:
			current_game_state = GameState.GAME_OVER


func check_ceiling_floor_collision():
	if (Collision.point_to_point(ball.position, Vector2(ball.position.x, screen_height)) or
			Collision.point_to_point(ball.position, Vector2(ball.position.x, 0))):
		ball.speed.y = -ball.speed.y


func reset_field():
	player_paddle.rect.position = player_paddle_starting_position
	ai_paddle.rect.position = ai_paddle_starting_position
	ball.position = ball_starting_position
