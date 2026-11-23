extends VehicleBody3D

@export var engine_force_max: float = 1800.0
@export var brake_force_max: float = 32.0
@export var steering_limit: float = 0.42
@export var steering_speed: float = 2.4

func _physics_process(delta: float) -> void:
    var gas := Input.get_action_strength("accelerate")
    var brake_input := Input.get_action_strength("brake")
    var steer_input := Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
    # Simple automatic forward/reverse behavior for the prototype.
    if gas > 0.05:
        engine_force = gas * engine_force_max
        brake = 0.0
    elif brake_input > 0.05 and linear_velocity.length() < 1.2:
        engine_force = -brake_input * engine_force_max * 0.55
        brake = 0.0
    else:
        engine_force = 0.0
        brake = brake_input * brake_force_max
    steering = move_toward(steering, steer_input * steering_limit, steering_speed * delta)
    if Input.is_action_just_pressed("camera_switch"):
        var follow := get_node("CameraArm/FollowCamera") as Camera3D
        var cabin := get_node("CabinCamera") as Camera3D
        cabin.current = follow.current
        follow.current = not cabin.current
