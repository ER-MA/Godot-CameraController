extends Node2D
class_name Camera2DFollowComponent

@export var controller_component: Camera2DControllerComponent
@export var follow_target: Node2D
@export var is_enable: bool = false
var is_running: bool = true
@export_group("跟随参数")
@export_enum("None", "Lerp", "Smooth") var transition_mode: int = 1 ## 摄像机的运动过度模式：[br]None: 直接移动至目标位置[br]Lerp: 使用 lerp 函数对坐标进行插值[br]Smooth: 使用 move_toward 函数对坐标进行平滑插值
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖 MovenentComponent 中的 position_deceleration_speed）
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var smoothing_speed: float = 500.0 ## 摄像机的平滑移动速度（会覆盖 MovenentComponent 中的 position_smoothing_speed）
@export var is_following: bool = true ## 勾选后摄像机将开始跟随目标


func _ready() -> void:
	if is_ready():
		_cover_parameter() # 覆盖参数

func _physics_process(_delta: float) -> void:
	if is_ready() and is_following:
		controller_component.add_target_position(follow_target.position - controller_component.get_camera_position())


func _cover_parameter() -> void:
	controller_component.position_transition_mode = transition_mode # 覆盖摄像机的运动模式
	controller_component.position_deceleration_speed = deceleration_speed # 覆盖插值移动速度
	controller_component.position_smoothing_speed = smoothing_speed # 覆盖平滑移动速度


func start_follow() -> void:
	is_following = true
	
func stop_follow() -> void:
	is_following = false


func is_ready() -> bool:
	# 组件自检
	if not is_enable:
		if is_running:
			push_warning("[%s] 此脚本被禁用" % self.get_script().get_global_name())
			is_running = false
		return false
		
	if not controller_component:
		if is_running:
			push_error("[%s] 未分配或找到 Camera2DControllerComponent" % self.get_script().get_global_name())
			is_running = false
		return false
		
	if not controller_component.is_ready():
		if is_running:
			push_warning("[%s] 依赖的组件 Camera2DControllerComponent 尚未就绪" % self.get_script().get_global_name())
			is_running = false
		return false
		
	if not follow_target:
		if is_running:
			push_error("[%s] 未分配或找到要跟随的节点" % self.get_script().get_global_name())
			is_running = false
		return false
		
	is_running = true
	return true
