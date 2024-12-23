/// @description Inserir descrição aqui
// Você pode escrever seu código neste editor

if (!__active_canvas) return;

if (!__system_started)
{
	__system_define_canvas();
}	

for (var _i = 0; _i < canvas_exibiting_amnt; _i++)
{
	var _ind = canvas_exibiting[_i];
	canvas_collection[_ind].processor.step_processor();
}
