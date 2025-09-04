extends Node2D
class_name Camera2DKeyboardControllerComponent

@export var controller_component: Camera2DControllerComponent
@export var is_enable: bool = false
@export_group("键盘控制参数")
@export_enum("None", "Lerp", "Smooth") var transition_mode: int = 1 ## 摄像机的运动过度模式：[br]None: 直接移动至目标位置[br]Lerp: 使用 lerp 函数对坐标进行插值[br]Smooth: 使用 move_toward 函数对坐标进行平滑插值
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖 MovenentComponent 中的 position_deceleration_speed）
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var smoothing_speed: float = 500.0 ## 摄像机的平滑移动速度（会覆盖 MovenentComponent 中的 position_smoothing_speed）
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var move_speed: float = 200.0 ## 摄像机的移动速度（px/s）
@export var synchronous_zoom: bool = true # 摄像机的移动距离是否受缩放的影响
var _input_vector: Vector2 # 方向输入
var _position_increment: Vector2 # 相较上一帧鼠标的偏移量
var _camera_zoom: Vector2 # 当前摄像机的缩放倍率


func _ready() -> void:
	# 组件自检
	if not is_enable:
		push_warning("[Camera2DKeyboardControllerComponent] 脚本被禁用")
	elif not controller_component:
		push_error("[Camera2DKeyboardControllerComponent] 未分配或找到 Camera2DControllerComponent")

func _physics_process(delta: float) -> void:
	if is_ready():
		_input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		_position_increment = _input_vector * -1 * move_speed * delta
		
		if synchronous_zoom:
			_camera_zoom = controller_component.get_camera_zoom()
		else:
			_camera_zoom = Vector2.ONE
		
		controller_component.add_target_position(_position_increment / _camera_zoom)
		# 另一种四向四区输入方式：Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))


func _cover_parameter() -> void:
	controller_component.position_transition_mode = transition_mode # 覆盖摄像机的运动模式
	controller_component.position_deceleration_speed = deceleration_speed # 覆盖插值移动速度
	controller_component.position_smoothing_speed = smoothing_speed # 覆盖平滑移动速度


func is_ready() -> bool:
	return is_enable and controller_component and controller_component.is_ready()


# 暂时缺失覆盖参数环节，等输入系统做好了再说
