
function node_array_sort_by_depth(_array, _id_array)
{
    var _amnt = array_length(_array);
    for (var _i = 0; _i < _amnt; _i++) 
	{
        for (var _j = 0; _j < _amnt - _i - 1; _j++) 
		{
            var _num1 = _array[_id_array[_j]].depth, 
				_num2 = _array[_id_array[_j+1]].depth;
				
            if (floor(_num1) < floor(_num2)) 
			{
                var _temp = _id_array[_j];
                _id_array[_j] = _id_array[_j+1];
                _id_array[_j+1] = _temp;
            }
        }
    }	
	return _id_array;
}

function __node_extract_rendering_order(_array, _type)
{
	var _len = array_length(_array);
	var _order_array = [];
	for (var _i = 0; _i < _len; _i++)
	{
		var _node = _array[_i];
		var _struct = new __node_render_ordenation(_type, _node.id, _node.depth);
		array_push(_order_array, variable_clone(_struct));
	}
	return _order_array;
}

	//	Vector 2
	//	Stores two values, a y position and a x position
	function Vector2(_x = 0, _y = _x) constructor {
		x = _x;
		y = _y;
						
		static get_magnitude = function()
		{
			var _mag = 0;
			_mag =  sqrt((x * x) + (y * y))				
			return _mag;
		}
			
		static normalize = function(){
			var _magnitude = get_magnitude();
			if (_magnitude == 0){
				x = 0;
				y = 0			
			}
			else
			{
				if (x != 0) x /= _magnitude;
				if (y != 0) y /= _magnitude;
			}
				
			return self;
		}

		static get_speed = function() {
			return point_distance(0, 0, x, y);
		}
			
		static get_direction = function(_x_origin = 0, _y_origin = 0) {
			return point_direction(_x_origin, _y_origin, x, y);
		}
			
		static is_null = function() {
			return ((x == noone) and (y == noone)) or ((x == undefined) and (y == undefined));
		}

		static lengthdir = function(_length, _dir) {
			x = lengthdir_x(_length, _dir);
			y = lengthdir_y(_length, _dir);
		
			return self;
		}
			
		static set_value = function(_x, _y) {
			x = _x;
			y = _y;	
			return self;
		}
			
		static lerpto = function(_vec2, _amount) {
			if is_vector2(_vec2) {
				x = lerp(x, _vec2.x, _amount);
				y = lerp(y, _vec2.y, _amount);
			}
			return self;
		}
			
		static compare = function(_vec2){
			return (x == _vec2.x && y == _vec2.y);	
		}
			
		static round_vec = function()
		{
			x = round(x);
			y = round(y);
		}
	}
	
	#macro VECTOR_RIGHT new Vector2(1,0)
	#macro VECTOR_LEFT new Vector2(-1,0)
	#macro VECTOR_UP new Vector2(0,1)
	#macro VECTOR_DOWN new Vector2(0,-1)