extends Node3D

const CarScript = preload("res://scripts/car.gd")
var car: VehicleBody3D
var camera_label: Label

func _ready() -> void:
    _make_environment()
    _make_city()
    _make_car()
    _make_hud()

func _make_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.72, 0.78, 0.88)
    env.ambient_light_energy = 0.75
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world.environment = env
    add_child(world)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -25, 0)
    sun.light_energy = 1.15
    sun.shadow_enabled = true
    add_child(sun)

func _make_city() -> void:
    _box("Ground", Vector3(0,-0.7,0), Vector3(260,1,260), Color("#65765b"), true)
    _box("Road", Vector3(0,-0.12,0), Vector3(18,0.18,220), Color("#292d32"), true)
    _box("SidewalkLeft", Vector3(-10.8,0.02,0), Vector3(3.4,0.32,220), Color("#a4a39b"), true)
    _box("SidewalkRight", Vector3(10.8,0.02,0), Vector3(3.4,0.32,220), Color("#a4a39b"), true)
    for z in range(-100, 110, 12):
        _box("LaneMark", Vector3(0,-0.015,z), Vector3(0.18,0.025,5.2), Color("#eee6c9"), false)
    var rng := RandomNumberGenerator.new()
    rng.seed = 2047
    for side in [-1, 1]:
        for i in range(10):
            var h := rng.randf_range(8.0, 23.0)
            var w := rng.randf_range(9.0, 15.0)
            var d := rng.randf_range(10.0, 17.0)
            var x := side * rng.randf_range(19.0, 29.0)
            var z := -95.0 + i * 21.0
            var color := [Color("#d7c9ad"), Color("#c9bda8"), Color("#b7c2bd"), Color("#d5d0c1")][rng.randi_range(0,3)]
            _box("DushanbeBuilding", Vector3(x,h/2,z), Vector3(w,h,d), color, true)
            _box("Roof", Vector3(x,h+0.15,z), Vector3(w+0.3,0.3,d+0.3), Color("#77766e"), true)
            for floor_i in range(1, int(h/3.2)):
                for win in range(2):
                    var wx := x + (float(win)-0.5)*w*0.38
                    _box("Window", Vector3(wx, floor_i*3.1+1.4,z-d/2-0.03), Vector3(1.25,1.35,0.08), Color("#52758a"), false)
    # Distant low hills give the skyline a sense of place.
    for i in range(9):
        var hill := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        mesh.radius = 1
        mesh.height = 2
        hill.mesh = mesh
        hill.scale = Vector3(20, rng.randf_range(5,11), 14)
        hill.position = Vector3(-100+i*25, 3, -125)
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color("#7d927b")
        hill.material_override = mat
        add_child(hill)

func _make_car() -> void:
    car = VehicleBody3D.new()
    car.name = "BMW_E39_Prototype"
    car.mass = 1450.0
    car.position = Vector3(0, 1.1, 0)
    car.script = CarScript
    add_child(car)
    var body_shape := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.82, 0.65, 4.55)
    body_shape.shape = shape
    body_shape.position = Vector3(0, 0.12, 0)
    car.add_child(body_shape)
    _make_car_visuals()
    _make_wheel("FrontLeft", Vector3(-0.98,-0.28,-1.42), true, false)
    _make_wheel("FrontRight", Vector3(0.98,-0.28,-1.42), true, false)
    _make_wheel("RearLeft", Vector3(-0.98,-0.28,1.42), false, true)
    _make_wheel("RearRight", Vector3(0.98,-0.28,1.42), false, true)
    var spring := SpringArm3D.new()
    spring.name = "CameraArm"
    spring.spring_length = 7.0
    spring.position = Vector3(0, 2.2, 0.4)
    spring.rotation_degrees = Vector3(-12, 0, 0)
    spring.margin = 0.2
    car.add_child(spring)
    var cam := Camera3D.new()
    cam.name = "FollowCamera"
    cam.current = true
    spring.add_child(cam)
    var cabin := Camera3D.new()
    cabin.name = "CabinCamera"
    cabin.position = Vector3(0, 1.0, -0.35)
    cabin.current = false
    car.add_child(cabin)

