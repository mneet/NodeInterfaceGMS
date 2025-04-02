function __node_navigator() constructor
{
	owner = noone;
	
	grid_position = new Vector2(0,0);
	selected = false;
		
	directions = {};
	with (directions){	
		up = noone;
		down = noone;
		left = noone;
		right = noone;	
	}
	
	blocked_directions = {};
	with (blocked_directions)
	{
		up = false;
		down = false;
		left = false;
		right = false;	
	}
	
	static set_directions = function(_direction, _path)
	{
		directions[$ _direction] = variable_clone(_path);
		return self;
	}
	
	static block_directions = function(_up, _down, _left, _right)
	{
		blocked_directions.up = _up;
		blocked_directions.down = _down;
		blocked_directions.left = _left;
		blocked_directions.right = _right;
	}
	
	static execute_selection_event = function()
	{
		with (owner)
		{
			for (var _i = 0; _i < array_length(__selection_events); _i++)
			{
				var _func = __selection_events[_i];
				if (is_callable(_func)) _func(self);
			}		
		}
	}
	
	static execute_deselection_event = function()
	{
		with (owner)
		{
			for (var _i = 0; _i < array_length(__deselection_events); _i++)
			{
				var _func = __deselection_events[_i];
				if (is_callable(_func)) _func(self);
			}		
		}
	}
	
	static select_node = function(_play_sound = true)
	{
		selected = !selected;
		
		if (owner.processor != noone)
		{
			owner.node_set_active(selected);	
			
			if (selected && _play_sound)
			{			
				if (!owner.sound_sel_played && owner.sound_select != noone && !owner.node_blocked)
				{
					audio_play_sfx(owner.sound_select);
					owner.sound_sel_played = true;
				}
			}
			else
			{
				owner.sound_sel_played = false;
			}	
		}
		
		return self;
	}
}

function __node_navi_grid_path_cell(_position, _path) constructor
{
	x =	_position.x;
	y =	_position.y;
	path = _path;
}

