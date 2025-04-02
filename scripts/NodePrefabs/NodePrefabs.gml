 function node_button(_name, _navigable = true, _origin = NODE_ORIGIN.MIDDLE_CENTER) : Node(_name, _origin) constructor
{
	add_component_renderer();
	add_component_processor();	

	node_active = false;
	navigable = _navigable;
	
	sound_select = noone;
	sound_click = noone;
	
	sound_sel_played = false;
	sound_click_played = false;
	
	input_checker = input_check_pressed;
	
	#region TEXT ATTRIBUTES
	text_calculated = false;
	
	text_key =  "";
	text =  "";
	
	font_key = "";
	font = fnt_noto_10;
	outline = false;
	
	// Colors
	color1 = c_white;
	color2 = c_white;
	color3 = c_white;
	color4 = c_white;	
	
	alignment_h = fa_center;
	alignment_v = fa_middle;
	
	separation = -1;
	horizontal_wrap = GUI_WIDTH;	
	
	text_scale = transform.scale;
	text_box = transform.size;
	text_offset = new Vector2(0,0);
	
	__draw_text = false;
	
	#endregion
	
	#region SPRITE ATTRIBUTES
	
	sprite = noone;
	sprite_default = noone;
	sprite_hover = noone;
	
	sub_img = 0;
	animate = false;
	color = c_white;
	sprite_scale = new Vector2(1,1);	
	
	#endregion
	
	#region INPUT GLYPH
	
	input_indicator = noone;
	input_sprite = noone;
	input_origin = noone;
	input_transform = noone;
	
	///@function		node_add_input_indicator()
	///@descriptions	Add an input indicator to the button
	static node_add_input_indicator = function(_input, _origin = NODE_ORIGIN.TOP_LEFT, _offset_x = 0, _offset_y = 0)
	{
		input_indicator = _input;
		input_sprite = input_get_sprite(_input);
		input_origin = _origin;
		input_transform = new MiniTransform();	
		
		var _origin_pos = node_get_converted_origin(input_origin);
		input_transform.position.x = _origin_pos.x + _offset_x;
		input_transform.position.y = _origin_pos.y + _offset_y;
		
		return self;
	}
	
	///@function		node_input_set_scale()
	///@descriptions	Set the scale of the input indicator
	static node_input_ind_set_scale = function(_x, _y)
	{
		input_transform.scale.x = _x;
		input_transform.scale.y = _y;
		
		return self;
	}	
	
	#endregion
	
	if (navigable)
	{
		add_component_navigator();
		with (processor)
		{
			mouse_hover = false;
		
			click_action = function(_node)
			{
				mini_tween(_node.transform,.05)
					.tween_scale(0.95, 0.95)
					.set_on_complete(function(_target)
					{
						mini_tween(_target, .05)
							.tween_scale(1, 1);
					});
			}
		
			click_control = function(_node)
			{
				if (_node.node_blocked) return;
				
				var _processor = _node.processor;
				if (!_processor.mouse_hover || global.node_manager.block_action || !_node.node_active) return;
				
				global.node_manager.__cursor_hovering_interface = _processor.mouse_hover;
				
				var _click_input = _node.input_checker("act_accept");	
				if (_click_input && _processor.click_action != noone)
				{
					if (_node.sound_click != noone) audio_play_sfx(_node.sound_click);
					_processor.click_action(_node);
				}
				
				if (!_node.node_active && __events_activation_on)
				{
					__node_execute_deactivation_events();
				}
			}
			add_process(click_control, false);
		
			var _mouse_selection = function(_node)
			{
				var _canvas_parent = node_get_canvas_by_ind(_node.__canvas_ind);
				
				if (_canvas_parent != noone && !_canvas_parent.canvas_is_active) return;
				
				var _processor = _node.processor;
				if (_node.node_active)
				{
					_node.sprite = _node.sprite_hover;	
				}
				else
				{
					_node.sprite = _node.sprite_default;	
				}
				if (!node_check_cursor_navigation() && node_check_button_input())
				{
					_processor.mouse_hover = true;
					_node.node_set_active(_node.navigator.selected);
					return;
				}
			
				var _cursor = input_get_cursor();
			
				var _node_origin_x = _node.transform.position.x + _node.system_origin_offset.x,
					_node_origin_y = _node.transform.position.y + _node.system_origin_offset.y;
			
				var _node_x_2 = _node_origin_x + _node.transform.fixed.size.x,
					_node_y_2 = _node_origin_y + _node.transform.fixed.size.y;
			
				var _mouse_check = point_in_rectangle(_cursor.x, _cursor.y, _node_origin_x, _node_origin_y, _node_x_2, _node_y_2);
			
				if (_mouse_check != _node.node_active)
				{					
					if (_mouse_check)
					{						
						_canvas_parent.nav_select_node(_node.path);				
					}
					_processor.mouse_hover = _mouse_check;

					_node.node_set_active(_processor.mouse_hover);
				}
			
			}
			add_process(_mouse_selection);
		}
	}
	
	#region UPDATE
	
	static update_input_indicator = function()
	{
		if (input_indicator != noone) input_sprite = input_get_sprite(input_indicator);
	}
	
	custom_update = function()
	{
		text = language_get_localized_text(text_key);
		font = language_get_localized_font(font_key, outline);
		text_calculated = false;	
		
		update_input_indicator();
	}
	
	#endregion
	
	#region EVENTS
	
	__activation_events = [];
	__deactivation_events = [];
	__events_activation_on = false;
	
	///@function		node_set_active()
	///@descriptions	Toggle the active flag on the node
	node_set_active = function(_flag)
	{
		if (node_blocked) _flag = false;
		
		if (node_active != _flag)
		{
			node_active = _flag;
			
			if (node_active) 
			{
				__node_execute_activation_events();
				node_set_button_active(true);
			}
			else
			{
				__node_execute_deactivation_events();
				node_set_button_active(false);
			}
		}
	}	
	
	///@function						node_add_activation_event(_event)
	///@description						Add a new event to be executed when node is selected
	static node_add_activation_event = function(_event)
	{
		for (var _i = 0; _i < argument_count; _i++)
		{
			var _func = argument[_i];
			array_push(__activation_events, _func);
		}		
		return self;
	}
	
	///@function						node_add_deactivation_event(_event)
	///@description						Add a new event to be executed when node is deselected
	static node_add_deactivation_event = function(_event)
	{
		for (var _i = 0; _i < argument_count; _i++)
		{
			var _func = argument[_i];
			array_push(__deactivation_events, _func);
		}		
		return self;
	}
	
	static __node_execute_activation_events = function()
	{
		__events_activation_on = true;
		for (var _i = 0; _i < array_length(__activation_events); _i++)
		{
			var _func = __activation_events[_i];
			if (is_callable(_func)) _func(self);
		}	
	}
	
	static __node_execute_deactivation_events = function()
	{
		__events_activation_on = false;
		for (var _i = 0; _i < array_length(__deactivation_events); _i++)
		{
			var _func = __deactivation_events[_i];
			if (is_callable(_func)) _func(self);
		}	
	}
	
	#endregion
	
	#region UTILITY
	
	///@function			set_click_action(_click_function)
	///@description			Add a function to run when the node is clicked
	static set_click_action = function(_click_function)
	{
		if (processor != noone)
		{
			processor.click_action = _click_function;
		}
		return self;
	}
		
	#region TEXT
	///@function							node_add_text(_text, _font, _color, _outline)
	///@description							Prefab node made for drawing text elements
	///@param {string} _text_key			Text key or string
	///@param {Asset.GMFont} _font			Text font
	///@param {Constant.Color} _color		Text color
	///@param {bool} _outline				If the text should be drawed with an outline
	static node_add_text = function(_text_key, _font_key, _color, _outline)
	{
		text_key =  _text_key;
		text =  language_get_localized_text(_text_key);
		font_key = _font_key;
		font = language_get_localized_font(_font_key, _outline);
		outline = _outline;
	
		// Colors
		color1 = _color;
		color2 = _color;
		color3 = _color;
		color4 = _color;	
	
		alignment_h = fa_center;
		alignment_v = fa_middle;
	
		separation = -1;
		text_box = transform.fixed.size;
		
		__draw_text = true;
	}
	
	///@function			node_text_set_alignment(_horizontal, _vertical)
	static node_text_set_alignment = function(_horizontal, _vertical)
	{
		alignment_h = _horizontal;
		alignment_v = _vertical;
		
		return self;
	}
	
	///@function			node_text_set_horizontal_wrap(_wrap_w, _separation)
	static node_text_set_horizontal_wrap = function(_wrap_w, _separation = -1)
	{
		horizontal_wrap = _wrap_w;
		separation = _separation;
		
		return self;
	}
	
	///@function			node_text_set_colors(_c1, _c2, _c3, _c4)
	static node_text_set_colors = function(_c1, _c2, _c3, _c4)
	{
		color1 = _c1;
		color2 = _c2;
		color3 = _c3;
		color4 = _c4;
		
		return self;
	}	
	
	///@function						node_text_set_box(_w, _h)
	///@description						Define the text box size
	static node_text_set_box = function(_w, _h)
	{		
		text_box = new Vector2(_w, _h);	
	}
			
	///@function						node_text_set_scale(_xscale, _yscale)
	///@description						Define the text scale
	static node_text_set_scale = function(_xscale, _yscale)
	{		
		text_scale = new Vector2(_xscale, _yscale);
	}
	
	///@function						node_text_set_offset(_x, _y)
	///@description						Define the text offset
	static node_text_set_offset = function(_x, _y)
	{		
		text_offset = new Vector2(_x, _y);
	}
	
	#endregion
	
	#region SPRITE
	
	///@function						node_add_sprite(_text, _font, _color, _outline)
	///@description						Prefab node made for drawing sprites
	///@param {Asset.GMSprite} _sprite	Sprite asset do be drawed
	///@param {Constant.Color} _color	Sprite color
	///@param {bool} _animate			If the sprite subimg should be animated
	static node_add_sprite = function(_sprite, _color = c_white, _animate = false)
	{
		// Sprite attributes
		sprite = _sprite;
		sprite_default = _sprite;
		sprite_hover = _sprite;
		
		sub_img = 0;
		animate = _animate;
		color = _color;	

		// If animate is turned on
		if (animate)
		{		
			with (processor)
			{
				var _animate_sprite_subimg = function(_owner)
				{					
					_owner.sub_img += sprite_get_speed(_owner.sprite) / game_get_speed(gamespeed_fps);
					_owner.sub_img = _owner.sub_img % sprite_get_number(_owner.sprite);
				}	
				add_process(_animate_sprite_subimg);
			}
		}
		
		var _spr_w = sprite_get_width(sprite),
			_spr_h = sprite_get_height(sprite);
		
		if (transform.size.x < _spr_w || transform.size.y < _spr_h)
		{
			node_set_size(_spr_w, _spr_h);
		}
	}
		
	///@function						node_sprite_set_scale(_xscale, _yscale)
	///@description						Define the sprite scale
	static node_sprite_set_scale = function(_xscale, _yscale)
	{		
		sprite_scale = new Vector2(_xscale, _yscale);
	}
	
	///@function						node_sprite_set_hover(_sprite)
	///@description						Define the hovering sprite
	static node_sprite_set_hover = function(_sprite)
	{
		sprite_hover = _sprite;
	}
	
	#endregion
	
	static node_add_select_sound = function(_sound_id)
	{
		sound_select = _sound_id;
		return self;
	}
	
	static node_add_click_sound = function(_sound_id)
	{
		sound_click = _sound_id;
		return self;
	}
	
	#endregion
	
	#region DEFAULT DRAW
	with (renderer)
	{
		custom_draw = function(_node)
		{
			var _transform = _node.transform;
			
			var _sprite_x = _transform.position.x,
				_sprite_y = _transform.position.y,
				_text_x = _transform.position.x + (_node.text_offset.x * _transform.scale.x),
				_text_y = _transform.position.y + (_node.text_offset.y * _transform.scale.y);
			
			if (!_node.text_calculated && _node.__draw_text)
			{
			    draw_set_font(_node.font);

			    var _txt_width = string_width_ext(_node.text, _node.separation,  _node.text_box.x);

			    _node.text_scale = new Vector2(1, 1);

			    if (_txt_width > _node.text_box.x)
			    {
			        _node.text_scale.x = round((_node.text_box.x / _txt_width) * 10) / 10;
			    }

			    _node.text_scale.y = _node.text_scale.x;

			    _node.text_calculated = true;
			}
						
			if (_node.sprite != noone)
			{	
				draw_sprite_ext(
					_node.sprite, 
					_node.sub_img, 
					_transform.position.x, 
					_transform.position.y, 
					_transform.scale.x * _node.sprite_scale.x, 
					_transform.scale.y * _node.sprite_scale.y, 
					_transform.rotation,
					_node.color, 
					_transform.alpha
				);			
			}						
			
			if (_node.__draw_text)
			{
				// Draw sets
				draw_set_font(_node.font);
				draw_set_valign(_node.alignment_v);
				draw_set_halign(_node.alignment_h);

				// Drawing text
				draw_text_ext_transformed_color(
					_text_x, 
					_text_y, 
					_node.text, 
					_node.separation, 
					_node.text_box.x, 
					_node.text_scale.x * _transform.scale.x, 
					_node.text_scale.y * _transform.scale.y, 
					_transform.rotation, 
					_node.color1, _node.color2, _node.color3, _node.color4, 
					_transform.alpha
				);

				// Reseting draw_set
				draw_set_font(-1);
				draw_set_valign(-1);
				draw_set_halign(-1);
			}
			
			if (_node.input_sprite != noone && !_node.node_blocked)
			{
				draw_input_sprite(
					_node.input_sprite, 
					0, 
					_transform.position.x + _node.input_transform.position.x, 
					_transform.position.y +  _node.input_transform.position.y, 
					_transform.scale.x * _node.input_transform.scale.x, 
					_transform.scale.y * _node.input_transform.scale.y, 
					_transform.rotation + _node.input_transform.rotation,
					_node.color, 
					_transform.alpha * _node.input_transform.alpha
				);
			}
		}		
	}	
	#endregion
	
	#region Start Default
	add_component_animator();
	//animator.set_state_motion(NODE_MOTION_STATE.IDLE, global.node_animator_db.active_scale_grow);
	#endregion

}