func _make_car_visuals() -> void:
    _car_box("LowerBody", Vector3(0,0.1,0), Vector3(1.85,0.55,4.35), Color("#263c55"))
    _car_box("Cabin", Vector3(0,0.68,0.15), Vector3(1.58,0.72,2.25), Color("#25313b"))
    _car_box("Hood", Vector3(0,0.42,-1.42), Vector3(1.78,0.18,1.25), Color("#304e6c"))
    _car_box("Trunk", Vector3(0,0.42,1.65), Vector3(1.78,0.2,0.85), Color("#304e6c"))
    _car_box("FrontBumper", Vector3(0,-0.03,-2.2), Vector3(1.9,0.22,0.18), Color("#171b20"))
    _car_box("RearBumper", Vector3(0,-0.03,2.2), Vector3(1.9,0.22,0.18), Color("#171b20"))
    _car_box("FrontGlass", Vector3(0,0.78,-0.72), Vector3(1.45,0.5,0.07), Color("#7293a5"))
    _car_box("RearGlass", Vector3(0,0.78,1.18), Vector3(1.45,0.48,0.07), Color("#7293a5"))
    for x in [-0.91, 0.91]:
        _car_box("Headlight", Vector3(x,0.25,-2.22), Vector3(0.38,0.22,0.05), Color("#f4e7bb"))
        _car_box("Taillight", Vector3(x,0.25,2.22), Vector3(0.35,0.2,0.05), Color("#9d2525"))

func _car_box(n: String, p: Vector3, s: Vector3, color: Color) -> void:
    var mi := MeshInstance3D.new()
    mi.name = n
    var mesh := BoxMesh.new()
    mesh.size = s
    mi.mesh = mesh
    mi.position = p
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.35
    mat.roughness = 0.32
    mi.material_override = mat
    car.add_child(mi)

func _make_wheel(n: String, p: Vector3, steering: bool, traction: bool) -> void:
    var wheel := VehicleWheel3D.new()
    wheel.name = n
    wheel.position = p
    wheel.use_as_steering = steering
    wheel.use_as_traction = traction
    wheel.wheel_radius = 0.36
    wheel.wheel_rest_length = 0.16
    wheel.suspension_stiffness = 28.0
    wheel.suspension_max_force = 6000.0
    wheel.damping_compression = 0.8
    wheel.damping_relaxation = 0.9
    wheel.friction_slip = 3.0
    car.add_child(wheel)
    var tire := MeshInstance3D.new()
    var cyl := CylinderMesh.new()
    cyl.top_radius = 0.36
    cyl.bottom_radius = 0.36
    cyl.height = 0.24
    tire.mesh = cyl
    tire.rotation_degrees.z = 90
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#17191c")
    tire.material_override = mat
    wheel.add_child(tire)

func _box(n: String, p: Vector3, s: Vector3, color: Color, solid: bool) -> void:
    var parent: Node3D = StaticBody3D.new() if solid else Node3D.new()
    parent.name = n
    parent.position = p
    add_child(parent)
    var mi := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = s
    mi.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mi.material_override = mat
    parent.add_child(mi)
    if solid:
        var cs := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = s
        cs.shape = box_shape
        parent.add_child(cs)

func _make_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(18, 16)
    panel.add_theme_stylebox_override("panel", _panel_style())
    layer.add_child(panel)
    var info := VBoxContainer.new()
    info.add_theme_constant_override("separation", 3)
    panel.add_child(info)
    var title := Label.new()
    title.text = "CAR LIFE  /  DUSHANBE DISTRICT 01"
    title.add_theme_font_size_override("font_size", 22)
    info.add_child(title)
    var help := Label.new()
    help.text = "WASD / touch controls  •  C: camera"
    help.add_theme_font_size_override("font_size", 15)
    info.add_child(help)
    var controls := HBoxContainer.new()
    controls.anchor_left = 0.0
    controls.anchor_top = 1.0
    controls.anchor_right = 1.0
    controls.anchor_bottom = 1.0
    controls.offset_left = 22
    controls.offset_top = -112
    controls.offset_right = -22
    controls.offset_bottom = -18
    controls.add_theme_constant_override("separation", 14)
    layer.add_child(controls)
    _add_hold_button(controls, "◀", "steer_left")
    _add_hold_button(controls, "▶", "steer_right")
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_child(spacer)
    _add_hold_button(controls, "BRAKE", "brake")
    _add_hold_button(controls, "DRIVE", "accelerate")
    var cam_button := Button.new()
    cam_button.text = "CAM"
    cam_button.custom_minimum_size = Vector2(90, 76)
    cam_button.pressed.connect(_switch_camera)
    controls.add_child(cam_button)

func _add_hold_button(parent: HBoxContainer, caption: String, action: String) -> void:
    var b := Button.new()
    b.text = caption
    b.custom_minimum_size = Vector2(86, 76)
    b.add_theme_font_size_override("font_size", 20)
    b.button_down.connect(func(): Input.action_press(action))
    b.button_up.connect(func(): Input.action_release(action))
    parent.add_child(b)

func _switch_camera() -> void:
    var follow := car.get_node("CameraArm/FollowCamera") as Camera3D
    var cabin := car.get_node("CabinCamera") as Camera3D
    cabin.current = follow.current
    follow.current = not cabin.current

func _panel_style() -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = Color(0.04,0.06,0.08,0.72)
    s.set_corner_radius_all(10)
    s.content_margin_left = 14
    s.content_margin_right = 14
    s.content_margin_top = 9
    s.content_margin_bottom = 9
    return s
