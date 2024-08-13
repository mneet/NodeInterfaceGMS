function __num_node_text(_text, _font, _color = c_white)  : __num_node() constructor
{
	text = _text;
	font = _font;
	color = _color;
	
	xoffset = 0;
	yoffset = 0;
	
	static set_text_offset = function(_x, _y){
		xoffset = _x;
		yoffset = _y;
		
		return self;
	}
}