function node_button(_name, _navigable = true, _origin = NODE_ORIGIN.MIDDLE_CENTER) : node(_name) constructor
{
	add_component_renderer();
	add_component_processor();	
	
	origin = _origin;
	node_active = false;
	navigable = _navigable;
	
	sound_select = snd_button_select_pop;
	sound_click = snd_interface_button_confirm;
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
	
	#endregion
	
	#region SPRITE ATTRIBUTES
	
	sprite = noone;
	sprite_default = noone;
	sprite_hover = noone;
	
	sub_img = 0;
	animate = false;
	color = c_white;
	sprite_scale = transform.scale;	
	
	#endregion
	
	click_checker = function(_node)
	{
		var _processor = _node.processor;
		if (!_processor.mouse_hover || global.node_manager.block_action) return;
				
		var _click_input = input_check_pressed("act_accept");	
		if (_click_input && _processor.click_action != noone)
		{
			if (_node.sound_click != noone) audio_play_sfx(_node.sound_click);
			_processor.click_action(_node);
		}
	}
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
				var _processor = _node.processor;
				if (!_processor.mouse_hover || global.node_manager.block_action) return;
				
				var _click_input = _node.input_checker("act_accept");	
				if (_click_input && _processor.click_action != noone)
				{
					if (_node.sound_click != noone) audio_play_sfx(_node.sound_click);
					_processor.click_action(_node);
				}
			}
			add_process(click_control, false);
		
			var _mouse_selection = function(_node)
			{
				var _processor = _node.processor;
				if (_node.node_active)
				{
					_node.sprite = _node.sprite_hover;	
				}
				else
				{
					_node.sprite = _node.sprite_default;	
				}
				if (!node_check_cursor_navigation())
				{
					_processor.mouse_hover = true;
					return;
				}
			
				var _cursor = input_get_cursor();
			
				var _node_origin_x = _node.transform.fixed_position.x + _node.system_origin_offset.x + _node.transform.offset.x,
					_node_origin_y = _node.transform.fixed_position.y + _node.system_origin_offset.y + _node.transform.offset.y;
			
				var _node_x_2 = _node_origin_x + _node.transform.size.x,
					_node_y_2 = _node_origin_y + _node.transform.size.y;
			
				var _mouse_check = point_in_rectangle(_cursor.x, _cursor.y, _node_origin_x, _node_origin_y, _node_x_2, _node_y_2);
			
				var _manager_obj = global.node_manager.interface_obj
				if (_mouse_check != _node.node_active && _manager_obj  != noone)
				{
					if (_mouse_check)
					{
						_manager_obj.canvas_active.nav_select_node(_node.path);				
					}
					_processor.mouse_hover = _mouse_check;
					_node.node_active = _processor.mouse_hover;
				}
			
			}
			add_process(_mouse_selection);
		}
	}
	
	#region UPDATE
	
	custom_update = function()
	{
		text = language_get_localized_text(text_key);
		font = language_get_localized_font(font_key);
		text_calculated = false;		
	}
	
	#endregion
	
	#region UTILITY
	
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
		font = language_get_localized_font(_font_key);
		outline = _outline;
	
		// Colors
		color1 = _color;
		color2 = _color;
		color3 = _color;
		color4 = _color;	
	
		alignment_h = fa_center;
		alignment_v = fa_middle;
	
		separation = -1;
		text_box = transform.size;
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
	
	///@function						node_text_set_box(_x, _y)
	///@description						Define the text box size
	static node_text_set_box = function(_x, _y)
	{		
		text_box = new Vector2(_x, _y);	
	}
			
	///@function						node_text_set_scale(_xscale, _yscale)
	///@description						Define the text scale
	static node_text_set_scale = function(_xscale, _yscale)
	{		
		text_scale = new Vector2(_xscale, _yscale);
	}
	
	///@function						node_text_set_offset(_xscale, _yscale)
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
			
			if (!_node.text_calculated)
			{
			    draw_set_font(_node.font);

			    var _txt_width = string_width(_node.text);

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
			
			// Draw sets
			draw_set_font(_node.font);
			draw_set_valign(_node.alignment_v);
			draw_set_halign(_node.alignment_h);

			// Drawing text
			draw_text_outlined(
				_text_x, 
				_text_y, 
				_node.text, 
				_node.separation, 
				_node.horizontal_wrap, 
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
	
	#region Start Default
	add_component_animator();
	//animator.set_state_motion(NODE_MOTION_STATE.IDLE, global.node_animator_db.active_scale_grow);
	#endregion

}

///@function							node_prefab_text(_text, _font, _color, _outline)
///@description							Prefab node made for drawing text elements
///@param {string} _name				Node name
///@param {string} _text				String to be drawed
///@param {Asset.GMFont, string} _font	Text font
///@param {Constant.Color} _color		Text color
///@param {bool} _outline				If the text should be drawed with an outline
function node_prefab_text(_name, _text, _font, _color, _outline = true) : node(_name) constructor 
{
	text_key = _text;
	text =  language_get_localized_text(_text);
	font = language_get_localized_font(_font);
	font_key = _font;
	outline = _outline;
	
	text_box = transform.size;
	
	// Colors
	color1 = _color;
	color2 = _color;
	color3 = _color;
	color4 = _color;	
	
	alignment_h = fa_center;
	alignment_v = fa_middle;
	
	separation = 0;
	horizontal_wrap = GUI_WIDTH;
	
	text_calculated = false;
	
	#region System Methods
	add_component_renderer();
	with (renderer)
	{	
		custom_draw = function(_node)
		{
			// Text Attributes
			var _x = _node.transform.position.x,
				_y = _node.transform.position.y;
			
			var _text = _node.text,
				_font = _node.font;
			
			if (!_node.text_calculated)
			{
			    draw_set_font(_font);

			    var _txt_width = string_width(_text);

			    _node.text_scale = new Vector2(1, 1);

			    if (_txt_width > _node.text_box.x)
			    {
			        _node.text_scale.x = round((_node.text_box.x / _txt_width) * 10) / 10;
			    }

			    _node.text_scale.y = _node.text_scale.x;

			    _node.text_calculated = true;
			}
			
			var _separation = _node.separation,
				_h_wrap = _node.horizontal_wrap;
			
			var _h_align = _node.alignment_h,
				_v_align = _node.alignment_v;
			
			var _color1 = _node.color1,
				_color2 = _node.color2,
				_color3 = _node.color3,
				_color4 = _node.color4;
			
			var _alpha = _node.transform.alpha;
			
			var _xscale = _node.transform.scale.x,
				_yscale = _node.transform.scale.y;
			
			var _rot = _node.transform.rotation;
			
			// Draw sets
			draw_set_font(_font);
			draw_set_valign(_v_align);
			draw_set_halign(_h_align);
						
			// Drawing text
			if (_node.outline)
			{
				draw_text_outlined(_x, _y, _text, -1, _h_wrap, _xscale, _yscale, _rot,_color1, _color2, _color3, _color4, _alpha);
			}
			else
			{
				draw_text_ext_transformed_color(_x, _y, _text, -1, _h_wrap, _xscale, _yscale, _rot,_color1, _color2, _color3, _color4, _alpha);
			}

			// Reseting draw_set
			draw_set_font(-1);
			draw_set_valign(-1);
			draw_set_halign(-1);
		}
	}
		
	#endregion
	
	#region UPDATE
	
	///@function		update()
	///@descriptions	Update the button variables when needed, example: Language or input mode change
	update = function()
	{
		text = language_get_localized_text(text_key);
		font = language_get_localized_font(font_key);
	}
	
	#endregion
	
	#region Utility Methods
	static set_alignment = function(_horizontal, _vertical)
	{
		alignment_h = _horizontal;
		alignment_v = _vertical;
		
		return self;
	}
	
	static set_horizontal_wrap = function(_wrap_w, _separation)
	{
		horizontal_wrap = _wrap_w;
		separation = _separation;
		
		return self;
	}
	
	static set_colors = function(_c1, _c2, _c3, _c4)
	{
		color1 = _c1;
		color2 = _c2;
		color3 = _c3;
		color4 = _c4;
		
		return self;
	}	
	#endregion
}


///@function						node_prefab_sprite(_text, _font, _color, _outline)
///@description						Prefab node made for drawing sprites
///@param {string} _name			Node name
///@param {Asset.GMSprite} _sprite	Sprite asset do be drawed
///@param {Constant.Color} _color	Sprite color
///@param {bool} _animate			If the sprite subimg should be animated
function node_prefab_sprite(_name, _sprite, _color = c_white, _animate = false) : node(_name) constructor 
{
	// Sprite attributes
	sprite = _sprite;
	sub_img = 0;
	animate = _animate;
	color = _color;	
	// Components
	add_component_processor();
	add_component_renderer();
	
	node_set_size(sprite_get_width(sprite), sprite_get_height(sprite));
	
	// Draw methods
	with (renderer)
	{	
		custom_draw = function(_node)
		{
			// Text Attributes
			var _x = _node.transform.position.x,
				_y = _node.transform.position.y;

			var _sprite = _node.sprite,
				_subimg = _node.sub_img,
				_color = _node.color;

			var _xscale = _node.transform.scale.x,
				_yscale = _node.transform.scale.y;
				
			var _rot = _node.transform.rotation,
				_alpha = _node.transform.alpha;
			
			draw_sprite_ext(_sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _color, _alpha);			
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

