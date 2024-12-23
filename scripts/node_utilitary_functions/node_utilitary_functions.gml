
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