///@function							node_text(_text, _font, _color, _outline)
///@description							Prefab node made for drawing text elements
///@param {string} _name				Node name
///@param {string} _text				String to be drawed
///@param {Asset.GMFont} _font			Text font
///@param {Constant.Color} _color		Text color
///@param {bool} _outline				If the text should be drawed with an outline
function node_text(_name, _text, _font, _color, _outline = true, _origin = NODE_ORIGIN.MIDDLE_CENTER) : Node(_name, _origin) constructor 
{
	text_key = _text;
	text =  language_get_localized_text(_text);
	font = language_get_localized_font(_font, _outline);
	font_key = _font;
	outline = _outline;
	
	text_box = variable_clone(transform.size);
	text_scale = new Vector2(1,1);
	
	// Colors
	color1 = _color;
	color2 = _color;
	color3 = _color;
	color4 = _color;	
	
	alignment_h = fa_center;
	alignment_v = fa_middle;
	
	separation = -1;
	horizontal_wrap = GUI_WIDTH;
	
	text_calculated = false;
	
	typewriting = false;
	text_len = 0;
	text_full = "";
	char_current = 0;
	char_speed   = 1;
	typewriter_delay = 0;
	
	#region System Methods
	
	with (renderer)
	{	
		custom_draw = function(_node)
		{
			var _transform = _node.transform;
			
			if (!_node.text_calculated)
			{
			    draw_set_font(_node.font);

			    var _txt_width = string_width_ext(_node.text, _node.separation, _node.text_box.x);

			    _node.text_scale = new Vector2(1, 1);

			    if (_txt_width > _node.text_box.x)
			    {
			        _node.text_scale.x = round((_node.text_box.x / _txt_width) * 10) / 10;
			    }

			    _node.text_scale.y = _node.text_scale.x;

			    _node.text_calculated = true;
			}
										
			// Draw sets
			draw_set_font(_node.font);
			draw_set_valign(_node.alignment_v);
			draw_set_halign(_node.alignment_h);

			// Drawing text
			draw_text_ext_transformed_color(
				_transform.position.x, 
				_transform.position.y, 
				_node.text, 
				_node.separation, 
				_node.text_box.x, 
				_node.text_scale.x * _transform.scale.x, 
				_node.text_scale.y * _transform.scale.y, 
				_transform.rotation, 
				_node.color1, _node.color2, _node.color3, _node.color4, 
				_transform.alpha
			);

			// Reseting draw_set
			draw_set_font(-1);
			draw_set_valign(-1);
			draw_set_halign(-1);			
		}	
	}
		
	#endregion
	
	#region UPDATE
	
	typewrite_update = function()
	{
		var _text = text;
		
		text_len = string_length(_text);	
		if (typewriting && text_full != _text)
		{			
			text = string_copy(_text, 1, 0);
			char_current = 0;
			typewriter_delay = typewriter_delay_max;
		}
		else
		{
			char_current = text_len;
		}
		text_full = _text;
	}
	
	custom_update = function()
	{
		text = language_get_localized_text(text_key);
		font = language_get_localized_font(font_key, outline);
		text_calculated = false;	
		typewrite_update();
	}
	
	#endregion
	
	#region Utility Methods
	
	static text_set_alignment = function(_horizontal, _vertical)
	{
		alignment_h = _horizontal;
		alignment_v = _vertical;
		
		return self;
	}
	
	static text_set_text_box = function(_w, _h)
	{
		text_box.x = _w;
		text_box.y = _h;
		
		return self;
	}
	
	static text_set_colors = function(_c1, _c2, _c3, _c4)
	{
		color1 = _c1;
		color2 = _c2;
		color3 = _c3;
		color4 = _c4;
		
		return self;
	}	
	
	static text_set_typewriting = function(_speed = 1, _delay = 0)
	{
		typewriting = true;
		char_current = 1;
		char_speed = _speed;
		typewriter_delay = _delay;
		typewriter_delay_max = _delay;
		
		with(processor)
		{
			typewriting_control = function(_node)
			{
				with (_node)
				{
					if (typewriter_delay > 0)
					{
						typewriter_delay -= delta_time_seconds();
						return;
					}
					
					if (char_current < string_length(text_full))
					{
						char_current += delta_time_seconds() * char_speed;
						text = string_copy(text_full, 1, char_current);
						
						text = string_wrap(text, text_box.x, font);
					}
				}
			}
			add_process(typewriting_control, true);
		}
	}
	#endregion
}


