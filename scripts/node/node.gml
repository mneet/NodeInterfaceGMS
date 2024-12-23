// An Node is the basic interface element, it has the default variables for control and visual display
function node(_name, _origin = NODE_ORIGIN.MIDDLE_CENTER) constructor
{
	// System variables
	id = 0;
	path = [id];
	name = _name; 
	depth = 0;
	
	origin = _origin;
	origin_offset = new Vector2(0,0);
	system_origin_offset = new Vector2(0,0);
	
	transform = new __node_transform();
	transform.owner = self;
	
	//Components 
	renderer = noone;
	processor = noone;
	animator = noone;
	navigator = noone;
	
	// Order that children nodes (containers, visual elements, etc) will be executed both for draw and step.
	// Ordenated by depth
	nested_nodes = [];
	nested_depth_order = [];
	nested_nodes_amnt = 0;	
	
	#region SYSTEM
	
	node_active = false;
	__path_amnt = 1;
	__path_cache = {};
	__skip_render = false;
	
	__command_delay = 0;
	
	#region NODE SEARCH
	
	///@function		__build_node_path()
	///@description		Build the node path to be used by internal functions
	static __build_node_path = function()
	{
		for (var _i = 0; _i < nested_nodes_amnt; _i++)
		{
			var _node = nested_nodes[_i];
			_node.path = variable_clone(path);		
			array_push(_node.path, _node.id);
			_node.__path_amnt = array_length(_node.path);
		}
	}
	
	///@function		__get_navigation_paths()
	///@description		Get the node paths from this node and all the nested nodes on it
	static __get_navigation_paths = function()
	{
		var _paths = [];
		for (var _i = 0; _i < nested_nodes_amnt; _i++)
		{
			var _node = nested_nodes[_i];
			if (_node.navigator != noone)
			{
				var _position = variable_clone(_node.transform.position);
				_position.x += _node.transform.offset.x * -1;
				_position.y += _node.transform.offset.y * -1;
				
				var _path_cell = new __node_navi_grid_path_cell(_position, variable_clone(_node.path));
				array_push(_paths, _path_cell);	
			}
			var _node_path = _node.__get_navigation_paths();
			if (array_length(_node_path) > 0 ) _paths = array_concat(_paths,_node_path);
		}
		return _paths;
	}
	
	///@function		__node_search_by_name()
	///@description		Search a node by its name (Slow, use it caution)
	static __node_search_by_name = function(_name)
	{
		var _search = false;
		for (var _i = 0; _i < nested_nodes_amnt; _i++)
		{
			var _node = nested_nodes[_i];
			if (_node.name == _name)
			{
				_search = _node;
				break
			}
			else
			{
				_search = _node.__node_search_by_name(_name);	
				if (_search != false) break;
			}
		}	
		if (_search != false)
		{
			struct_add_variable_once(__path_cache, _name, _search.path);	
		}
		return _search;
	}
	
	///@function		node_find_by_path()
	///@description		Search a node by its path
	static node_find_by_path = function(_path)
	{
		_path = variable_clone(_path);
		if (is_array(_path))
		{
			array_delete(_path, 0, __path_amnt);
		}
		var _node = self;
		for (var _i = 0; _i < array_length(_path); _i++)
		{
			var _ind = _path[_i];
			_node = _node.nested_nodes[_ind];	
		}
		return _node;
	}
	
	///@function		node_find_by_name()
	///@description		Search a node by its name, if already cache it will search by its path automaticaly
	static node_find_by_name = function(_name)
	{
		var _node = false;
		if (string_length(_name) <= 0) return _node;
		
		if (!struct_exists(__path_cache, _name))
		{
			_node = __node_search_by_name(_name);
		}
		else
		{
			show_debug_message($"Node {_name} found on cache");
			_node = node_find_by_path(__path_cache[$ _name]);	
		}
		
		return _node;
	}
	
	#endregion
			
	#region UPDATE NODE INTERNAL VARIABLES
	
	///@function		update()
	///@descriptions	Update the button variables when needed, example: Language or input mode change
	static update = function(_node)
	{
		for (var _i = 0; _i < nested_nodes_amnt; _i++)
		{
			var _nested_node = nested_nodes[_i];			
			_nested_node.update(_nested_node);
		}
		custom_update(_node);
		return;
	}
	
	///@function		custom_update()
	///@descriptions	Update the button variables when needed, example: Language or input mode change
	custom_update = function()
	{
		
	}
	
	///@function		node_set_custom_update()
	///@descriptions	Set the update function of the node
	node_set_custom_update = function(_custom_function)
	{
		if (is_callable(_custom_function))
		{
			custom_update = _custom_function;	
		}
	}
	
	#endregion
	
	#region TRANSFORM MANIPULATION
	
	///@function		update_nested_transform()
	///@description		Apply transform to all nested nodes
	static update_nested_transform = function()
	{
		for (var _i = 0; _i < nested_nodes_amnt; _i++)
		{
			var _node = nested_nodes[_i];			
			_node.transform.__set_parent(transform);
			_node.__node_get_system_origin_offset();
			_node.update_nested_transform();
		}
	}
	
	///@function		__rotate_nested()
	///@description		Rotate nested nodes around position
	static __rotate_nested = function()
	{
		for (var _i = 0; _i < nested_nodes_amnt; _i++)
		{
			var _node = nested_nodes[_i];
			_node.transform.rotation = transform.rotation + _node.transform.self_rotation;
			
			var _node_origin = new Vector2();
			_node_origin.x = transform.position.x + _node.transform.self_position.x;
			_node_origin.y = transform.position.y + _node.transform.self_position.y;
			
			var _distance = point_distance(_node_origin.x, _node_origin.y, transform.position.x, transform.position.y);
			
			_node.transform.position.x = transform.position.x + lengthdir_x(_distance, transform.rotation);
			_node.transform.position.y = transform.position.y + lengthdir_y(_distance, transform.rotation);
						
			_node.__rotate_nested();
		}
	}		
	
	///@function		__node_get_system_origin_offset()
	///@description		Calculate the system origin of the node (System origin is always TOP LEFT)
	static __node_get_system_origin_offset = function()
	{
		var _size = transform.size;
		switch (origin)
		{
			case NODE_ORIGIN.BOTTOM_LEFT:
				system_origin_offset.x = 0;
				system_origin_offset.y = -(_size.y);
				break;
			case NODE_ORIGIN.BOTTOM_CENTER:
				system_origin_offset.x = -(_size.x / 2);
				system_origin_offset.y = -(_size.y);
				break;
			case NODE_ORIGIN.BOTTOM_RIGHT:
				system_origin_offset.x = -_size.x;
				system_origin_offset.y = -(_size.y);
				break;
			case NODE_ORIGIN.MIDDLE_LEFT:
				system_origin_offset.x = 0;
				system_origin_offset.y = -_size.y / 2;
				break;
			case NODE_ORIGIN.MIDDLE_CENTER:
				system_origin_offset.x = -_size.x / 2;
				system_origin_offset.y = -_size.y / 2;
				break;
			case NODE_ORIGIN.MIDDLE_RIGHT:
				system_origin_offset.x = -(_size.x);
				system_origin_offset.y = -_size.y / 2;
				break;
			case NODE_ORIGIN.TOP_LEFT:
				system_origin_offset.x = 0;
				system_origin_offset.y = 0;
				break;
			case NODE_ORIGIN.TOP_CENTER:
				system_origin_offset.x = -(_size.x / 2);
				system_origin_offset.y = 0;
				break;
			case NODE_ORIGIN.TOP_RIGHT:
				system_origin_offset.x = -(_size.x);
				system_origin_offset.y = 0;
				break;
		}	
	}
	
	#endregion
	
	#endregion
	
	#region MUSIC
	
	sound_play_enter = snd_interface_open;
	sound_play_leave = snd_interface_open;
	
	#endregion
	
	#region ANIMATION UTILITY
	
	///@function		node_call_state(_state, _execute_at_end)
	///@description		Call an state on the animator component, execute a funciton at end
	static node_call_state = function(_state, _execute_at_end = noone, _play_music = true)
	{
		if (_play_music)
		{
			switch (_state)
			{
				case NODE_MOTION_STATE.ENTER:
					audio_play_sfx(sound_play_enter);	
					break;
					
				case NODE_MOTION_STATE.OUT:
					//audio_play_sfx(sound_play_leave);	
					break;
			}		
		}
		
		node_trigger_nested_animator(_state);
		if (animator != noone && !animator.motion_state_compare(_state))
		{
			animator.animator_change_state(_state, _execute_at_end);
		}
		else
		{
			if (is_callable(_execute_at_end))
			{
				if (__command_delay > 0)
				{
					call_later(__command_delay, time_source_units_seconds, _execute_at_end);	
				}
				else
				{
					_execute_at_end();	
				}
			}
		}
	}
	
	///@function		node_set_call_delay(_seconds)
	///@description		Set a delay in seconds for the at end function on animator states
	static node_set_call_delay = function(_seconds)
	{
		__command_delay = _seconds;
	}
	
	///@function		node_trigger_nested_animator(_state)
	///@description		Trigger a state on all nested nodes
	static node_trigger_nested_animator = function(_state)
	{
		for (var _i = 0; _i < nested_nodes_amnt; _i++)
		{
			var _node = nested_nodes[_i];			
			_node.node_call_state(_state, noone, false);
		}		
	}
	
	///@function		node_reset_nested_nodes()
	///@description		Reset all nested nodes to their start transform
	static node_reset_nested_nodes = function()
	{
		for (var _i = 0; _i < nested_nodes_amnt; _i++)
		{
			var _node = nested_nodes[_i];			
			_node.transform.__reset_to_start();
			_node.node_reset_nested_nodes();	
		}		
	}
	
	#endregion
	
	#region UTILITY
	
	///@function						node_add(_nodes)
	///@description						Add a new nested node
	///@param {struct} _nodes			Nodes to be nested
	static node_add = function(_nodes)
	{
		for (var _i = 0; _i < argument_count; _i++)
		{
			argument[_i].id = array_length(nested_nodes);
			array_push(nested_nodes, variable_clone(argument[_i]));	
			array_push(nested_depth_order, variable_clone(argument[_i].id));
			
			if (argument[_i].transform.size.x > transform.fixed_size.x && argument[_i].transform.size.y > transform.fixed_size.y)
			{
				node_set_size(argument[_i].transform.size.x, argument[_i].transform.size.y);	
			}
		}		
		nested_nodes_amnt = array_length(nested_nodes);
		return self;
	}
	
	///@function						node_set_depth(_depth)
	///@description						Change the depth of the node
	///@param {real} _depth				Depth integer number
	static node_set_depth = function(_depth)
	{
		depth = _depth;
		return self;
	}
	
	///@function						node_set_position(_x, _y)
	///@description						Set the node position on the canvas
	///@param {real} _x					X position in pixels
	///@param {real} _y					Y position in pixels
	static node_set_position = function(_x, _y)
	{
		transform.fixed_position.x = round(_x);
		transform.fixed_position.y = round(_y);	
						
		return self;
	}
	
	///@function						node_set_scale(_x, _y)
	///@description						Set the node scale
	///@param {real} _x					X scale
	///@param {real} _y					Y scale
	static node_set_scale = function(_x, _y)
	{
		transform.fixed_scale.x = _x;
		transform.fixed_scale.y = _y;
		
		return self;
	}
	
	///@function						node_set_start_position(_x, _y)
	///@description						Set the node position on the canvas
	///@param {real} _x					X position in pixels
	///@param {real} _y					Y position in pixels
	static node_set_start_position = function(_x, _y)
	{
		transform.start_position = new Vector2(round(_x), round(_y));
		
		return self;
	}
	
	///@function						node_set_start_scale(_x, _y)
	///@description						Set the node scale
	///@param {real} _x					X scale
	///@param {real} _y					Y scale
	static node_set_start_scale = function(_x, _y)
	{
		transform.start_scale = new Vector2(round(_x), round(_y));
		
		return self;
	}
	
	///@function						node_set_start_rotation(_x, _y)
	///@description						Set the node scale
	///@param {real} _x					X scale
	///@param {real} _y					Y scale
	static node_set_start_rotation = function(_x, _y)
	{
		transform.start_rotation = _x;
		
		return self;
	}
	
	///@function						node_set_start_alpha(_x, _y)
	///@description						Set the node scale
	///@param {real} _alpha				Alpha
	static node_set_start_alpha = function(_alpha)
	{
		transform.start_alpha = _alpha;	
		return self;
	}
	
	///@function						node_set_offset(_x, _y)
	///@description						Set the node offset on the canvas, this is used when you want to change the positions inside a container but maintain the navigation
	///@param {real} _x					X position in pixels
	///@param {real} _y					Y position in pixels
	static node_set_offset = function(_x, _y)
	{
		transform.offset.x = _x;
		transform.offset.y = _y;
		
		return self;
	}
	
	///@function						node_set_size(_w, _h)
	///@description						Set the size of the node
	///@param {real} _w					Width in pixels
	///@param {real} _h					Height in pixels
	static node_set_size = function(_w, _h)
	{		
		transform.fixed_size.x = variable_clone(round(_w));
		transform.fixed_size.y = variable_clone(round(_h));	
		
		transform.size.x = variable_clone(round(_w));
		transform.size.y = variable_clone(round(_h));	
		
		__node_get_system_origin_offset();
		return self;
	}
			
	///@function						node_get_converted_origin()
	///@description						Convert the system origin for any given origin
	///@param {real} _origin			Desired origin using enum NODE_ORIGIN
	static node_get_converted_origin = function(_origin)
	{
		var _size = transform.size;
		var _offset = variable_clone(system_origin_offset);
		switch (_origin)
		{
			case NODE_ORIGIN.BOTTOM_LEFT:
				_offset.x += 0;
				_offset.y += _size.y;
				break;
			case NODE_ORIGIN.BOTTOM_CENTER:
				_offset.x += _size.x / 2;
				_offset.y += _size.y;
				break;
			case NODE_ORIGIN.BOTTOM_RIGHT:
				_offset.x += _size.x;
				_offset.y += _size.y;
				break;
			case NODE_ORIGIN.MIDDLE_LEFT:
				_offset.x += 0;
				_offset.y += _size.y / 2;
				break;
			case NODE_ORIGIN.MIDDLE_CENTER:
				_offset.x += _size.x / 2;
				_offset.y += _size.y / 2;
				break;
			case NODE_ORIGIN.MIDDLE_RIGHT:
				_offset.x += _size.x;
				_offset.y += _size.y / 2;
				break;
			case NODE_ORIGIN.TOP_LEFT:
				_offset.x += 0;
				_offset.y += 0;
				break;
			case NODE_ORIGIN.TOP_CENTER:
				_offset.x += _size.x / 2;
				_offset.y += 0;
				break;
			case NODE_ORIGIN.TOP_RIGHT:
				_offset.x += _size.x;
				_offset.y += 0;
				break;
		}	
		return _offset;
	}
	
	///@function						node_transform_rotate(_rotation)
	///@description						Rotate the node and the nested nodes inside it
	///@param {real} _rotation			Rotation in degrees
	static node_transform_rotate = function(_rotation)
	{
		transform.rotation = transform.parent_rotation + _rotation;
		transform.self_rotation = _rotation;
		__rotate_nested();
	}
	
	///@function						node_transform_scale(_rotation)
	///@description						Change node scale
	///@param {real} _x					X scale (Width, horizontal, X)
	///@param {real} _y					Y scale (Height, vertical, Y)
	static node_transform_scale = function(_x, _y)
	{
		transform.scale.x = _x;
		transform.scale.y = _y;	
		
		update_nested_transform();	
	}
	
	///@function						node_transform_move(_rotation)
	///@description						Move the node position in pixels
	///@param {real} _x					X amount of pixels
	///@param {real} _y					Y amount of pixels
	static node_transform_move = function(_x, _y)
	{
		transform.position.x += _x;
		transform.position.y += _y;
		
		transform.self_position.x += _x;
		transform.self_position.y += _y;	

		update_nested_transform();
	}
	
	///@function						node_transform_alpha(_rotation)
	///@description						Move the node position in pixels
	///@param {real} _alpha				Alpha value
	static node_transform_alpha = function(_alpha)
	{
		transform.alpha += _alpha;
		transform.self_alpha = _alpha;	

		update_nested_transform();
	}
	
	///@function						node_transform_set_alpha(_rotation)
	///@description						Move the node position in pixels
	///@param {real} _alpha				Alpha value
	static node_transform_set_alpha = function(_alpha)
	{
		transform.alpha = _alpha;
		transform.self_alpha = _alpha;	

		update_nested_transform();
	}
	
	#endregion
	
	#region COMPONENTS
	
	///@function		add_component_renderer()
	///@description		Add a renderer component to the node
	static add_component_renderer = function(_owner = self)
	{
		if (renderer != noone) return;
		
		renderer = new __node_renderer();
		renderer.owner = _owner;
	}
	
	///@function		add_component_processor()
	///@description		Add a renderer component to the node
	static add_component_processor = function(_owner = self)
	{
		if (processor != noone) return;
		
		processor = new __node_processor();
		processor.owner = _owner;
	}
	
	///@function		add_component_animator()
	///@description		Add a renderer component to the node
	static add_component_animator = function(_owner = self)
	{
		if (animator != noone) return;
		
		if (processor == noone) add_component_processor();
		animator = new __node_animator();	
		animator.owner = _owner;	
		
		processor.add_process(animator.state_machine_brain, true);
	}
	
	///@function		add_component_navigator()
	///@description		Add a navigator component to the node
	static add_component_navigator = function(_owner = self)
	{
		if (navigator != noone) return;
		
		navigator = new __node_navigator();	
		navigator.owner = _owner;	
	}
	
	#endregion	
	
	custom_awake = function()
	{
		
	}	
	
	///@function		__awake()
	///@description		Run methods to update and start node
	__awake = function()
	{
		__build_node_path();
		transform.__initiate_transform();
		transform.__transform_recalculate();
		__node_get_system_origin_offset();	
		
		nested_depth_order = node_array_sort_by_depth(nested_nodes,nested_depth_order);				
		for (var _i = 0; _i < nested_nodes_amnt; _i++)
		{
			var _node = nested_nodes[_i];
			_node.__awake();			
		}
		transform.__reset_to_start();
		
		update_nested_transform();	
		custom_awake();
	}
}

