function __node_animator() constructor
{
	owner = noone;
	motion_state = NODE_MOTION_STATE.ENTER;
	complete_state_function = noone;
	motion_state_set = false;
	
	restart_anim = false;
	
	ac_enter = new __node_animator_ac_control();
	ac_leave = new __node_animator_ac_control();
	ac_idle = new __node_animator_ac_control();
	
	event_state = [];
	
	#region STATE MACHINE
	
	static state_machine_brain = function(_node)
	{	
		var _animator = _node.animator;		
		_animator.state_trigger(_node, _animator);
		
		switch (_animator.motion_state)
		{
			case NODE_MOTION_STATE.ENTER:
				_animator.state_motion_enter(_node,_animator);
				break;
			
			case NODE_MOTION_STATE.IDLE:
				_animator.state_motion_idle(_node, _animator);
				break;
			
			case NODE_MOTION_STATE.LEAVE:
				_animator.state_motion_leave(_node, _animator);
				break;
			
			case NODE_MOTION_STATE.OUT:
				_animator.state_motion_out(_node, _animator);
				break;
				
			case NODE_MOTION_STATE.RESTART:
				_animator.state_motion_restart(_node, _animator);
				break;
		}
	}
	
	state_motion_enter = function(_node, _animator)
	{
		if (!motion_state_set)
		{
			motion_state_set = true;		
			call_function_when_complete();
			animator_change_state(NODE_MOTION_STATE.IDLE);
		}
	}
	
	state_motion_idle = function(_node, _animator)
	{
		
	}
	
	state_motion_leave = function(_node, _animator)
	{
		if (!motion_state_set)
		{			
			motion_state_set = true;
			call_function_when_complete();			
			if (!restart_anim)
			{
				show_debug_message("OUT");
				animator_change_state(NODE_MOTION_STATE.OUT);
			}
			else 
			{
				show_debug_message("UPDATE");
				owner.update();
				animator_change_state(NODE_MOTION_STATE.ENTER);
			}
		}
	}
	
	state_motion_restart = function(_node, _animator)
	{
		if (!motion_state_set)
		{			
			motion_state_set = true;
			call_function_when_complete();	
			restart_anim = true;
			animator_change_state(NODE_MOTION_STATE.LEAVE);
		}
	}
	
	state_motion_out = function(_node, _animator)
	{		
		if (!motion_state_set)
		{		
			//_node.__skip_render = true;
			motion_state_set = true;				
			call_function_when_complete();
		}
	}
		
	state_trigger = function(_node, _animator)
	{
			
	}
	
	animator_change_state = function(_state, _execute_at_end = noone)
	{
		if (_state != motion_state)
		{
			motion_state = _state;
			motion_state_set = false;
			owner.__skip_render = false;
		
			complete_state_function = _execute_at_end;
			
			__animator_execute_events(_state);
		}
		return self;
	}
	
	call_function_when_complete = function()
	{
		if (complete_state_function != noone)
		{
			complete_state_function();
			complete_state_function = noone;
		}
	}
		
	#endregion	
		
	#region UTILITY
	
	///@function		set_state_motion(_state, _function)
	///@description		Set the behavious for a given state
	static set_state_motion = function (_state, _function)
	{
		switch (_state)
		{
			case NODE_MOTION_STATE.ENTER: state_motion_enter = _function; break;	
			case NODE_MOTION_STATE.IDLE: state_motion_idle = _function; break;	
			case NODE_MOTION_STATE.LEAVE: state_motion_leave = _function; break;	
			case NODE_MOTION_STATE.OUT: state_motion_out = _function; break;	
		}
	}
	
	///@function		set_state_trigger(_function)
	///@description		Set the trigger for new states
	static set_state_trigger = function(_function)
	{
		state_trigger = _function;
		return self;
	}
	
	///@function		set_default_anim_scale(_state, _curve, _channel, _timer_max, _delay)
	static set_default_anim_scale = function(_state, _curve = ac_defaults, _channel = 0, _timer_max = 0.3, _delay = 0)
	{
		switch (_state)
		{
			case NODE_MOTION_STATE.ENTER:
				ac_enter = new __node_animator_ac_control(_curve, _channel, _timer_max, _delay);
				set_state_motion(_state, global.node_animator_db.ac_scale_enter);
				break;
			case NODE_MOTION_STATE.LEAVE:
				ac_leave = new __node_animator_ac_control(_curve, _channel, _timer_max, _delay);
				set_state_motion(_state, global.node_animator_db.ac_scale_leave);
				break;	
		}
	}
	
	///@function		motion_state_compare(_state)
	///@description		Compare the active state
	static motion_state_compare = function(_state)
	{
		return motion_state == _state;	
	}
	
	#endregion
		
	#region EVENT
	
	for (var _i = 0; _i < NODE_MOTION_STATE.LENGTH;	_i++)
	{
		event_state[_i] = [];
	}
	
	static animator_bind_event = function(_state, _event_funct)
	{
		array_push(event_state[_state], _event_funct);
		return self;
	}
	
	static __animator_execute_events = function(_state)
	{
		for (var _i = 0; _i < array_length(event_state[_state]); _i++)
		{
			var _event = event_state[_state][_i];
			if (is_callable(_event)) _event(owner);
		}
	}
	
	#endregion
}