///@function						node_sprite(_text, _font, _color, _outline)
///@description						Prefab node made for drawing sprites
///@param {string} _name			Node name
///@param {Asset.GMSprite} _sprite	Sprite asset do be drawed
///@param {Constant.Color} _color	Sprite color
///@param {bool} _animate			If the sprite subimg should be animated
function node_sprite(_name, _sprite, _color = c_white, _animate = false, _origin = NODE_ORIGIN.MIDDLE_CENTER) : Node(_name, _origin) constructor 
{
	// Sprite attributes
	sprite = _sprite;
	sub_img = 0;
	animate = _animate;
	color = _color;	
			
	node_set_size(sprite_get_width(sprite), sprite_get_height(sprite));
	
	// Draw methods
	with (renderer)
	{	
		custom_draw = function(_node)
		{
			var _transform = _node.transform;
			
			var _sprite_x = _transform.position.x,
				_sprite_y = _transform.position.y;
						
			if (_node.sprite != noone)
			{	
				draw_sprite_ext(
					_node.sprite, 
					_node.sub_img, 
					_transform.position.x, 
					_transform.position.y, 
					_transform.scale.x, 
					_transform.scale.y, 
					_transform.rotation,
					_node.color, 
					_transform.alpha
				);	
			}						
		}		
	}	
	
	// If animate is turned on
	if (animate)
	{		
		with (processor)
		{
			var _animate_sprite_subimg = function(_owner)
			{					
				_owner.sub_img += sprite_get_speed(_owner.sprite) / game_get_speed(gamespeed_fps);
				_owner.sub_img = _owner.sub_img % sprite_get_number(_owner.sprite);
			}	
			add_process(_animate_sprite_subimg);
		}
	}
}

