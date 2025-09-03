extends Node2D
class_name Camera2DMouseDragComponent

@export var movement_component: Camera2DMovementComponent
@export var is_enable: bool = false
@export_group("拖拽参数")
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖MovenentComponent中的deceleration_speed）
var _mouse_start_position: Vector2 # 开始拖动时鼠标的位置
var _is_dragging: bool = false


# 物理帧更新
func _physics_process(_delta: float) -> void:
	if is_enable and movement_component:
		
		if _is_dragging:
			movement_component.target_position = movement_component.camera_2d.position + (_mouse_start_position - get_local_mouse_position())


# 输入处理
func _unhandled_input(event: InputEvent) -> void:
	if is_enable and movement_component:
		
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				
				# 鼠标右键被按下时
				if event.pressed:
					movement_component.motion_mode = 0 # 摄像机的运动模式设置为Lerp
					movement_component.deceleration_speed = deceleration_speed # 覆盖插值移动速度
					_mouse_start_position = get_local_mouse_position() # 记录鼠标位置
					
				# 鼠标右键被按下和松开时
				_is_dragging = event.pressed
				#_is_dragging = true if event.pressed else false # 类似三元运算符的另一种写法
