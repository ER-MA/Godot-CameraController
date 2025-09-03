extends Node2D
class_name Camera2DKeyboardControllerComponent

@export var movement_component: Camera2DMovementComponent
@export var is_enable: bool = false
@export_group("键盘控制参数")
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖MovenentComponent中的deceleration_speed）
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var move_speed: float = 200.0 ## 摄像机的移动速度（px/s）
#var _direction_input_vector: Vector2 # 方向输入


# 物理帧更新
func _physics_process(delta: float) -> void:
	if is_enable and movement_component:
		movement_component.target_position += Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * -1 * move_speed * delta
		# 另一种四向四区输入方式：Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))


# 输入处理
#movement_component.motion_mode = 0 # 摄像机的运动模式设置为Lerp
#movement_component.deceleration_speed = deceleration_speed # 覆盖插值移动速度
