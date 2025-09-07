extends Button

@export var input_mapper: InputMapper
@export var action: String ## 操作的动作
@export var event_num: int ## 操作动作的第 num 个事件


func _init() -> void:
	toggle_mode = true # 设置按钮为切换模式
	
func _ready() -> void:
	update_text() # 更新文本（权宜之计，需要确保InputMapper比这里更早读取本地按键映射）

func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		grab_focus()  # 确保获得焦点
		text = "等待输入"
	else:
		release_focus() # 放弃焦点

func _gui_input(event: InputEvent) -> void: # 使用 _gui_input 确保所有键盘事件会优先进入此方法
	if event.is_pressed() and button_pressed:
		# 处理输入事件
		InputMap.action_erase_events(action) # 从 action 对应的动作中擦除所有已绑定的事件
		InputMap.action_add_event(action, event) # 将接收到的事件添加至 action 对应的动作中
		# 更新状态
		button_pressed = false # 关闭按钮（在 _toggle() 函数中会自动放弃焦点）
		update_text() # 更新文本
		input_mapper.save_keymaps() # 保存修改
		# 阻止事件继续传播
		accept_event()

func update_text() -> void:
	var events = InputMap.action_get_events(action)
	if events.size() > event_num:
		text = events[event_num].as_text()
	else:
		text = "未绑定"
