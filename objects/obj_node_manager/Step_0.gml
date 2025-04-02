/// @description Node Manager Step

if (!__active_canvas) return;

if (!__system_started)
{
	__system_define_canvas();
}	

for (var _i = 0; _i < canvas_exhibiting_amnt; _i++)
{
	var _ind = canvas_exhibiting[_i];
	canvas_collection[_ind].processor.step_processor();
}
