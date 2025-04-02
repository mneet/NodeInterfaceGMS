/// @description Node Manager Create

canvas_collection = [];
canvas_active = noone;
canvas_active_ind = 0;

canvas_exhibiting = [0];
canvas_exhibiting_amnt = 1;
canvas_main = 0;

__last_main_canvas = 0;

__system_started = false;
__active_canvas = true;

__canvas_multiple_animating = false;
__canvas_popup = false;
__canvas_transitioning = false;

#region SYSTEM FUNCTIONS

///@function					__system_define_canvas()
///@description					Define the active canvas and other system variables
__system_define_canvas = function()
{
	if (canvas_active != noone)
	{
		canvas_active.canvas_is_active = false;
	}
	
	var _main_canvas_ind = canvas_exhibiting[canvas_main]; 
	canvas_active = canvas_collection[_main_canvas_ind];
	canvas_active_ind = _main_canvas_ind;
	
	__node_canvas_input_define(id);
	__system_started = true;
	
	canvas_active.canvas_is_active = true;
	canvas_active.node_set_block(false);
	canvas_active.update();
	
	__system_set_canvas_ind_on_nodes(canvas_active, _main_canvas_ind);
}

__system_set_canvas_ind_on_nodes = function(_node, _canvas_ind)
{
	for (var _i = 0; _i < _node.nested_nodes_amnt; _i++)
	{
		var _nested = _node.nested_nodes[_i];
		_nested.__canvas_ind = _canvas_ind;
		
		__system_set_canvas_ind_on_nodes(_nested, _canvas_ind);
	}
}

#endregion

#region Utility Methods

///@function					canvas_change_active(_canvas_ind)
///@description					Change the active canvas to the given index of the canvas_collection array
///@param {real} _canvas_ind	Canvas index 
canvas_change_active = function(_canvas_ind)
{

	if (global.node_manager.__canvas_transitioning) return;
	
	global.node_manager.__canvas_transitioning = true;

	for (var _i = 0; _i < array_length(canvas_exhibiting); _i++)
	{
		if (_i == canvas_main) continue;
		canvas_collection[canvas_exhibiting[_i]].node_call_state(NODE_MOTION_STATE.LEAVE);
	}
	canvas_active.node_call_state(NODE_MOTION_STATE.LEAVE, __canvas_execute_change_active);
	
	
}

///@function					canvas_pop(_canvas_ind)
///@description					Remove the last canvas on the collection
canvas_pop = function()
{
	if (__canvas_multiple_animating || global.node_manager.__canvas_transitioning) return;
	
	__canvas_multiple_animating = true;
	global.node_manager.__canvas_transitioning = true;
	
	canvas_active.node_call_state(NODE_MOTION_STATE.LEAVE, __canvas_execute_pop);
}

canvas_push_new = function(_canvas)
{
	if (__canvas_multiple_animating || __canvas_popup || global.node_manager.__canvas_transitioning) return;
	
	__canvas_popup = true;
	
	array_push(canvas_collection, _canvas);
	var _canvas_ind = array_length(canvas_collection) - 1;
	
	canvas_active.canvas_is_active = false;
	canvas_active.node_set_block(true);
	
	__last_main_canvas = canvas_main;	
	array_push(canvas_exhibiting, _canvas_ind);
	canvas_main = array_length(canvas_exhibiting) - 1;
	canvas_exhibiting_amnt++;
		
	__system_define_canvas();	
}

__canvas_execute_pop = function()
{
	var _canvas_amnt = array_length(canvas_collection);
	if (_canvas_amnt > 0)
	{
		array_pop(canvas_collection);
				
		var _exhibiting_ind = array_get_index(canvas_exhibiting, _canvas_amnt - 1);
		if (_exhibiting_ind != -1)
		{
			array_delete(canvas_exhibiting, _exhibiting_ind, 1);
			canvas_exhibiting_amnt--;
			
			if (_exhibiting_ind == canvas_main)
			{
				canvas_main = __last_main_canvas;				
			}
		}
	}	
	__system_define_canvas();
	
	__canvas_multiple_animating = false;
	__canvas_popup = false;
	global.node_manager.__canvas_transitioning = false;
}

__canvas_execute_change_active = function(_canvas = canvas_active)
{	
	if (__canvas_popup) __canvas_execute_pop();
	
	var _id = variable_clone(global.node_manager.__call_next_canvas_ind);
	if (_id != noone)
	{
		_canvas.node_reset_nested_nodes();
		
		canvas_exhibiting = [_id];
		__system_define_canvas();
				
		with (canvas_active)
		{
			update();
			node_call_state(NODE_MOTION_STATE.ENTER, function ()
			{
				global.node_manager.__canvas_transitioning = false;	
			});
			
			if (!cursor_navigation) nav_select_node(nav_default_path, false);
			if (nav_node_selected != noone)
			{
				input_set_cursor(variable_clone(nav_node_selected.transform.position));
			}
		}
		global.node_manager.__call_next_canvas_ind = noone;
	}
}

#endregion

__node_set_manager_object(id);

