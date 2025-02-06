/// @description Node Manager Draw GUI

if (!__active_canvas) return;
for (var _i = 0; _i < canvas_exibiting_amnt; _i++)
{
	var _ind = canvas_exibiting[_i];
	canvas_collection[_ind].renderer.draw();
}

draw_set_font(fnt_noto_10);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);

draw_text(2, GUI_HEIGHT, global.project_settings.game_version);

draw_set_font(-1);
draw_set_halign(-1);
draw_set_valign(-1);

//draw_line(GUI_WIDTH/2, 0, GUI_WIDTH/2, GUI_HEIGHT);
//draw_line(0, GUI_HEIGHT/2, GUI_WIDTH, GUI_HEIGHT/2);

//draw_circle_color(canvas_active.nav_position.x, canvas_active.nav_position.y, 5,c_orange, c_blue, false);


//draw_line(GUI_WIDTH/2, 0, GUI_WIDTH/2, GUI_HEIGHT);

//for (var _y = 0; _y < canvas_active.nav_grid_dimension.y; _y++)
//{
//	for (var _x = 0; _x < canvas_active.nav_grid_dimension.x; _x++)
//	{
//		var _x_pos = 10 + global.node_manager.nav_grid_cell_size.x * _x;
//		var _y_pos = 10 + global.node_manager.nav_grid_cell_size.y * _y;
//		var _color = c_red;
//		if (canvas_active.nav_grid[_x, _y] == noone) _color = c_white;
//		draw_circle_color(_x_pos, _y_pos, 5, _color, _color, false);	
//	}
//}
