function __node_transform() : MiniTransform() constructor
{
	owner = noone;
	
	// ATTRIBUTES
	position = new Vector2(0,0);
	parent_position = new Vector2(0,0);
	self_position = new Vector2(0,0);
	fixed_position = new Vector2(0,0);
	start_position = noone;
	
	scale = new Vector2(1,1);
	parent_scale = new Vector2(1,1)
	self_scale = new Vector2(1,1);
	fixed_scale = new Vector2(1,1);
	start_scale = noone;
	
	alpha = 1;
	parent_alpha = 1;
	self_alpha = 1;
	fixed_alpha = 1;
	start_alpha = noone;
	
	rotation = 0;
	parent_rotation = 0;
	self_rotation = 0;
	fixed_rotation = 0;
	start_rotation = noone;
	
	size = new Vector2(16,16);
	fixed_size = new Vector2(16,16);
	parent_size = new Vector2(16,16);
	offset = new Vector2(0,0);	
	

	///@function		__initiate_transform()
	///@description		Initiate transform variables
	static __initiate_transform = function()
	{
		self_position = variable_clone(fixed_position);	
		self_scale = variable_clone(fixed_scale);				
		self_alpha = variable_clone(fixed_alpha);			
		self_rotation = variable_clone(fixed_rotation);
		
		__transform_calculate_size();
		__transform_recalculate();
	}
	
	///@function		__containter_update()
	///@description		Update attribute safter being organized by a container
	static __containter_update = function()
	{
		self_position = variable_clone(fixed_position);	
		self_scale = variable_clone(fixed_scale);				
		self_alpha = variable_clone(fixed_alpha);			
		self_rotation = variable_clone(fixed_rotation);
		
		fixed_position.x = parent_position.x + self_position.x;
		fixed_position.y = parent_position.y + self_position.y;
		fixed_alpha = self_alpha * alpha;
		fixed_scale.x = self_scale.x * parent_scale.x;
		fixed_scale.y = self_scale.y * parent_scale.y;
		fixed_rotation = self_rotation + rotation;
		
		__transform_recalculate();
		
		if (owner != noone) owner.update_nested_transform();
	}	
	
	///@function		__transform_calculate_size()
	///@description		Recalculate node size and scale
	static __transform_calculate_size = function()
	{
		size.x = round(fixed_size.x * scale.x);
		size.y = round(fixed_size.y * scale.y);
	}
	
	///@function		__transform_recalculate()
	///@description		Recalculate positions, size, etc
	static __transform_recalculate = function()
	{			
		position.x = parent_position.x + self_position.x + offset.x;
		position.y = parent_position.y + self_position.y + offset.y;
		
		scale.x = self_scale.x * parent_scale.x;
		scale.y = self_scale.y * parent_scale.y;
				
		alpha = self_alpha * parent_alpha;
		
		rotation = self_rotation + parent_rotation;
				
		__transform_calculate_size();

	}	
	
	///@function		__set_parent()
	///@description		Get the parent node attributes
	static __set_parent = function(_transform)
	{
		parent_position = variable_clone(_transform.position);
		parent_scale = variable_clone(_transform.scale);
		parent_rotation = variable_clone(_transform.rotation);
		parent_alpha = variable_clone(_transform.alpha);
		parent_size = variable_clone(_transform.size);
		
		__transform_recalculate();
	}	
	
	///@function		__reset_to_start()
	///@description		Set the active variables to the start variables (Used when animating nodes)
	static __reset_to_start = function()
	{
		position = start_position != noone ? variable_clone(start_position) : position;
		scale = start_scale != noone ? variable_clone(start_scale) : scale;
		alpha = start_alpha != noone ? variable_clone(start_alpha) : alpha;
		rotation = start_rotation != noone ? variable_clone(start_rotation) : rotation;
	}
	
	
	#region CONFIGURE NODE SPECIFIC TRANSFORM
	__execute_on_complete = function()
	{
		if (on_complete_func != noone)
		{
			on_complete_func(tween_target);
		}
	}
	
	update_children = function()
	{
		if (owner != noone)
		{
			owner.update_nested_transform();
		}
	}
	
	#endregion
}	