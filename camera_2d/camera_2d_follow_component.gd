extends Node2D
class_name Camera2DFollowComponent

@export var movement_component: Camera2DMovementComponent
@export var follow_target: Node2D
@export var is_enable: bool = false
@export_group("跟随参数")
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖MovenentComponent中的deceleration_speed）


# 物理帧更新
func _physics_process(_delta: float) -> void:
	if is_enable and movement_component:
		movement_component.target_position = follow_target.position