function __node_animator_ac_control(_curve = ac_defaults, _channel = 0, _timer_max = .3, _start_delay = 0) constructor
{
	curve = _curve;
	channel = _channel;
	channel_ind = _channel;
	timer_max = _timer_max;
	
	timer_delay_max = _start_delay
	timer_delay = _start_delay
	
	timer = 0;
	progress = 0;
}

global.node_animator_db = {};
with (global.node_animator_db)
{
	slide_out_left = function(_node, _animator)
	{
		var _x_out = -100;
		_node.transform.position.x = lerp(_node.transform.position.x, _x_out, 0.1);
		_node.update_nested_transform();	
		
		if (abs(_node.transform.position.x - _x_out) < 1)
		{
			_node.transform.position.x = _x_out;
			_animator.animator_change_state(NODE_MOTION_STATE.OUT);	
		}
	}
	
	slide_out_right = function(_node, _animator)
	{
		var _x_out = GUI_WIDTH + 100;
		
		_node.transform.position.x = lerp(_node.transform.position.x, _x_out, 0.02);
		_node.update_nested_transform();	
		
		if (abs(_node.transform.position.x - _x_out) < 1)
		{
			_node.transform.position.x =_node.transform.position.x;
			_animator.animator_change_state(NODE_MOTION_STATE.OUT);	
		}
	}
	
	slide_out_up = function(_node, _animator)
	{
		var  _y_out = -(_node.transform.fixed_size.y + _node.system_origin_offset.x * -1);
		_node.transform.position.y = lerp(_node.transform.position.y, _y_out, 0.1);
		_node.update_nested_transform();	
		
		if (_node.transform.position.y - _y_out < 1)
		{
			_node.transform.position.y = _y_out;
			_animator.animator_change_state(NODE_MOTION_STATE.OUT);	
		}
	}
	
	slide_out_down = function(_node, _animator)
	{
		var  _y_out = GUI_HEIGHT + 50;
		_node.transform.position.y = lerp(_node.transform.position.y, _y_out, 0.1);
		_node.update_nested_transform();	
		
		if (_y_out - _node.transform.position.y < 1)
		{
			_node.transform.position.y = _y_out;
			_animator.animator_change_state(NODE_MOTION_STATE.OUT);	
		}
	}
	
	slide_in_vertical = function(_node, _animator)
	{
		_node.transform.position.y = lerp(_node.transform.position.y, _node.transform.fixed_position.y, 0.1);
		_node.update_nested_transform();	
		
		if (abs(_node.transform.fixed_position.y - _node.transform.position.y) < 1)
		{
			_node.transform.position.y = _node.transform.fixed_position.y;
			_animator.animator_change_state(NODE_MOTION_STATE.IDLE);	
		}
	}
	
	slide_in_horizontal_left = function(_node, _animator)
	{
		_node.transform.position.x = lerp(_node.transform.position.x, _node.transform.fixed_position.x, 0.02);
		_node.update_nested_transform();	
		
		if (abs(_node.transform.position.x - _node.transform.fixed_position.x) < 1)
		{
			_node.transform.position.x =  _node.transform.fixed_position.x;
			_animator.animator_change_state(NODE_MOTION_STATE.IDLE);	
		}
	}
	
	slide_in_horizontal_right = function(_node, _animator)
	{
		_node.transform.position.x = lerp(_node.transform.position.x, _node.transform.fixed_position.x, 0.1);
		_node.update_nested_transform();	
		
		if (abs(_node.transform.position.x - _node.transform.fixed_position.x) < 1)
		{
			_node.transform.position.x =  _node.transform.fixed_position.x;
			_animator.animator_change_state(NODE_MOTION_STATE.IDLE);	
		}
	}
		
	ac_scale_leave = function(_node, _animator)
	{
		with (_animator)
		{
			if (!motion_state_set)
			{
				motion_state_set = true;
			
				ac_leave.progress = 0;
				ac_leave.timer = 0;
				ac_leave.channel = animcurve_get_channel(ac_leave.curve, ac_leave.channel_ind);	
			}		
			
			ac_leave.timer_delay -= delta_time_seconds();
			if (ac_leave.timer_delay <= 0)
			{			
				ac_leave.timer += delta_time_seconds();
				ac_leave.progress = animcurve_channel_evaluate(ac_leave.channel, ac_leave.timer/ ac_leave.timer_max);
			}			
		}
	
		_node.transform.scale.x = _node.transform.fixed_scale.x * (1 - _animator.ac_leave.progress);
		_node.transform.scale.y = _node.transform.fixed_scale.y * (1 - _animator.ac_leave.progress);
		
		_node.update_nested_transform();
		
		if (_animator.ac_leave.timer >= _animator.ac_leave.timer_max)
		{
			_animator.call_function_when_complete();			
			if (!_animator.restart_anim)
			{
				_animator.animator_change_state(NODE_MOTION_STATE.OUT);
			}
			else 
			{
				_animator.owner.update(_animator.owner);
				_animator.restart_anim = false;
				_animator.animator_change_state(NODE_MOTION_STATE.ENTER);
				
			}
		}
	}
	
	ac_scale_enter = function(_node, _animator)
	{
		with (_animator)
		{
			if (!motion_state_set)
			{
				motion_state_set = true;		
				ac_enter.progress = 0;
				ac_enter.timer = 0;
				ac_enter.channel = animcurve_get_channel(ac_enter.curve, ac_enter.channel_ind);		
				
				ac_enter.timer_delay = ac_enter.timer_delay_max;
			}
			
			ac_enter.timer_delay -= delta_time_seconds();
			if (ac_enter.timer_delay <= 0)
			{			
				ac_enter.timer += delta_time_seconds();
				ac_enter.progress = animcurve_channel_evaluate(ac_enter.channel, ac_enter.timer/ ac_enter.timer_max);
			}
		}
		_node.transform.scale.x = _node.transform.fixed_scale.x * _animator.ac_enter.progress;
		_node.transform.scale.y = _node.transform.fixed_scale.y * _animator.ac_enter.progress;
		
		_node.update_nested_transform();
		
		if (_animator.ac_enter.timer >= _animator.ac_enter.timer_max)
		{
			_animator.call_function_when_complete();			
			_animator.animator_change_state(NODE_MOTION_STATE.IDLE);
		}
	}
	
	active_scale_grow = function(_node, _animator)
	{
		if (_node.node_active)
		{
			var _scale_target_x = _node.transform.fixed_scale.x * 1.1,
				_scale_target_y = _node.transform.fixed_scale.y * 1.1;
									
			if (_node.transform.scale.x != _scale_target_x)
			{
				_node.transform.scale.x = lerp(_node.transform.scale.x, _scale_target_x, 0.1);
				_node.transform.scale.y = lerp(_node.transform.scale.y, _scale_target_y , 0.1);

				_node.update_nested_transform();
			}
		}
		else
		{
			if (_node.transform.scale.x != _node.transform.fixed_scale.x)
			{
				_node.transform.scale.x = lerp(_node.transform.scale.x, _node.transform.fixed_scale.x, 0.1);
				_node.transform.scale.y = lerp(_node.transform.scale.y, _node.transform.fixed_scale.y, 0.1);
								
				_node.update_nested_transform();	
			}
		}	
	}
}