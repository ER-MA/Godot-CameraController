extends Button

@export var input_mapper: InputMapper
@export var action: String


func _init() -> void:
	toggle_mode = true

func _ready() -> void:
	set_process_unhandled_input(false)

func _toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	if toggled_on:
		text = "等待输入"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		InputMap.action_erase_events(action) # 从 action 对应的动作中擦除所有已绑定的事件
		InputMap.action_add_event(action, event) # 将接收到的事件添加至 action 对应的动作中
		button_pressed = false
		release_focus() # 放弃焦点
		update_text()
		# 保存修改
		# ...
		# 另一种写法，但是依然感觉没上面这种靠谱
		input_mapper.keymaps[action] = event
		input_mapper.save_keymaps()

func update_text() -> void:
	text = InputMap.action_get_events(action)[0].as_text() # 从 action 对应的动作数组中读取第一个事件，并将其转为文本
