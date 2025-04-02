///@function						node_canvas(_name, _origin)
///@description						Create an canvas node to start an interface 
///@param {string} _name			Name used for identify the node
///@param {real} [_origin]			Determines the anchor point of the node using NODE_ORIGIN enum
function node_canvas(_name, _origin = NODE_ORIGIN.MIDDLE_CENTER) : Node(_name,_origin) constructor
{
	add_component_renderer();
	add_component_processor();
		
	#region Navigation Brain
	
	canvas_is_active = false;
	
	nav_position = new Vector2(0,0);
	nav_node_selected = noone;
	nav_default_path = noone;
	
	button_input = true;
	cursor_input = true;
	cursor_navigation = false;
	
	__grid_initiated = false;
	__bt_selected_this_frame = false;
	
	///@function					nav_select_node(_path, _play_sound)
	///@description					Select an given node 
	///@param {string} _path		Node path to be selected
	///@param {bool} _play_sound	IF the selection sound should be played
	static nav_select_node = function(_path, _play_sound = true)
	{
		if (__bt_selected_this_frame) return;
		
		if (!is_array(_path)) return;
		
		if (nav_node_selected != noone)
		{
			nav_node_selected.navigator.select_node();
		}
		nav_node_selected = node_find_by_path(_path);
		if (nav_node_selected != noone)
		{
			nav_node_selected.navigator.select_node(_play_sound);
			nav_position = variable_clone(nav_node_selected.transform.position);
			if (!input_compare_mode(INPUT_MODE.MOUSE) && !cursor_navigation)
			{
				input_set_cursor(variable_clone(nav_node_selected.transform.position));
			}
			__bt_selected_this_frame = true;
		}
	}
	
	///@function					nav_deselect_node()
	///@description					Remove the navigation selection from the current select node
	static nav_deselect_node = function()
	{
		if (nav_node_selected != noone)
		{
			nav_node_selected.navigator.select_node();
		}
		nav_node_selected = noone;
	}
		
	#region NAV SEARCH
		
	static __nav_find_neighbor_right = function(_cells, _cell_a)
	{
		// Find "right" neighbor for button A
		var _neighbor_right = noone;
		var _closest_distance = infinity;
		
		for (var _i = 0; _i < array_length(_cells); _i++) 
		{
			var _cell_b = _cells[_i];			
			if (_cell_b == _cell_a) continue;
			
			// Check if B is to the right of A (with some vertical tolerance)
			if (_cell_b.x > _cell_a.x && abs(_cell_b.y - _cell_a.y) < 10) 
			{
				var _dist = point_distance(_cell_a.x, _cell_a.y, _cell_b.x, _cell_b.y);
				if (_dist < _closest_distance) {
				  _neighbor_right = _cell_b;
				  _closest_distance = _dist;
				}
			}
		}
		return _neighbor_right;
	}
	
	static __nav_find_neighbor_left = function(_cells, _cell_a)
	{
		// Find "right" neighbor for button A
		var _neighbor_right = noone;
		var _closest_distance = infinity;
		
		for (var _i = 0; _i < array_length(_cells); _i++) 
		{
			var _cell_b = _cells[_i];			
			if (_cell_b == _cell_a) continue;
			
			// Check if B is to the right of A (with some vertical tolerance)
			if (_cell_b.x < _cell_a.x && abs(_cell_b.y - _cell_a.y) < 10) 
			{
				var _dist = point_distance(_cell_a.x, _cell_a.y, _cell_b.x, _cell_b.y);
				if (_dist < _closest_distance) {
				  _neighbor_right = _cell_b;
				  _closest_distance = _dist;
				}
			}
		}
		return _neighbor_right;
	}
	
	static __nav_find_neighbor_up = function(_cells, _cell_a)
	{
		// Find "right" neighbor for button A
		var _neighbor_right = noone;
		var _closest_distance = infinity;
		
		for (var _i = 0; _i < array_length(_cells); _i++) 
		{
			var _cell_b = _cells[_i];			
			if (_cell_b == _cell_a) continue;
			
			// Check if B is to the right of A (with some vertical tolerance)
			if (_cell_b.y < _cell_a.y && abs(_cell_b.x - _cell_a.x) < 10) 
			{
				var _dist = point_distance(_cell_a.x, _cell_a.y, _cell_b.x, _cell_b.y);
				if (_dist < _closest_distance) {
				  _neighbor_right = _cell_b;
				  _closest_distance = _dist;
				}
			}
		}
		return _neighbor_right;
	}
	
	static __nav_find_neighbor_down = function(_cells, _cell_a)
	{
		// Find "right" neighbor for button A
		var _neighbor_right = noone;
		var _closest_distance = infinity;
		
		for (var _i = 0; _i < array_length(_cells); _i++) 
		{
			var _cell_b = _cells[_i];			
			if (_cell_b == _cell_a) continue;
			
			// Check if B is to the right of A (with some vertical tolerance)
			if (_cell_b.y > _cell_a.y && abs(_cell_b.x - _cell_a.x) < 10) 
			{
				var _dist = point_distance(_cell_a.x, _cell_a.y, _cell_b.x, _cell_b.y);
				if (_dist < _closest_distance) {
				  _neighbor_right = _cell_b;
				  _closest_distance = _dist;
				}
			}
		}
		return _neighbor_right;
	}
	
	#endregion
	
	///@function					__nav_build_navigations()
	///@description					Run system functions to build navigation grid
	static __nav_build_navigations = function()
	{		
		var _path_cells = __get_navigation_paths();
		for (var _i = 0; _i < array_length(_path_cells); _i++)
		{
			var _cell = _path_cells[_i],
				_node = node_find_by_path(_cell.path);
			
			var _path_up = __nav_find_neighbor_up(_path_cells, _cell);
			var _path_down = __nav_find_neighbor_down(_path_cells, _cell);
			var _path_left = __nav_find_neighbor_left(_path_cells, _cell);					
			var _path_right = __nav_find_neighbor_right(_path_cells, _cell);					
					
			if (_path_up != noone)		_node.navigator.set_directions("up", _path_up.path);
			if (_path_down != noone)	_node.navigator.set_directions("down", _path_down.path);
			if (_path_left != noone)	_node.navigator.set_directions("left", _path_left.path);
			if (_path_right != noone)	_node.navigator.set_directions("right", _path_right.path);
		}
		
		if (nav_default_path == noone && array_length(_path_cells) > 0) nav_default_path = _path_cells[0].path;
	}
	
	#endregion
	
	#region INPUT
	
	///@function					__nav_input_manager()
	///@description					Handles grid input navigation
	__nav_input_manager = function(_canvas)
	{
		if (global.node_manager.block_navigation || !_canvas.button_input || !_canvas.canvas_is_active) return;
		
		with (_canvas)
		{			
			if (nav_node_selected == noone && button_input) 
			{
				nav_select_node(nav_default_path, false);
				if (nav_node_selected == noone) return;
			}
		
			var _directions = nav_node_selected.navigator.directions,
				_blocked_dir = nav_node_selected.navigator.blocked_directions;
				
			var _mov_input = input_check_movement_accelerator();
						
			if (_mov_input.x > 0)
			{
				if (_directions.right != noone && !_blocked_dir.right) nav_select_node(_directions.right); 
			}
			else if (_mov_input.x < 0)
			{
				if (_directions.left != noone && !_blocked_dir.left) nav_select_node(_directions.left); 
			}
			else if (_mov_input.y > 0)
			{
				if (_directions.down != noone && !_blocked_dir.down) nav_select_node(_directions.down); 
			}
			else if (_mov_input.y < 0)
			{
				if (_directions.up != noone && !_blocked_dir.up) nav_select_node(_directions.up); 
			}
		}
	}	
		
	#endregion
	
	#region UTILITY

	///@function					navigation_block_button_input()
	///@description					Block gamepad/keyboard input
	static navigation_block_button_input = function()
	{
		button_input = !button_input;
	}
	
	///@function					navigation_block_cursor_input()
	///@description					Block cursor input
	static navigation_block_cursor_input = function()
	{
		cursor_input = !cursor_input;
	}
	
	///@function					navigation_set_default_node(_node_name)
	///@description					Set the given node to be the default selected node when activating this canvas
	///@param {string} _node_name	Default node name
	static navigation_set_default_node = function(_node_name)
	{
		var _first_node = node_find_by_name(_node_name);
		if (_first_node != noone)
		{
			nav_default_path = _first_node.path;
		}
	}
	
	#endregion
	
	#endregion
	
	///@function					__nav_initiate_navigation()
	///@description					Build grid, populate and select default node
	static __nav_initiate_navigation = function()
	{
		__nav_build_navigations();						
		if (!cursor_navigation) nav_select_node(nav_default_path, false);
	}
	
	custom_awake = function()
	{
		// Update nested node transforms
		transform.__reset_to_start();
		update_nested_transform();	
		
		__nav_initiate_navigation();		
		nav_deselect_node();
		
		processor.add_process(__nav_input_manager);
		
		// Force update at end of awake process
		update();
	}	
}
