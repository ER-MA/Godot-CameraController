extends Button
class_name Remapper

@export var is_enable: bool = true
@export var input_mapper: InputMapper
@export var rebind_action: String ## 该按钮要重绑定的动作
@export var event_num: int ## 该按钮要绑定的动作的第 num 个事件
@export var cancel_action: String = "ui_cancel" ## 用于取消绑定的动作
@export_group("显示内容")
#下述 display_mode 功能还需要修改文本更新逻辑，暂时懒得做了。
@export_enum("填充", "滞空") var display_mode: int = 0 ## 绑定按键的展示模式：[br]填充：第一个按键取消绑定后，后续按键顺位填充[br]滞空：按键始终显示在被绑定时的按钮上[br]！！！暂时不可用！！！
@export var unbind: String = "未绑定" ## 未绑定按键时按钮显示的文本
@export var wait_input: String = "等待输入" ## 等待输入时按钮显示的文本

static var active_remapper: Remapper = null # 静态变量跟踪当前激活的remapper


func _init() -> void:
	if is_enable:
		self.toggle_mode = true # 设置按钮为切换模式

func _ready() -> void:
	if is_ready():
		input_mapper.ready.connect(update_all_text) # 链接事件更新信号到文本更新函数（使 InputMapper 准备好后再执行初始化）
		input_mapper.action_changed.connect(update_text) # 链接事件更新信号到文本更新函数

func _toggled(toggled_on: bool) -> void:
	if is_enable:
		if toggled_on:
			# 关闭前一个激活的 remapper（防止出现多个按钮被同时激活的情况）
			if Remapper.active_remapper and Remapper.active_remapper != self:
				Remapper.active_remapper._cancel_binding()
			Remapper.active_remapper = self
			grab_focus()  # 确保获得焦点
			text = wait_input
		else:
			if Remapper.active_remapper == self:
				Remapper.active_remapper = null
			release_focus() # 放弃焦点

func _gui_input(event: InputEvent) -> void: # 使用 _gui_input 确保所有键盘事件会优先进入此方法
	if is_enable and rebind_action and InputMap.has_action(rebind_action) and cancel_action:
		if event.is_pressed() and self.button_pressed:
			# 处理输入事件
			
			# 填充模式
			if display_mode == 0:
				if InputMap.action_get_events(rebind_action).size() > event_num: # 若当前按钮对应的事件存在则擦除事件
					InputMap.action_erase_event(rebind_action, InputMap.action_get_events(rebind_action)[event_num]) # 从 action 对应的动作中擦除当前绑定的事件
				if not event.is_action(cancel_action): # 若为取消键则不添加事件
					InputMap.action_add_event(rebind_action, event) # 将接收到的事件添加至 action 对应的动作中
				
			# 滞留模式
			elif display_mode == 1:
				# ！！！无效！！！（InputMap 似乎不会接收空的 InputEvent。想要实现该功能应该还是需要修改文本显示部分的函数）
				var events: Array = InputMap.action_get_events(rebind_action)
				var empty_event: InputEvent = InputEventKey.new()
				# 当事件数量不足时使用空事件扩展数组
				while events.size() <= event_num:
					events.append(empty_event)
				# 替换当前按钮的事件为玩家输入的事件
				if event.is_action(cancel_action):
					events[event_num] = empty_event
				else:
					events[event_num] = event
				# 按顺序重新写入事件到动作
				InputMap.action_erase_events(rebind_action) # 清除动作中的所有事件
				for e in events:
					InputMap.action_add_event(rebind_action, e)
					print(e)
					
			_cancel_binding() # 更新状态
			accept_event() # 阻止事件继续传播


func _cancel_binding():
	if is_enable and input_mapper and rebind_action:
		self.button_pressed = false # 关闭按钮（会触发 _toggle() 函数，并在其中放弃焦点）
		input_mapper.action_changed.emit(rebind_action) # 发出信号，让所有同 action 的按钮更新文本，让 InputMapper 将修改后的按键映射保存到本地（虽然其可能并没有被更改，不过问题不大）


func update_text(action: String) -> void:
	if is_enable and rebind_action:
		if action == rebind_action:
			if InputMap.action_get_events(action).size() > event_num:
				text = InputMap.action_get_events(action)[event_num].as_text()
			else:
				text = unbind
	
func update_all_text() -> void:
	if is_enable and rebind_action:
		update_text(rebind_action)


func is_ready() -> bool:
	# 组件自检
	if not is_enable:
		push_warning("[%s] 此脚本被禁用" % self.get_script().get_global_name())
		return false
		
	if not input_mapper:
		push_error("[%s] 未分配或找到 InputMapper" % self.get_script().get_global_name())
		return false
		
	if not input_mapper.is_ready():
		push_warning("[%s] 依赖的组件 InputMapper 尚未就绪" % self.get_script().get_global_name())
		return false
		
	if not rebind_action:
		push_error("[%s] 未配置该按钮要重绑定的动作" % self.get_script().get_global_name())
		return false
		
	if not InputMap.has_action(rebind_action):
		push_error("[{0}] 输入映射中未找到动作 {1}".format([self.get_script().get_global_name(), rebind_action]))
		return false
		
	if not cancel_action:
		push_error("[%s] 未配置该按钮取消绑定用的动作" % self.get_script().get_global_name())
		return false
		
	return true
