global.node_manager = {};
with (global.node_manager)
{
	interface_obj = noone;
	prev_interface_obj = noone;
	nav_grid_cell_size = new Vector2(16,16);
	
	block_action = false;
	block_navigation = false;
	
	button_action = false;
	cursor_action = false;
	
	button_active = false;
	
	__cursor_hovering_interface = false;
	
	debug_size = false;
	debug_origin = false;
	
	cursor_navigation = false;
	
	__call_next_canvas_ind = noone;
	
	__reroll_object_function = noone;
	__new_interface_obj = noone;
	__canvas_transitioning = false;
}

function __node_set_manager_object(_obj)
{
	global.node_manager.interface_obj = _obj;
	
	__node_canvas_input_define(_obj);
}

function __node_canvas_input_define(_obj)
{
	with (_obj)
	{
		if (canvas_active != noone)
		{
			global.node_manager.button_action = canvas_active.button_input;
			global.node_manager.cursor_action = canvas_active.cursor_input;
			global.node_manager.cursor_navigation = canvas_active.cursor_navigation;
		}
	}
}

function node_update_all_canvas()
{
	for (var _i = 0; _i < instance_number(obj_node_manager); _i++)
	{
		var _obj = instance_find(obj_node_manager, _i);
		for (var _j = 0; _j < array_length(_obj.canvas_collection); _j++)
		{
			_obj.canvas_collection[_j].update(_obj.canvas_collection[_j]);	
		}
	}
}

function node_check_cursor_navigation()
{
	return global.node_manager.cursor_navigation || input_compare_mode(INPUT_MODE.MOUSE);
}

function node_check_button_input()
{
	return global.node_manager.button_action;
}

function node_block_navigation()
{
	global.node_manager.block_navigation = !global.node_manager.block_navigation;
}	

function node_block_action()
{
	global.node_manager.block_action = !global.node_manager.block_action;
}

function node_block_input()
{
	node_block_navigation();
	node_block_action();
}

function node_unblock_input()
{
	global.node_manager.block_navigation = false;
	global.node_manager.block_action = false;
}	

function node_compare_active_canvas(_canvas_ind)
{
	var _compare = false;
	if (global.node_manager.interface_obj != noone)
	{
		_compare = global.node_manager.interface_obj.canvas_active_ind == _canvas_ind;	
	}
	return _compare
}

function node_change_active_canvas(_canvas_ind)
{
	var _obj = global.node_manager.interface_obj;
	if (instance_exists(_obj) && !node_compare_active_canvas(_canvas_ind))
	{
		global.node_manager.__call_next_canvas_ind = _canvas_ind;
		_obj.canvas_change_active(_canvas_ind);
	}
}

function node_return_last_canvas()
{
	var _canvas_ind =  global.node_manager.interface_obj.__last_main_canvas;	
	node_change_active_canvas(_canvas_ind);
}

function node_get_active_canvas()
{
	var _canvas = noone;
	var _obj = global.node_manager.interface_obj
	if (instance_exists(_obj))
	{		
		_canvas = _obj.canvas_active;
	}
	return _canvas;
}

function node_get_canvas_by_ind(_canvas_ind)
{
	var _canvas = noone;
	var _obj = global.node_manager.interface_obj
	if (instance_exists(_obj))
	{		
		if (_canvas_ind < array_length(_obj.canvas_collection))
		{			
			_canvas = _obj.canvas_collection[_canvas_ind];
		}
	}
	return _canvas;
}

function node_push_new_canvas(_new_canvas)
{
	var _node_manager = node_get_manager_object();
	if (instance_exists(_node_manager))
	{		
		_node_manager.canvas_push_new(_new_canvas);
	}
}

function node_remove_last_canvas()
{
	var _obj = global.node_manager.interface_obj
	if (instance_exists(_obj))
	{		
		_obj.canvas_pop();
	}
}

function node_get_manager_object()
{
	return global.node_manager.interface_obj;
}

function node_update_by_name(_name)
{
	var _manager = node_get_manager_object();
	if (_manager != noone)
	{
		for (var _i = 0; _i < array_length(_manager.canvas_collection); _i++)
		{
			var _canvas = _manager.canvas_collection[_i],
				_node = _canvas.node_find_by_name(_name);
				
			if (_node != noone)
			{
				_node.update();
				break;
			}
		}	
	}
}

function node_is_cursor_over_node()
{
	return global.node_manager.__cursor_hovering_interface;
}

function node_set_button_active(_flag)
{
	global.node_manager.button_active = _flag;	
}

function node_is_button_active()
{
	return global.node_manager.button_active;
}