extends AnimatedSprite2D

@export var mode7_sprite: Mode7Sprite2D
@export var sky_texture: Sprite2D

@export var speed: float = 1500
@export var turn_speed: float = 55
@export var climb_speed: float = 165

@export var airship_upper_bound_y :int = 150
@export var airship_lower_bound_y :int = 400

# Note this is geared towards using Projeciton as interpolation mode, which will only work on 2 scanline override elements
@export var ground_height_scale_x_min :float = 0.01	# Will apply to the 2nd scanline override element
# Note the absence of a "max" for this.
# A good max is a little less than the 1st (0-indexed) scanline element scale x.  Setting the 2nd element scale x higher will
# make the "ground" look like it's projecting backwards.


func _physics_process(delta: float) -> void:
	var turn_input := Input.get_action_strength("right") - Input.get_action_strength("left")
	var climb_input := Input.get_action_strength("up") -  Input.get_action_strength("down")
	var forward_input := Input.get_action_strength("decelerate") - Input.get_action_strength("accelerate")
	
	# Airship moves up or down within a set range - keeps it on the screen
	# Remember Y coordinates increase as they go down the screen
	if (position.y < airship_lower_bound_y and climb_input > 0):
		position.y += climb_input * delta * climb_speed
	elif (position.y > airship_upper_bound_y and climb_input < 0):
		position.y += climb_input * delta * climb_speed
		
	# Index 1 - so the 2nd scanline override element in the array
	# The X scale (in projection mode) largely has the effect of making it look closer to/farther from the ground
	
	# Pressing "down"/D
	if (mode7_sprite.mode7_scanline_overrides[1].scale.x < mode7_sprite.mode7_scanline_overrides[0].scale.x and climb_input < 0):
		mode7_sprite.mode7_scanline_overrides[1].scale.x += delta
	# Pressing "up"/W
	elif (mode7_sprite.mode7_scanline_overrides[1].scale.x > ground_height_scale_x_min and climb_input > 0):
		mode7_sprite.mode7_scanline_overrides[1].scale.x -= delta

	# Tilt horizon with turnww
	mode7_sprite.mode7_top_horizon_tilt = turn_input * -1

	mode7_sprite.mode7_global_rotation = wrapf(
		mode7_sprite.mode7_global_rotation + turn_input * turn_speed * delta,
		-360.0,
		360.0
	)

	# parallax horizontally based on turn input
	var parallax_layer = sky_texture.get_parent()
	var parallax_scroll_rate = turn_input * turn_speed * 12 * delta * -1
	parallax_layer.manual_scroll.x += parallax_scroll_rate

	if forward_input != 0.0:
		var forward_dir := Vector2.DOWN.rotated(deg_to_rad(mode7_sprite.mode7_global_rotation))   
		$%AirshipPosition.position += forward_dir * forward_input * speed * delta
		
		$Wheel/AnimationPlayer.play("Wheel_Accelerate")
	else:
		$Wheel/AnimationPlayer.play("Wheel_Idle")
		
	if turn_input == 0:
		play("default")
	elif turn_input < 0:
		play("turn_left")
	elif turn_input > 0:
		play("turn_right")
		

		
		
	
