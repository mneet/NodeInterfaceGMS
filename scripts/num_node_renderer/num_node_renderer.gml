// A renderer is made to be used inside a Node
// It can store sprites or text to be displayed in the interface

function __num_node_renderer() constructor
{
	visual_elements = [];
	custom_draw  = noone;
	
	static add_sprite = function(_sprite, _color = c_white){
		sprite = _sprite;
		sprite_color = _color;
		
		return self;
	}
	
	static add_text = function(_text, _font, _color = c_white){
		text = _text;
		text_font = _font;
		text_color = _color;
		
		return self;
	}
	
	static add_custom_draw = function(_custom_function){
		custom_draw = _custom_function;
	
		return self;
	}
	
	static draw = function(){
			
	}
}