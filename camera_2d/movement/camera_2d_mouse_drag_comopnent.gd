extends Node2D
class_name Camera2DMouseDragComponent

@export var controller_component: Camera2DControllerComponent
@export var is_enable: bool = false
@export_group("拖拽参数")
@export_enum("Add", "Set") var control_mode: int = 0 ## 本组件修改摄像机坐标的模式：[br]0: 在摄像机原有坐标基础上 add 偏移量（可能产生累积误差？目前可以忽略不计）[br]1: 直接修改摄像机的坐标（覆盖其他组件对坐标的修改）[br]建议使用模式 0
@export_enum("None", "Lerp", "Smooth") var transition_mode: int = 1 ## 摄像机的运动过度模式：[br]None: 直接移动至目标位置[br]Lerp: 使用 lerp 函数对坐标进行插值[br]Smooth: 使用 move_toward 函数对坐标进行平滑插值
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖 MovenentComponent 中的 position_deceleration_speed）
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var smoothing_speed: float = 500.0 ## 摄像机的平滑移动速度（会覆盖 MovenentComponent 中的 position_smoothing_speed）
var _camera_start_position: Vector2 # 开始拖动时摄像机的位置
var _camera_zoom: Vector2 # 当前摄像机的缩放倍率
var _mouse_start_viewport_position: Vector2 # 开始拖动时鼠标的位置
var _mouse_prev_viewport_position: Vector2 # 上一帧时鼠标的位置
var _mouse_current_viewport_position: Vector2 # 当前鼠标位置
var _mouse_delta_viewport_position: Vector2 # 相较上一帧鼠标的偏移量
var _is_dragging: bool = false


func _ready() -> void:
	# 组件自检
	if not is_enable:
		push_warning("[Camera2DMouseDragComponent] 脚本被禁用")
	elif not controller_component:
		push_error("[Camera2DMouseDragComponent] 未分配或找到 Camera2DControllerComponent")

func _physics_process(_delta: float) -> void:
	if is_ready():
		
		if _is_dragging:
			if control_mode == 0:
				_mouse_current_viewport_position = get_viewport().get_mouse_position()
				_mouse_delta_viewport_position = _mouse_prev_viewport_position - _mouse_current_viewport_position
				_camera_zoom = controller_component.get_camera_zoom()
				controller_component.add_target_position(_mouse_delta_viewport_position / _camera_zoom)
				_mouse_prev_viewport_position = get_viewport().get_mouse_position()
			elif control_mode == 1:
				_mouse_current_viewport_position = get_viewport().get_mouse_position()
				_camera_zoom = controller_component.get_camera_zoom()
				controller_component.target_position = _camera_start_position + (_mouse_start_viewport_position - _mouse_current_viewport_position) / _camera_zoom

func _unhandled_input(event: InputEvent) -> void:
	if is_ready():
		
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				
				# 鼠标右键被按下时
				if event.pressed:
					_cover_parameter() # 覆盖
					if control_mode == 0:
						_mouse_prev_viewport_position = get_viewport().get_mouse_position()
					elif control_mode == 1:
						_mouse_start_viewport_position = get_viewport().get_mouse_position() # 记录鼠标在视口中的起始位置
						_camera_start_position = controller_component.get_camera_position() # 记录摄像机的起始位置
					
				# 鼠标右键被按下和松开时
				_is_dragging = true if event.pressed else false # 类似三元运算符的另一种写法（与 `_is_dragging = event.pressed` 等效）


func _cover_parameter() -> void:
	controller_component.position_transition_mode = transition_mode # 覆盖摄像机的运动模式
	controller_component.position_deceleration_speed = deceleration_speed # 覆盖插值移动速度
	controller_component.position_smoothing_speed = smoothing_speed # 覆盖平滑移动速度


func is_ready() -> bool:
	return is_enable and controller_component and controller_component.is_ready()
